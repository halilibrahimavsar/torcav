import 'dart:io';

import 'package:injectable/injectable.dart';

/// The two raw network probes the security domain needs.
///
/// They live here rather than in the use cases so `security/domain` contains
/// no `dart:io` at all — a property a grep can check, and the reason those
/// use cases were untestable before.
@lazySingleton
class NetworkProbeDataSource {
  const NetworkProbeDataSource();

  /// Resolves [host] to its addresses.
  ///
  /// Three outcomes, kept distinct because the DNS checks depend on telling
  /// them apart:
  ///  * a non-empty list — the name resolved;
  ///  * an empty list — the name genuinely does not resolve (NXDOMAIN),
  ///    which for the hijack probe is the *expected* answer, not an error;
  ///  * `null` — the lookup could not run at all (offline, resolver
  ///    unreachable), so we learned nothing.
  ///
  /// Returning strings rather than `InternetAddress` keeps `dart:io` out of
  /// the domain layer entirely.
  Future<List<String>?> lookup(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.map((a) => a.address).toList();
    } on SocketException {
      return const [];
    } catch (_) {
      return null;
    }
  }

  /// Fetches the connectivity-check endpoint and returns its HTTP status,
  /// or null when the request could not complete at all.
  ///
  /// `connectivitycheck.gstatic.com` is one of the four endpoints CLAUDE.md
  /// permits; a 204 means the network is not intercepting traffic.
  Future<int?> connectivityStatus() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await client.getUrl(
        Uri.parse('http://connectivitycheck.gstatic.com/generate_204'),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      await response.drain<void>();
      return response.statusCode;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }
}
