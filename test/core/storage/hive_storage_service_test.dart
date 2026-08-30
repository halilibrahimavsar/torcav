import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

/// The box name `HiveStorageService` opens. Private in the service, asserted
/// here because it is the on-disk contract: renaming it orphans every
/// existing install's preferences.
const _boxName = 'torcav_preferences';

List<int> _key(int seed) {
  final rng = Random(seed);
  return List<int>.generate(32, (_) => rng.nextInt(256));
}

void main() {
  late Directory dir;
  late HiveStorageService service;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('torcav_hive_test');
    // `HiveStorageService.init` calls `Hive.initFlutter`, which needs the
    // path_provider platform channel. Opening the box directly exercises the
    // same cipher path without a platform binding.
    Hive.init(dir.path);
    service = HiveStorageService();
  });

  tearDown(() async {
    await Hive.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('bootstrap guard', () {
    test('accessing storage before init explains the bootstrap order', () {
      expect(
        () => service.box,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('init() not called'),
              contains('SecureStorage'),
              contains('configureDependencies'),
            ),
          ),
        ),
      );
    });
  });

  group('encrypted box', () {
    setUp(() async {
      await Hive.openBox(
        _boxName,
        encryptionCipher: HiveAesCipher(_key(1)),
      );
    });

    test('values round-trip', () async {
      await service.save('ssid', 'HomeNet');
      await service.save('count', 7);

      expect(service.get<String>('ssid'), 'HomeNet');
      expect(service.get<int>('count'), 7);
    });

    test('missing key returns null, not the default', () {
      expect(service.get<String>('absent'), isNull);
    });

    test('type mismatch returns the default instead of throwing', () async {
      await service.save('count', 7);

      // A stored int read as String must not crash the caller — this guard is
      // what keeps a schema change from bricking startup.
      expect(service.get<String>('count', defaultValue: 'fallback'), 'fallback');
    });

    test('delete removes a single key, clearAll empties the box', () async {
      await service.save('a', 1);
      await service.save('b', 2);

      await service.delete('a');
      expect(service.get<int>('a'), isNull);
      expect(service.get<int>('b'), 2);

      await service.clearAll();
      expect(service.get<int>('b'), isNull);
    });
  });

  // The privacy invariant is "storage is encrypted at rest". These two
  // tests pin what the cipher actually does — and what it does *not* do.
  group('encryption at rest', () {
    test('the box file holds no plaintext', () async {
      await Hive.openBox(_boxName, encryptionCipher: HiveAesCipher(_key(1)));
      await service.save('psk', 'SuperSecret123');
      await Hive.close();

      final file = File('${dir.path}/$_boxName.hive');
      expect(file.existsSync(), isTrue);
      expect(
        String.fromCharCodes(file.readAsBytesSync()),
        isNot(contains('SuperSecret123')),
        reason: 'the value was written to disk unencrypted',
      );
    });

    // Documents a real defect, found by writing this test.
    //
    // `HiveStorageService.init` wraps `openBox` in a try/catch whose comment
    // says the box is deleted and recreated "if the existing box cannot be
    // decrypted with [encryptionKey] (cipher mismatch, e.g. after a
    // secure-storage reset)". Hive does not behave that way: a wrong key
    // opens successfully and presents an *empty* box. The recovery branch
    // therefore never runs, and a cipher mismatch is indistinguishable from
    // a first launch — the user's preferences silently revert to defaults
    // while the old encrypted file stays on disk forever.
    //
    // Locked in as the current behaviour so a future fix has to update this
    // test deliberately rather than by accident.
    test('a wrong key opens an EMPTY box instead of throwing', () async {
      await Hive.openBox(_boxName, encryptionCipher: HiveAesCipher(_key(1)));
      await service.save('secret', 'HomeNet-PSK');
      expect(service.get<String>('secret'), 'HomeNet-PSK');
      await Hive.close();

      Hive.init(dir.path);
      final reopened = await Hive.openBox(
        _boxName,
        encryptionCipher: HiveAesCipher(_key(2)),
      );

      expect(reopened.isEmpty, isTrue);
      expect(service.get<String>('secret'), isNull);
    });
  });
}
