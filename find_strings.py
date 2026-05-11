#!/usr/bin/env python3
"""Find hard-coded, user-visible Dart strings that should likely be localized.

The scanner is intentionally heuristic. It does not try to parse the full Dart
grammar, but it does tokenize Dart string literals and then scores the local
context around each literal. This catches more UI text than a widget-name regex
while still filtering out imports, asset paths, keys, colors, ids, and generated
l10n files.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import signal
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable, Iterator, Sequence


DEFAULT_SCAN_ROOT = "lib"

EXCLUDED_DIRS = {
    ".dart_tool",
    ".git",
    "build",
    "coverage",
    "ios",
    "android",
    "macos",
    "linux",
    "windows",
    "web",
}

EXCLUDED_FILE_PARTS = {
    f"{os.sep}core{os.sep}l10n{os.sep}app_localizations",
    f"{os.sep}core{os.sep}l10n{os.sep}app_",
}

LOCALIZATION_PATTERNS = (
    "context.l10n",
    "AppLocalizations.of",
    "lookupAppLocalizations",
)

VISIBLE_WIDGETS = {
    "AboutDialog",
    "ActionChip",
    "AlertDialog",
    "AppBar",
    "Banner",
    "BottomNavigationBarItem",
    "Card",
    "CheckboxListTile",
    "Chip",
    "ChoiceChip",
    "CupertinoActionSheet",
    "CupertinoAlertDialog",
    "CupertinoDialogAction",
    "CupertinoNavigationBar",
    "CupertinoSearchTextField",
    "CupertinoTextField",
    "DataColumn",
    "DropdownMenuEntry",
    "ExpansionTile",
    "FilterChip",
    "FloatingActionButton",
    "InputChip",
    "InputDecoration",
    "ListTile",
    "MenuItemButton",
    "NavigationDestination",
    "NavigationRailDestination",
    "NeonButton",
    "NeonSectionHeader",
    "NeonText",
    "OutlinedButton",
    "PopupMenuItem",
    "ProminentDisclosureDialog",
    "RadioListTile",
    "SearchBar",
    "SearchAnchor",
    "SegmentedButton",
    "Semantics",
    "SimpleDialog",
    "SimpleDialogOption",
    "SnackBar",
    "SwitchListTile",
    "Tab",
    "Text",
    "TextButton",
    "TextField",
    "TextFormField",
    "TextSpan",
    "Tooltip",
}

VISIBLE_PARAMETER_NAMES = {
    "actionLabel",
    "ariaLabel",
    "body",
    "cancelLabel",
    "caption",
    "confirmLabel",
    "content",
    "description",
    "emptyText",
    "errorText",
    "helperText",
    "hint",
    "hintText",
    "label",
    "labelText",
    "message",
    "name",
    "placeholder",
    "prefixText",
    "semanticsLabel",
    "semanticLabel",
    "subLabel",
    "subtitle",
    "suffixText",
    "text",
    "title",
    "tooltip",
    "trailing",
}

TECHNICAL_PARAMETER_NAMES = {
    "asset",
    "assetName",
    "backend",
    "command",
    "debugLabel",
    "fontFamily",
    "heroTag",
    "id",
    "key",
    "languageCode",
    "locale",
    "namePrefix",
    "package",
    "path",
    "routeName",
    "tag",
    "url",
    "valueKey",
}

@dataclass(frozen=True)
class StringLiteral:
    value: str
    start: int
    end: int
    line: int
    quote: str
    is_raw: bool


@dataclass(frozen=True)
class Finding:
    file: str
    line: int
    string: str
    reason: str
    context: str


def iter_dart_files(root: Path, include_tests: bool = False) -> Iterator[Path]:
    for path in root.rglob("*.dart"):
        parts = set(path.parts)
        if parts & EXCLUDED_DIRS:
            continue
        normalized = str(path)
        if any(part in normalized for part in EXCLUDED_FILE_PARTS):
            continue
        if not include_tests and ("test" in parts or path.name.endswith("_test.dart")):
            continue
        yield path


def unescape_dart_string(body: str, is_raw: bool) -> str:
    if is_raw:
        return body
    replacements = {
        r"\n": "\n",
        r"\r": "\r",
        r"\t": "\t",
        r"\'": "'",
        r"\"": '"',
        r"\\": "\\",
    }
    for escaped, value in replacements.items():
        body = body.replace(escaped, value)
    return body


def quote_at(source: str, position: int) -> str | None:
    return next(
        (quote for quote in ("'''", '"""', "'", '"') if source.startswith(quote, position)),
        None,
    )


def is_identifier_char(char: str) -> bool:
    return char.isalnum() or char == "_"


def scan_quoted_region(source: str, start: int, quote: str) -> int:
    i = start + len(quote)
    while i < len(source):
        if source.startswith(quote, i):
            return i + len(quote)
        nested_quote = quote_at(source, i)
        if nested_quote:
            i = scan_quoted_region(source, i, nested_quote)
            continue
        if source.startswith("//", i):
            end = source.find("\n", i)
            i = len(source) if end == -1 else end
            continue
        if source.startswith("/*", i):
            end = source.find("*/", i + 2)
            i = len(source) if end == -1 else end + 2
            continue
        if source[i] == "{":
            i = scan_balanced_braces(source, i)
            continue
        if source[i] == "}":
            return i + 1
        if source[i] == "\\":
            i += 2
            continue
        i += 1
    return i


def scan_balanced_braces(source: str, start: int) -> int:
    depth = 0
    i = start
    while i < len(source):
        nested_quote = quote_at(source, i)
        if nested_quote:
            i = scan_quoted_region(source, i, nested_quote)
            continue
        if source.startswith("//", i):
            end = source.find("\n", i)
            i = len(source) if end == -1 else end
            continue
        if source.startswith("/*", i):
            end = source.find("*/", i + 2)
            i = len(source) if end == -1 else end + 2
            continue
        if source[i] == "{":
            depth += 1
        elif source[i] == "}":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return i


def scan_dart_string(source: str, start: int, quote: str, is_raw: bool) -> tuple[str, int]:
    body: list[str] = []
    i = start + len(quote) + (1 if is_raw else 0)
    while i < len(source):
        if source.startswith(quote, i):
            return "".join(body), i + len(quote)
        if not is_raw and source[i] == "\\":
            body.append(source[i : min(len(source), i + 2)])
            i += 2
            continue
        if not is_raw and source.startswith("${", i):
            end = scan_balanced_braces(source, i + 1)
            body.append(source[i:end])
            i = end
            continue
        if not is_raw and source[i] == "$" and i + 1 < len(source) and (
            source[i + 1].isalpha() or source[i + 1] == "_"
        ):
            end = i + 2
            while end < len(source) and is_identifier_char(source[end]):
                end += 1
            body.append(source[i:end])
            i = end
            continue
        body.append(source[i])
        i += 1
    return "".join(body), i


def iter_string_literals(source: str) -> Iterator[StringLiteral]:
    i = 0
    while i < len(source):
        if source.startswith("//", i):
            end = source.find("\n", i)
            i = len(source) if end == -1 else end
            continue
        if source.startswith("/*", i):
            end = source.find("*/", i + 2)
            i = len(source) if end == -1 else end + 2
            continue

        is_raw = False
        quote = quote_at(source, i)
        if (
            quote is None
            and source[i : i + 1] == "r"
            and (i == 0 or not is_identifier_char(source[i - 1]))
        ):
            quote = quote_at(source, i + 1)
            is_raw = quote is not None

        if quote is None:
            i += 1
            continue

        body, end = scan_dart_string(source, i, quote, is_raw=is_raw)
        yield StringLiteral(
            value=unescape_dart_string(body, is_raw=is_raw),
            start=i,
            end=end,
            line=source.count("\n", 0, i) + 1,
            quote=quote,
            is_raw=is_raw,
        )
        i = end


def compact(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def line_at(source: str, position: int) -> str:
    line_start = source.rfind("\n", 0, position) + 1
    line_end = source.find("\n", position)
    return source[line_start : len(source) if line_end == -1 else line_end].strip()


def previous_identifier(source: str, position: int) -> str | None:
    before = source[:position]
    match = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*:\s*$", before)
    return match.group(1) if match else None


def previous_call(source: str, position: int, window: int = 120) -> str | None:
    before = source[max(0, position - window) : position]
    matches = re.findall(r"\b([A-Za-z_][A-Za-z0-9_\.]*)\s*\(", before)
    return matches[-1] if matches else None


def nearby_constructor(source: str, position: int, window: int = 180) -> str | None:
    before = source[max(0, position - window) : position]
    matches = re.findall(r"\b([A-Z][A-Za-z0-9_]*)\s*\(", before)
    return matches[-1] if matches else None


def is_localized_expression(source: str, literal: StringLiteral) -> bool:
    context = source[max(0, literal.start - 120) : literal.end + 120]
    return any(pattern in context for pattern in LOCALIZATION_PATTERNS)


def is_import_or_directive(source: str, literal: StringLiteral) -> bool:
    line = line_at(source, literal.start)
    return bool(re.match(r"^(import|export|part|library)\b", line))


def looks_like_technical_string(value: str, parameter: str | None = None) -> bool:
    text = compact(value)
    upper = text.upper()
    if not text:
        return True
    if parameter in TECHNICAL_PARAMETER_NAMES:
        return True
    if len(text) == 1 and not text.isalpha():
        return True
    if re.fullmatch(r"[\d\s.,:%/+×xX°-]+", text):
        return True
    if upper.startswith(
        (
            "ALTER TABLE ",
            "CREATE INDEX ",
            "CREATE TABLE ",
            "DELETE FROM ",
            "DROP TABLE ",
            "INSERT INTO ",
            "PRAGMA ",
            "SELECT ",
            "UPDATE ",
        )
    ):
        return True
    if re.fullmatch(r"[a-z_]+(\s*[<>=!]+\s*\?)?", text):
        return True
    if re.fullmatch(r"(0x)?[0-9A-Fa-f]{4,}", text):
        return True
    if re.fullmatch(r"[a-z0-9_.-]+/[a-z0-9_./-]+", text):
        return True
    if re.fullmatch(r"[a-z]+(\.[a-z0-9_]+)+", text):
        return True
    if re.fullmatch(r"[a-z][a-z0-9_]*", text) and len(text) > 2:
        return True
    if text.startswith(("http://", "https://", "package:", "asset:", "file:")):
        return True
    if text.startswith(("@mipmap/", "<!doctype", "<html", "<head", "<meta", "<title>")):
        return True
    if re.fullmatch(r"[HhmsSaZE:/., -]+", text):
        return True
    if re.fullmatch(r"-{1,2}[A-Za-z0-9-]+", text):
        return True
    if re.search(r"\.(png|jpg|jpeg|gif|svg|json|db|arb|dart|ttf|otf|frag|onnx)$", text, re.I):
        return True
    if re.fullmatch(r"[A-Z_][A-Z0-9_]*", text) and "_" in text:
        return True
    return False


def looks_human_readable(value: str) -> bool:
    text = compact(value)
    if not text:
        return False
    if re.search(r"[A-Za-zÇĞİÖŞÜçğıöşü]", text) is None:
        return False
    if " " in text or any(ch in text for ch in ".,!?;:/&-'’·"):
        return True
    if re.fullmatch(r"[A-Z][A-Z0-9-]{1,}", text):
        return True
    if re.fullmatch(r"[A-Z][a-z]+([A-Z][a-z]+)+", text):
        return True
    if re.fullmatch(r"[A-Z][a-z]{2,}", text):
        return True
    return False


def interpolation_shell(value: str) -> str:
    without_braced = re.sub(r"\$\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}", " ", value)
    return re.sub(r"\$[A-Za-z_][A-Za-z0-9_]*", " ", without_braced)


def has_localizable_text_outside_interpolation(value: str) -> bool:
    shell = interpolation_shell(value)
    return looks_human_readable(shell)


def classify_literal(source: str, literal: StringLiteral) -> str | None:
    value = literal.value
    parameter = previous_identifier(source, literal.start)
    call = previous_call(source, literal.start)
    constructor = nearby_constructor(source, literal.start)

    if is_import_or_directive(source, literal):
        return None
    if is_localized_expression(source, literal):
        return None
    if call in {"db.execute", "db.query", "db.insert", "print", "debugPrint", "log"}:
        return None
    if looks_like_technical_string(value, parameter):
        return None

    if parameter in VISIBLE_PARAMETER_NAMES and looks_human_readable(value):
        if ("${" in value or "$" in value) and not has_localizable_text_outside_interpolation(value):
            return None
        return f"visible parameter `{parameter}`"
    if constructor in VISIBLE_WIDGETS and looks_human_readable(value):
        if ("${" in value or "$" in value) and not has_localizable_text_outside_interpolation(value):
            return None
        return f"visible widget `{constructor}`"
    if "${" in value or "$" in value:
        if (
            has_localizable_text_outside_interpolation(value)
            and (parameter in VISIBLE_PARAMETER_NAMES or constructor in VISIBLE_WIDGETS)
        ):
            return "interpolated human-readable string"
        return None
    if looks_human_readable(value) and constructor not in {None, "RegExp", "Uri"}:
        return f"human-readable literal near `{constructor}`"
    return None


def find_hardcoded_strings(directory: str | Path, include_tests: bool = False) -> list[Finding]:
    root = Path(directory).expanduser().resolve()
    findings: list[Finding] = []

    for path in sorted(iter_dart_files(root, include_tests=include_tests)):
        source = path.read_text(encoding="utf-8")
        for literal in iter_string_literals(source):
            reason = classify_literal(source, literal)
            if not reason:
                continue
            findings.append(
                Finding(
                    file=str(path),
                    line=literal.line,
                    string=compact(literal.value),
                    reason=reason,
                    context=line_at(source, literal.start),
                )
            )

    return dedupe_findings(findings)


def dedupe_findings(findings: Sequence[Finding]) -> list[Finding]:
    seen: set[tuple[str, int, str]] = set()
    unique: list[Finding] = []
    for finding in findings:
        key = (finding.file, finding.line, finding.string)
        if key in seen:
            continue
        seen.add(key)
        unique.append(finding)
    return sorted(unique, key=lambda item: (item.file, item.line, item.string))


def format_text(findings: Iterable[Finding], show_reason: bool = False) -> str:
    lines = []
    for finding in findings:
        suffix = f"  [{finding.reason}]" if show_reason else ""
        lines.append(f"{finding.file}:{finding.line}: {finding.string}{suffix}")
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Find likely localizable hard-coded Dart strings.",
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=DEFAULT_SCAN_ROOT,
        help=f"Directory to scan. Defaults to `{DEFAULT_SCAN_ROOT}`.",
    )
    parser.add_argument(
        "--include-tests",
        action="store_true",
        help="Include test files in the scan.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print findings as JSON.",
    )
    parser.add_argument(
        "--reason",
        action="store_true",
        help="Include the heuristic reason in text output.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    findings = find_hardcoded_strings(args.directory, include_tests=args.include_tests)

    if args.json:
        print(json.dumps([asdict(f) for f in findings], ensure_ascii=False, indent=2))
    else:
        output = format_text(findings, show_reason=args.reason)
        if output:
            print(output)
        print(f"\nFound {len(findings)} likely localizable hard-coded strings.")

    return 1 if findings else 0


if __name__ == "__main__":
    if hasattr(signal, "SIGPIPE"):
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    try:
        raise SystemExit(main())
    except BrokenPipeError:
        sys.exit(1)
