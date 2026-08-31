import 'package:torcav/features/diagnostics/domain/entities/network_health_score.dart';
import 'package:torcav/core/network/connected_signal.dart';
import 'package:torcav/features/monitoring/domain/entities/network_topology.dart';
import 'package:torcav/features/network_scan/domain/entities/network_device.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/security/domain/entities/security_assessment.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';
import 'package:torcav/features/wifi_scan/domain/entities/channel_rating.dart';
import 'package:torcav/features/wifi_scan/domain/entities/channel_rating_sample.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_observation.dart';

/// Realistic builders for cross-feature entities used in dashboard tests.
/// Each builder takes named optional args with realistic defaults so each test
/// only specifies the fields that actually matter for the scenario.

WifiNetwork buildWifiNetwork({
  String ssid = 'Lab AP',
  String bssid = 'AA:BB:CC:DD:EE:FF',
  int signalStrength = -55,
  int channel = 6,
  int frequency = 2437,
  SecurityType security = SecurityType.wpa2,
  String vendor = 'Cisco',
}) {
  return WifiNetwork(
    ssid: ssid,
    bssid: bssid,
    signalStrength: signalStrength,
    channel: channel,
    frequency: frequency,
    security: security,
    vendor: vendor,
  );
}

ScanSnapshot buildScanSnapshot({
  DateTime? timestamp,
  List<WifiNetwork> networks = const [],
}) {
  return ScanSnapshot(
    timestamp: timestamp ?? DateTime(2026, 5, 25, 12),
    backendUsed: 'android',
    interfaceName: 'wlan0',
    networks: networks
        .map((n) => WifiObservation.fromSingleNetwork(n))
        .toList(),
    channelStats: const [],
    bandStats: const [],
  );
}

SecurityAssessment buildSecurityAssessment({
  int score = 80,
  SecurityStatus status = SecurityStatus.moderate,
}) {
  return SecurityAssessment(
    score: score,
    status: status,
    evidenceFindings: const [],
    riskFactors: const [],
  );
}

SecurityEvent buildSecurityEvent({
  int? id,
  SecurityEventType type = SecurityEventType.rogueApSuspected,
  SecurityEventSeverity severity = SecurityEventSeverity.medium,
  String ssid = 'Lab AP',
  String bssid = 'AA:BB:CC:DD:EE:FF',
  DateTime? timestamp,
  String evidence = 'sample evidence',
  bool isRead = false,
}) {
  return SecurityEvent(
    id: id,
    type: type,
    severity: severity,
    ssid: ssid,
    bssid: bssid,
    timestamp: timestamp ?? DateTime(2026, 5, 25, 12),
    evidence: evidence,
    isRead: isRead,
  );
}

SpeedTestResult buildSpeedTestResult({
  int? id,
  DateTime? recordedAt,
  double latencyMs = 15,
  double jitterMs = 2,
  double downloadMbps = 150,
  double uploadMbps = 30,
  double packetLoss = 0,
  double loadedLatencyMs = 20,
}) {
  return SpeedTestResult(
    id: id,
    recordedAt: recordedAt ?? DateTime(2026, 5, 25, 11),
    latencyMs: latencyMs,
    jitterMs: jitterMs,
    downloadMbps: downloadMbps,
    uploadMbps: uploadMbps,
    packetLoss: packetLoss,
    loadedLatencyMs: loadedLatencyMs,
  );
}

ChannelRating buildChannelRating({
  int channel = 6,
  int frequency = 2437,
  double rating = 8.5,
  int networkCount = 3,
  ChannelQuality quality = ChannelQuality.veryGood,
  bool isDfs = false,
}) {
  return ChannelRating(
    channel: channel,
    frequency: frequency,
    rating: rating,
    networkCount: networkCount,
    quality: quality,
    isDfs: isDfs,
  );
}

ConnectedSignal buildConnectedSignal({
  String ssid = 'Lab AP',
  String bssid = 'AA:BB:CC:DD:EE:FF',
  int rssi = -55,
  int frequency = 2437,
  int linkSpeedMbps = 433,
  DateTime? timestamp,
}) {
  return ConnectedSignal(
    ssid: ssid,
    bssid: bssid,
    rssi: rssi,
    frequency: frequency,
    linkSpeedMbps: linkSpeedMbps,
    timestamp: timestamp ?? DateTime(2026, 5, 25, 12),
  );
}

NetworkDevice buildNetworkDevice({
  String ip = '192.168.1.20',
  String mac = '00:11:22:33:44:55',
  String vendor = 'Apple',
  String hostName = 'Alice Phone',
  double latency = 12,
}) {
  return NetworkDevice(
    ip: ip,
    mac: mac,
    vendor: vendor,
    hostName: hostName,
    latency: latency,
  );
}

TopologyNode buildTopologyNode({
  String id = 'node-1',
  String label = 'Test Node',
  TopologyNodeType type = TopologyNodeType.device,
  String? ip,
  String? mac,
  int? signalStrength,
  int? frequency,
  int? latencyMs,
  String? vendor,
  bool isGateway = false,
  bool isCurrentDevice = false,
}) {
  return TopologyNode(
    id: id,
    label: label,
    type: type,
    ip: ip,
    mac: mac,
    signalStrength: signalStrength,
    frequency: frequency,
    latencyMs: latencyMs,
    vendor: vendor,
    isGateway: isGateway,
    isCurrentDevice: isCurrentDevice,
  );
}

ChannelRatingSample buildChannelRatingSample({
  int channel = 6,
  int frequency = 2437,
  double rating = 7.5,
  DateTime? timestamp,
}) {
  return ChannelRatingSample(
    channel: channel,
    frequency: frequency,
    rating: rating,
    timestamp: timestamp ?? DateTime(2026, 5, 25, 12),
  );
}

NetworkHealthScore buildNetworkHealthScore({
  int totalScore = 80,
  int securityScore = 80,
  int performanceScore = 80,
  List<GamificationTask> recommendedTasks = const [],
}) {
  return NetworkHealthScore(
    totalScore: totalScore,
    securityScore: securityScore,
    performanceScore: performanceScore,
    recommendedTasks: recommendedTasks,
  );
}
