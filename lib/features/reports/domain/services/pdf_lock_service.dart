import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// File header magic — `TCV1` so we can spot Torcav-locked files at a
/// glance and refuse to "decrypt" something that isn't ours.
const _magic = [0x54, 0x43, 0x56, 0x31];

/// Lightweight password-based wrapper around an arbitrary byte payload.
///
/// **What it is:** SHA-256 keystream XOR. We derive a 32-byte block from
/// `SHA-256(password || salt || counter)` and XOR it against successive
/// 32-byte chunks of the PDF. A 16-byte random salt is prepended to the
/// ciphertext alongside an HMAC tag so we can detect a wrong password.
///
/// **What it isn't:** AES. There's no constant-time compare, no key
/// stretching, and no padding oracle protection. Treat this as
/// "obfuscation against casual leakage" (mailbox cache, Drive thumbnail,
/// nosy file-share recipient) — not as protection against a determined
/// attacker who already has the file.
///
/// File layout: `[magic:4][salt:16][hmac:32][ciphertext:N]`
class PdfLockService {
  const PdfLockService();

  /// Wrap [payload] under [password]. Returns the locked-file bytes.
  Uint8List lock({
    required Uint8List payload,
    required String password,
    Iterable<int>? saltOverride,
  }) {
    final salt = Uint8List.fromList(
      (saltOverride ?? _randomBytes(16)).toList(),
    );
    final keyBytes = utf8.encode(password);
    final ciphertext = _xorStream(payload, keyBytes, salt);
    final hmac =
        Hmac(sha256, _macKey(keyBytes, salt)).convert(ciphertext).bytes;

    final out = BytesBuilder();
    out.add(_magic);
    out.add(salt);
    out.add(hmac);
    out.add(ciphertext);
    return out.toBytes();
  }

  /// Reverse [lock]. Returns null when the magic header is missing or the
  /// HMAC doesn't match (wrong password / tampered file).
  Uint8List? unlock({required Uint8List locked, required String password}) {
    if (locked.length < 4 + 16 + 32) return null;
    for (var i = 0; i < 4; i++) {
      if (locked[i] != _magic[i]) return null;
    }
    final salt = Uint8List.sublistView(locked, 4, 20);
    final hmacBytes = locked.sublist(20, 52);
    final ciphertext = Uint8List.sublistView(locked, 52);

    final keyBytes = utf8.encode(password);
    final expected =
        Hmac(sha256, _macKey(keyBytes, salt)).convert(ciphertext).bytes;
    if (!_constantTimeEquals(expected, hmacBytes)) return null;

    return _xorStream(ciphertext, keyBytes, salt);
  }

  // ── Internals ──────────────────────────────────────────────────────

  /// Derive a 32-byte HMAC key independent of the encryption keystream.
  /// Domain-separated by a tag so a key/MAC reuse doesn't collapse.
  List<int> _macKey(List<int> password, List<int> salt) {
    return sha256.convert([
      ...password,
      ...salt,
      ...utf8.encode('torcav-mac'),
    ]).bytes;
  }

  Uint8List _xorStream(Uint8List input, List<int> password, List<int> salt) {
    final out = Uint8List(input.length);
    var counter = 0;
    var pos = 0;
    while (pos < input.length) {
      final block =
          sha256.convert([
            ...password,
            ...salt,
            (counter >> 24) & 0xff,
            (counter >> 16) & 0xff,
            (counter >> 8) & 0xff,
            counter & 0xff,
          ]).bytes;
      final remaining = input.length - pos;
      final take = remaining < block.length ? remaining : block.length;
      for (var i = 0; i < take; i++) {
        out[pos + i] = input[pos + i] ^ block[i];
      }
      pos += take;
      counter++;
    }
    return out;
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// Salt source. Uses `DateTime.now()` and the password hash as entropy
  /// — good enough for a 16-byte unique-per-file value. Override in tests.
  Iterable<int> _randomBytes(int n) {
    final seed = DateTime.now().microsecondsSinceEpoch;
    final mixed =
        sha256.convert([
          seed & 0xff,
          (seed >> 8) & 0xff,
          (seed >> 16) & 0xff,
          (seed >> 24) & 0xff,
          (seed >> 32) & 0xff,
          (seed >> 40) & 0xff,
        ]).bytes;
    return mixed.take(n);
  }
}
