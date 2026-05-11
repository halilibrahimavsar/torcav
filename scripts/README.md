# Scripts

## `gen_oui.py`

Preferred generator for `assets/data/oui.db`.

It downloads the official IEEE OUI CSV, normalizes assignments to `XX:XX:XX`,
stores vendor names in SQLite, and writes the database atomically so a failed
download cannot corrupt the existing asset.

```bash
python3 scripts/gen_oui.py
python3 scripts/gen_oui.py --output /tmp/oui.db
```

## `generate_oui_db.dart`

Dart equivalent of the OUI generator. It is useful when you want to run the
same generation path with the project's Dart dependencies.

```bash
dart scripts/generate_oui_db.dart
dart scripts/generate_oui_db.dart --output /tmp/oui.db
```

Both scripts should produce the same `oui` table and metadata.
