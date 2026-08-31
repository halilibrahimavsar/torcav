import '../entities/host_scan_result.dart';
import '../entities/lan_scan_session.dart';

/// Persisted history of LAN discovery runs.
///
/// The interface lives in `domain` and the SQLite implementation in `data`,
/// so a consumer outside this feature depends on the contract rather than on
/// how the rows are stored. It was declared alongside its implementation
/// before, which made every reader — the settings screen, the health report,
/// the export service — a `presentation → data` violation.
abstract class LanScanHistoryRepository {
  Future<void> saveSession({
    required String target,
    required String profile,
    required List<HostScanResult> hosts,
  });

  /// The most recent run, or null when the user has never scanned.
  Future<LanScanSession?> getLatestSession();

  Future<void> deleteAllSessions();
}
