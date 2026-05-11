// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

/// Standalone script to generate the OUI database for Torcav.
///
/// Usage: dart scripts/generate_oui_db.dart [--output assets/data/oui.db]
Future<void> main(List<String> arguments) async {
  print('--- Torcav OUI Database Generator ---');

  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  final projectRoot = Directory.current.path;
  final args = _parseArgs(arguments);
  final dbPath =
      args.outputPath == null
          ? p.join(projectRoot, 'assets', 'data', 'oui.db')
          : p.normalize(p.absolute(args.outputPath!));
  final tempDbPath = '$dbPath.tmp';

  // Ensure directory exists
  final dataDir = Directory(p.dirname(dbPath));
  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }

  final tempDbFile = File(tempDbPath);
  if (await tempDbFile.exists()) {
    await tempDbFile.delete();
  }

  print('Opening database...');
  final db = await databaseFactory.openDatabase(tempDbPath);
  var dbClosed = false;

  print('Creating tables...');
  await db.execute('''
    CREATE TABLE oui (
      prefix TEXT PRIMARY KEY,
      vendor TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE metadata (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');

  print('Downloading OUI data from IEEE...');
  final client = HttpClient();
  client.userAgent = 'Torcav-OUI-Generator/1.0';
  try {
    final request = await client.getUrl(
      Uri.parse('https://standards-oui.ieee.org/oui/oui.csv'),
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
    final seenPrefixes = <String>{};
    await db.transaction((txn) async {
      await for (final line in lines) {
        if (line.isEmpty || line.startsWith('Registry')) continue;

        // CSV format: Registry,Assignment,Organization Name,Organization Address
        // Example: MA-L,002272,American Micro-Systems Inc.,...
        final parts = _parseCsvLine(line);
        if (parts.length < 3) continue;

        final assignment = parts[1]; // e.g. "002272"
        final vendor = parts[2].replaceAll(RegExp(r'\s+'), ' ').trim();

        if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(assignment)) continue;

        // Format to XX:XX:XX
        final prefix =
            '${assignment.substring(0, 2)}:${assignment.substring(2, 4)}:${assignment.substring(4, 6)}'
                .toUpperCase();
        final isNewPrefix = seenPrefixes.add(prefix);

        await txn.insert('oui', {
          'prefix': prefix,
          'vendor': vendor,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        if (isNewPrefix) count++;
        if (count % 1000 == 0) {
          print('Inserted $count entries...');
        }
      }
    });

    if (count < 30000) {
      throw StateError(
        'Parsed only $count OUI records; expected at least 30000.',
      );
    }

    print('Finalizing...');
    await db.insert('metadata', {
      'key': 'source',
      'value': 'https://standards-oui.ieee.org/oui/oui.csv',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('metadata', {
      'key': 'generatedAt',
      'value': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('metadata', {
      'key': 'recordCount',
      'value': '$count',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.close();
    dbClosed = true;
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await File(tempDbPath).rename(dbPath);

    print('Success! Database created with $count entries at $dbPath');
  } catch (e) {
    print('Fatal error: $e');
    exitCode = 1;
  } finally {
    if (!dbClosed) {
      await db.close();
    }
    if (await tempDbFile.exists()) {
      await tempDbFile.delete();
    }
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
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
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

class _Args {
  const _Args({this.outputPath});

  final String? outputPath;
}

_Args _parseArgs(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--output' && i + 1 < args.length) {
      return _Args(outputPath: args[i + 1]);
    }
    if (args[i].startsWith('--output=')) {
      return _Args(outputPath: args[i].substring('--output='.length));
    }
  }
  return const _Args();
}
