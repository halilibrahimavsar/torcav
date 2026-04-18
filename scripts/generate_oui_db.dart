// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

/// Standalone script to generate the OUI database for Torcav.
///
/// Usage: dart scripts/generate_oui_db.dart
void main() async {
  print('--- Torcav OUI Database Generator ---');

  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  final projectRoot = Directory.current.path;
  final dbPath = p.join(projectRoot, 'assets', 'data', 'oui.db');

  // Ensure directory exists
  final dataDir = Directory(p.dirname(dbPath));
  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }

  // Delete old DB if exists
  final dbFile = File(dbPath);
  if (await dbFile.exists()) {
    print('Deleting existing database at $dbPath...');
    await dbFile.delete();
  }

  print('Opening database...');
  final db = await databaseFactory.openDatabase(dbPath);

  print('Creating tables...');
  await db.execute('''
    CREATE TABLE oui (
      prefix TEXT PRIMARY KEY,
      vendor TEXT NOT NULL
    )
  ''');

  print('Downloading OUI data from IEEE...');
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('http://standards-oui.ieee.org/oui/oui.csv'),
    );
    final response = await request.close();

    if (response.statusCode != 200) {
      print(
        'Error: Failed to download OUI data. Status code: ${response.statusCode}',
      );
      return;
    }

    print('Parsing data and inserting into database...');
    final lines = response
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    int count = 0;
    await db.transaction((txn) async {
      await for (final line in lines) {
        if (line.isEmpty || line.startsWith('Registry')) continue;

        // CSV format: Registry,Assignment,Organization Name,Organization Address
        // Example: MA-L,002272,American Micro-Systems Inc.,...
        final parts = _parseCsvLine(line);
        if (parts.length < 3) continue;

        final assignment = parts[1]; // e.g. "002272"
        final vendor = parts[2]; // e.g. "American Micro-Systems Inc."

        if (assignment.length != 6) continue;

        // Format to XX:XX:XX
        final prefix =
            '${assignment.substring(0, 2)}:${assignment.substring(2, 4)}:${assignment.substring(4, 6)}'
                .toUpperCase();

        await txn.insert('oui', {
          'prefix': prefix,
          'vendor': vendor,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        count++;
        if (count % 1000 == 0) {
          print('Inserted $count entries...');
        }
      }
    });

    print('Finalizing...');
    // Add internal mapping for Restricted Android MACs
    await db.insert('oui', {
      'prefix': '00:00:00',
      'vendor': 'Android Device (MAC Restricted)',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    print('Success! Database created with $count entries at $dbPath');
  } catch (e) {
    print('Fatal error: $e');
  } finally {
    await db.close();
    client.close();
  }
}

List<String> _parseCsvLine(String line) {
  final result = <String>[];
  bool inQuotes = false;
  var current = StringBuffer();

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(current.toString().trim());
      current.clear();
    } else {
      current.write(char);
    }
  }
  result.add(current.toString().trim());
  return result;
}
