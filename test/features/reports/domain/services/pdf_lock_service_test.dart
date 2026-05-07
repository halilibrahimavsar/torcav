import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/reports/domain/services/pdf_lock_service.dart';

void main() {
  const service = PdfLockService();

  test('round-trip lock / unlock returns the original payload', () {
    final payload = Uint8List.fromList(List.generate(1024, (i) => i % 256));
    final locked = service.lock(
      payload: payload,
      password: 'correct horse battery staple',
    );
    final unlocked = service.unlock(
      locked: locked,
      password: 'correct horse battery staple',
    );
    expect(unlocked, isNotNull);
    expect(unlocked, orderedEquals(payload));
  });

  test('wrong password fails authentication and returns null', () {
    final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
    final locked = service.lock(payload: payload, password: 'good');
    expect(service.unlock(locked: locked, password: 'bad'), isNull);
  });

  test('locked file starts with the TCV1 magic header', () {
    final locked = service.lock(
      payload: Uint8List.fromList([0]),
      password: 'x',
    );
    expect(locked.sublist(0, 4), orderedEquals([0x54, 0x43, 0x56, 0x31]));
  });

  test('files smaller than the header are rejected', () {
    expect(
      service.unlock(
        locked: Uint8List.fromList([1, 2, 3]),
        password: 'x',
      ),
      isNull,
    );
  });

  test('different passwords produce different ciphertext', () {
    final payload = Uint8List.fromList(List.filled(64, 0));
    final salt = List.filled(16, 0xAB);
    final a = service.lock(payload: payload, password: 'a', saltOverride: salt);
    final b = service.lock(payload: payload, password: 'b', saltOverride: salt);
    expect(a, isNot(orderedEquals(b)));
  });
}
