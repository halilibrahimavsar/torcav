/// Static threshold tables shared by [DiagnoseUseCase].
///
/// Kept in one place so threshold tweaks (and tests that assert against
/// them) have a single source of truth.
class DiagnosticThresholds {
  const DiagnosticThresholds();

  // RSSI: -55 dBm or stronger is treated as healthy; -75 dBm or weaker
  // saturates severity at 1.0. Severity ramps linearly between the two.
  static const int rssiHealthyDbm = -55;
  static const int rssiSevereDbm = -75;

  // Bufferbloat: induced latency = loadedLatencyMs - latencyMs.
  // Mirrors the Waveform A-F bands already in performance_page.dart.
  static const double bufferbloatHealthyMs = 30;
  static const double bufferbloatSevereMs = 200;

  // ISP-slow heuristic: only suspected when Wi-Fi PHY is comfortably above
  // the measured download (i.e. radio is not the bottleneck) AND download
  // is low in absolute terms.
  static const double ispSlowAbsoluteMbps = 25;
  static const double ispSlowPhyRatioCeiling = 0.20;

  // DNS: best benchmarked resolver latency.
  static const int dnsHealthyMs = 30;
  static const int dnsSevereMs = 250;

  // Channel: ChannelRatingEngine returns 0..10. Severity = 1 - score/10.
  // Anything below this absolute floor counts as crowded.
  static const double channelHealthyScore = 7.5;
  static const double channelSevereScore = 3.0;

  // Below this, no category is "primary" and we report `healthy`.
  static const double primaryCauseSeverityFloor = 0.4;
}
