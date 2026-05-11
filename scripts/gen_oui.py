#!/usr/bin/env python3
"""Generate assets/data/oui.db from the official IEEE OUI CSV.

This is the preferred OUI generator because it only uses Python's standard
library and writes the database atomically.
"""

from __future__ import annotations

import argparse
import csv
import os
import sqlite3
import sys
import tempfile
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


DEFAULT_OUI_URL = "https://standards-oui.ieee.org/oui/oui.csv"
DEFAULT_OUTPUT = Path("assets/data/oui.db")
MIN_EXPECTED_RECORDS = 30_000
USER_AGENT = "Torcav-OUI-Generator/1.0"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate the Torcav OUI SQLite database.",
    )
    parser.add_argument(
        "--url",
        default=DEFAULT_OUI_URL,
        help=f"OUI CSV URL. Defaults to {DEFAULT_OUI_URL}",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"Output database path. Defaults to {DEFAULT_OUTPUT}",
    )
    parser.add_argument(
        "--min-records",
        type=int,
        default=MIN_EXPECTED_RECORDS,
        help="Fail if fewer records are parsed.",
    )
    return parser.parse_args()


def fetch_csv(url: str) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read().decode("utf-8-sig")


def normalize_assignment(value: str) -> str | None:
    clean = "".join(ch for ch in value.upper() if ch in "0123456789ABCDEF")
    if len(clean) != 6:
        return None
    return f"{clean[0:2]}:{clean[2:4]}:{clean[4:6]}"


def iter_oui_rows(csv_text: str):
    reader = csv.DictReader(csv_text.splitlines())
    required_columns = {"Assignment", "Organization Name"}
    missing_columns = required_columns - set(reader.fieldnames or [])
    if missing_columns:
        raise ValueError(f"Missing expected CSV columns: {', '.join(sorted(missing_columns))}")

    for row in reader:
        prefix = normalize_assignment(row.get("Assignment", ""))
        vendor = " ".join((row.get("Organization Name") or "").split())
        if prefix and vendor:
            yield prefix, vendor


def create_database(output: Path, rows: list[tuple[str, str]], source_url: str) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(
        prefix=f".{output.name}.",
        suffix=".tmp",
        dir=output.parent,
    )
    os.close(fd)
    temp_path = Path(temp_name)

    try:
        with sqlite3.connect(temp_path) as conn:
            conn.execute("PRAGMA journal_mode = OFF")
            conn.execute("PRAGMA synchronous = OFF")
            conn.execute(
                """
                CREATE TABLE oui (
                    prefix TEXT PRIMARY KEY,
                    vendor TEXT NOT NULL
                )
                """
            )
            conn.execute(
                """
                CREATE TABLE metadata (
                    key TEXT PRIMARY KEY,
                    value TEXT NOT NULL
                )
                """
            )
            conn.executemany(
                "INSERT OR REPLACE INTO oui(prefix, vendor) VALUES (?, ?)",
                rows,
            )
            conn.executemany(
                "INSERT OR REPLACE INTO metadata(key, value) VALUES (?, ?)",
                [
                    ("source", source_url),
                    ("generatedAt", datetime.now(timezone.utc).isoformat()),
                    ("recordCount", str(len(rows))),
                ],
            )
            conn.execute("PRAGMA user_version = 1")
            conn.commit()

        os.replace(temp_path, output)
    except Exception:
        temp_path.unlink(missing_ok=True)
        raise


def main() -> int:
    args = parse_args()

    print(f"Fetching OUI data from {args.url}...")
    try:
        csv_text = fetch_csv(args.url)
        prefix_to_vendor = dict(iter_oui_rows(csv_text))
        rows = sorted(prefix_to_vendor.items())
    except Exception as error:
        print(f"Error: failed to fetch or parse OUI data: {error}", file=sys.stderr)
        return 1

    if len(rows) < args.min_records:
        print(
            f"Error: parsed only {len(rows)} records; expected at least {args.min_records}.",
            file=sys.stderr,
        )
        return 1

    print(f"Writing {len(rows)} records to {args.output}...")
    try:
        create_database(args.output, rows, args.url)
    except Exception as error:
        print(f"Error: failed to write database: {error}", file=sys.stderr)
        return 1

    print("OUI database generation complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
