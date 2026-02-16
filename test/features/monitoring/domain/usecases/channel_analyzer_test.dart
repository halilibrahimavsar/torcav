import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/monitoring/domain/usecases/channel_analyzer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  late ChannelAnalyzer analyzer;

  setUp(() {
    analyzer = ChannelAnalyzer();
  });

  const tNetwork1 = WifiNetwork(
    ssid: 'Net1',
    bssid: '1',
    signalStrength: -50,
    channel: 6,
    frequency: 2437,
    security: SecurityType.wpa2,
  );

  const tNetwork2 = WifiNetwork(
    ssid: 'Net2',
    bssid: '2',
    signalStrength: -60,
    channel: 6,
    frequency: 2437,
    security: SecurityType.wpa2,
  );

  const tNetwork3 = WifiNetwork(
    ssid: 'Net3',
    bssid: '3',
    signalStrength: -70,
    channel: 5,
    frequency: 2432,
    security: SecurityType.wpa2,
  );

  test('should rate overlapping channels lower', () {
    final networks = [tNetwork1, tNetwork2, tNetwork3];
    final ratings = analyzer.analyzeChannels(networks);

    // Channel 6 has 2 networks directly + 1 adjacent (result: heavy penalty)
    final rating6 = ratings.firstWhere((r) => r.channel == 6);
    expect(rating6.networkCount, 2);
    expect(rating6.rating, lessThan(10.0));

    // Channel 1 should have no interference from these
    final rating1 = ratings.firstWhere((r) => r.channel == 1);
    expect(rating1.networkCount, 0);
    expect(rating1.rating, 10.0);
  });

  test('should analyze 5GHz channels', () {
    final tNetwork5GHz = const WifiNetwork(
      ssid: 'Net5G',
      bssid: '4',
      signalStrength: -50,
      channel: 36,
      frequency: 5180,
      security: SecurityType.wpa2,
    );

    final ratings = analyzer.analyzeChannels([tNetwork5GHz]);

    final rating36 = ratings.firstWhere((r) => r.channel == 36);
    expect(rating36.networkCount, 1);
    expect(rating36.rating, lessThan(10.0));

    final rating40 = ratings.firstWhere((r) => r.channel == 40);
    expect(rating40.networkCount, 0);
    expect(rating40.rating, 10.0);
  });
}
