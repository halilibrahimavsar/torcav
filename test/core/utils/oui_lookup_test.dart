import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/oui_database_service.dart';
import 'package:torcav/core/utils/oui_lookup.dart';

class MockOuiDatabaseService extends Mock implements OuiDatabaseService {}

void main() {
  late MockOuiDatabaseService mockDb;
  late OuiLookup lookup;

  setUp(() {
    mockDb = MockOuiDatabaseService();
    lookup = OuiLookup(mockDb);
  });

  test('looks up vendors from the database service', () async {
    when(
      () => mockDb.getVendor('14:36:0E:AA:BB:CC'),
    ).thenAnswer((_) async => 'Turk Telekom');
    when(
      () => mockDb.getVendor('6C:E8:73:00:11:22'),
    ).thenAnswer((_) async => 'Xiaomi');
    when(() => mockDb.getVendor('invalid')).thenAnswer((_) async => 'Unknown');

    expect(await lookup.lookup('14:36:0E:AA:BB:CC'), 'Turk Telekom');
    expect(await lookup.lookup('6C:E8:73:00:11:22'), 'Xiaomi');
    expect(await lookup.lookup('invalid'), 'Unknown');
  });

  test('flags locally administered MAC addresses as suspicious', () {
    expect(OuiLookup.isSuspicious('02:11:22:33:44:55'), isTrue);
    expect(OuiLookup.isSuspicious('06:11:22:33:44:55'), isTrue);
    expect(OuiLookup.isSuspicious('0A-11-22-33-44-55'), isTrue);
    expect(OuiLookup.isSuspicious('0e1122334455'), isTrue);
    expect(OuiLookup.isSuspicious('00:11:22:33:44:55'), isFalse);
    expect(OuiLookup.isSuspicious('invalid'), isFalse);
  });

  test('normalizes MAC addresses to OUI prefixes', () {
    expect(
      OuiDatabaseService.normalizeMacToOui('14:36:0e:aa:bb:cc'),
      '14:36:0E',
    );
    expect(
      OuiDatabaseService.normalizeMacToOui('14-36-0E-AA-BB-CC'),
      '14:36:0E',
    );
    expect(OuiDatabaseService.normalizeMacToOui('14360EAABBCC'), '14:36:0E');
    expect(OuiDatabaseService.normalizeMacToOui('bad'), isNull);
  });

  test('detects zeroed restricted MAC addresses', () {
    expect(OuiDatabaseService.isZeroedMac('00:00:00:00:00:00'), isTrue);
    expect(OuiDatabaseService.isZeroedMac('000000000000'), isTrue);
    expect(OuiDatabaseService.isZeroedMac('00:00:00'), isFalse);
    expect(OuiDatabaseService.isZeroedMac('00:00:00:00:00:01'), isFalse);
  });

  test('detects stale local database bytes', () async {
    final service = OuiDatabaseService();
    final tempDir = await Directory.systemTemp.createTemp('oui_db_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    final dbFile = File('${tempDir.path}/oui.db');
    await dbFile.writeAsBytes([1, 2, 3]);

    expect(
      await service.isLocalDatabaseCurrentForTest(dbFile, [1, 2, 3]),
      isTrue,
    );
    expect(
      await service.isLocalDatabaseCurrentForTest(dbFile, [1, 2, 4]),
      isFalse,
    );
    expect(
      await service.isLocalDatabaseCurrentForTest(
        File('${tempDir.path}/missing.db'),
        [1],
      ),
      isFalse,
    );
  });
}
