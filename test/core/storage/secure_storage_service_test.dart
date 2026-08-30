import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/secure_storage_service.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// In-memory stand-in for the platform keystore, so key *generation* and
/// *persistence* can be asserted separately from the plugin.
class _FakeKeystore {
  final Map<String, String> values = {};
  int writeCount = 0;

  void bind(_MockSecureStorage mock) {
    when(() => mock.read(key: any(named: 'key'))).thenAnswer((invocation) async {
      return values[invocation.namedArguments[#key] as String];
    });
    when(
      () => mock.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((invocation) async {
      writeCount++;
      values[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
  }
}

void main() {
  late _MockSecureStorage storage;
  late _FakeKeystore keystore;
  late SecureStorageService service;

  setUp(() {
    storage = _MockSecureStorage();
    keystore = _FakeKeystore()..bind(storage);
    service = SecureStorageService(storage);
  });

  group('database encryption key', () {
    test('is generated on first use and persisted', () async {
      final key = await service.getDatabaseEncryptionKey();

      expect(key, isNotEmpty);
      expect(keystore.writeCount, 1);
      expect(keystore.values['torcav_db_encryption_key'], key);
    });

    test('is stable across calls — a new key would orphan the database', () {
      // If this ever regenerated, every previously encrypted row would become
      // unreadable and the user would silently lose all local history.
      return expectLater(
        Future(() async {
          final first = await service.getDatabaseEncryptionKey();
          final second = await service.getDatabaseEncryptionKey();
          expect(second, first);
          expect(keystore.writeCount, 1, reason: 'key was rewritten');
        }),
        completes,
      );
    });
  });

  group('Hive box key', () {
    test('is exactly 32 bytes — AES-256 requires it', () async {
      final key = await service.getOrCreateHiveBoxKey();

      expect(key, hasLength(32));
      expect(key.every((b) => b >= 0 && b <= 255), isTrue);
    });

    test('persists as base64 and round-trips to the same bytes', () async {
      final first = await service.getOrCreateHiveBoxKey();

      final stored = keystore.values['torcav_hive_box_key'];
      expect(stored, isNotNull);
      expect(base64Decode(stored!), first);

      final second = await service.getOrCreateHiveBoxKey();
      expect(second, first);
      expect(keystore.writeCount, 1, reason: 'key was regenerated');
    });

    test('two fresh services generate different keys', () async {
      final a = await service.getOrCreateHiveBoxKey();

      final other = _MockSecureStorage();
      _FakeKeystore().bind(other);
      final b = await SecureStorageService(other).getOrCreateHiveBoxKey();

      // Random.secure() collision on 256 bits is not a realistic failure.
      expect(b, isNot(a));
    });
  });

  test('deleteAll is forwarded to the platform keystore', () async {
    when(() => storage.deleteAll()).thenAnswer((_) async {});

    await service.deleteAll();

    verify(() => storage.deleteAll()).called(1);
  });
}
