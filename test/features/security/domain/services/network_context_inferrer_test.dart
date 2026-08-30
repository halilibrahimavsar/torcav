import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/network/network_context_type.dart';
import 'package:torcav/features/security/domain/entities/network_fingerprint.dart';
import 'package:torcav/features/security/domain/entities/trusted_network_profile.dart';
import 'package:torcav/features/security/domain/services/network_context_inferrer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  const inferrer = NetworkContextInferrer();

  WifiNetwork wifi({
    String ssid = 'Home',
    SecurityType security = SecurityType.wpa2,
  }) => WifiNetwork(
    ssid: ssid,
    bssid: '00:11:22:33:44:55',
    signalStrength: -50,
    channel: 1,
    frequency: 2412,
    security: security,
    vendor: '',
  );

  test('trusted profile takes precedence — context is home', () {
    final trusted = TrustedNetworkProfile(
      ssid: 'Free WiFi',
      bssid: '00:11:22:33:44:55',
      gateway: '192.168.1.1',
      fingerprint: NetworkFingerprint.fromWifiNetwork(
        wifi(ssid: 'Free WiFi', security: SecurityType.open),
      ),
      trustedAt: DateTime.now(),
      lastConfirmedAt: DateTime.now(),
    );

    final result = inferrer.infer(
      wifi(ssid: 'Free WiFi', security: SecurityType.open),
      trustedProfile: trusted,
    );

    expect(result, NetworkContextType.home);
  });

  test('open network without trust → public', () {
    final result = inferrer.infer(wifi(security: SecurityType.open));
    expect(result, NetworkContextType.public);
  });

  test('lure SSID without trust → public', () {
    final result = inferrer.infer(wifi(ssid: 'Airport WiFi'));
    expect(result, NetworkContextType.public);
  });

  test('encrypted unknown network → unknown', () {
    final result = inferrer.infer(wifi(ssid: 'NeighbourNet'));
    expect(result, NetworkContextType.unknown);
  });
}
