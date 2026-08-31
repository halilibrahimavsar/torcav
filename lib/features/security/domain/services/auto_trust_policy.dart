import 'package:injectable/injectable.dart';

import '../../../wifi_scan/domain/entities/wifi_network.dart';

/// Decides when a network the user keeps connecting to has earned automatic
/// trust — the baseline against which later drift is judged.
///
/// Split from `SecurityRepositoryImpl` so the rule can be read and tested
/// without a database. The repository still owns the persistence; this owns
/// only the judgement.
@lazySingleton
class AutoTrustPolicy {
  const AutoTrustPolicy();

  /// Connections required before a network is trusted automatically.
  ///
  /// Three sightings, not one: a single connection could be an evil twin the
  /// user joined by mistake, and trusting it would make the impostor the
  /// baseline that every later comparison is measured against.
  static const int requiredSightings = 3;

  /// Whether a network seen [seenCount] times should be promoted to trusted.
  ///
  /// Open networks never qualify however often they are used. Trust here
  /// means "this fingerprint is the reference"; on an open network anyone can
  /// reproduce that fingerprint, so the reference would be worthless.
  bool shouldTrust({required int seenCount, required SecurityType security}) {
    if (security == SecurityType.open) return false;
    // seenCount is the count *before* this sighting is recorded.
    return seenCount >= requiredSightings - 1;
  }
}
