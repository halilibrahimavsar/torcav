import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/breach_check_result.dart';

/// Queries the Have I Been Pwned Pwned Passwords range API.
///
/// Privacy model (k-anonymity): the password is SHA-1 hashed on-device, and
/// only the first 5 characters of that hash are sent to the API. The server
/// returns every hash suffix sharing that prefix; the match is resolved
/// locally. The raw password and full hash never leave the device, and the
/// password is never logged or persisted.
///
/// No API key is required for this endpoint.
@LazySingleton()
class BreachDataSource {
  static const _host = 'api.pwnedpasswords.com';

  /// Checks [password] against the breach corpus. Throws on network failure.
  Future<BreachCheckResult> checkPassword(String password) async {
    // SHA-1 the password on-device; HIBP keys the corpus on uppercase SHA-1.
    final digest = sha1.convert(password.codeUnits).toString().toUpperCase();
    final prefix = digest.substring(0, 5);
    final suffix = digest.substring(5);

    final client =
        HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(
        Uri.https(_host, '/range/$prefix'),
      );
      // Opt into the padded response so the prefix's result-count is not
      // observable from the response size.
      request.headers.set('Add-Padding', 'true');
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != 200) {
        throw HttpException(
          'Pwned Passwords API returned ${response.statusCode}',
        );
      }
      final body =
          await response.transform(const SystemEncoding().decoder).join();

      final exposureCount = matchExposureCount(body, suffix);

      return BreachCheckResult(
        isCompromised: exposureCount > 0,
        exposureCount: exposureCount,
        checkedAt: DateTime.now(),
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Resolves the breach exposure count for [hashSuffix] from a Pwned
  /// Passwords range [responseBody] (lines of `SUFFIX:COUNT`). Returns 0
  /// when the suffix is absent. Case-insensitive on the suffix.
  static int matchExposureCount(String responseBody, String hashSuffix) {
    final target = hashSuffix.toUpperCase();
    for (final line in responseBody.split('\n')) {
      final parts = line.trim().split(':');
      if (parts.length != 2) continue;
      if (parts[0].toUpperCase() == target) {
        return int.tryParse(parts[1].trim()) ?? 0;
      }
    }
    return 0;
  }
}
