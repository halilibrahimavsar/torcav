import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dns_candidate.dart';
import '../entities/jitter_sample.dart';
import '../entities/stabilization_profile.dart';
import '../entities/stabilization_session.dart';

/// Domain-level facade for the on-device VPN tunnel that performs ping
/// stabilization. Implementations bridge to platform code through a
/// MethodChannel + EventChannel pair.
abstract class PingStabilizerRepository {
  Future<Either<Failure, bool>> isVpnPrepared();

  /// Triggers the system VPN consent dialog. Resolves once the user grants
  /// (or denies) permission.
  Future<Either<Failure, bool>> requestVpnPermission();

  Future<Either<Failure, StabilizationSession>> start(
    StabilizationProfile profile,
  );

  Future<Either<Failure, void>> stop();

  /// 1 Hz stream of raw jitter samples emitted by the native service.
  Stream<JitterSample> observeSamples();

  /// Fires when the native tunnel terminates outside of the cubit's
  /// `stop()` flow — e.g. the user tapped "Stop" in the notification or
  /// revoked the VPN from system settings.
  Stream<void> observeTunnelStopped();

  Future<Either<Failure, List<DnsCandidate>>> benchmarkDns(
    List<DnsCandidate> candidates,
  );

  Future<Either<Failure, void>> setActiveDns(DnsCandidate candidate);

  /// Pushes thresholds, the candidate resolver list and localized
  /// notification strings to the native alert engine, which evaluates the
  /// recommendation rules while the app is backgrounded or dead. Fire and
  /// forget: config failures must never break the tunnel itself.
  Future<void> pushNativeConfig({
    required double jitterThresholdMs,
    required bool autoSwitchDns,
    required List<DnsCandidate> candidates,
    required Map<String, String> notificationStrings,
  });

  Future<Either<Failure, List<StabilizationProfile>>> listProfiles();

  Future<Either<Failure, void>> upsertProfile(StabilizationProfile profile);
}
