import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torcav/core/di/injection.dart';
import 'package:torcav/main.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    when(
      () => mockNetworkInfo.getWifiName(),
    ).thenAnswer((_) async => 'Test SSID');
    when(
      () => mockNetworkInfo.getWifiIP(),
    ).thenAnswer((_) async => '192.168.1.10');
    when(
      () => mockNetworkInfo.getWifiGatewayIP(),
    ).thenAnswer((_) async => '192.168.1.1');
  });

  testWidgets('app shell renders dashboard tab', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});

    // Reset and reconfigure GetIt for test
    await getIt.reset();
    await configureDependencies();

    // Override with mock
    if (getIt.isRegistered<NetworkInfo>()) {
      getIt.unregister<NetworkInfo>();
    }
    getIt.registerSingleton<NetworkInfo>(mockNetworkInfo);

    await tester.pumpWidget(const TorcavApp());

    // Multiple pumps to allow for async initialization
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
  });
}
