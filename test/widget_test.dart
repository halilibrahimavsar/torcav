import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torcav/core/di/injection.dart';
import 'package:torcav/main.dart';
import 'package:remote_auth_module/remote_auth_module.dart';
import 'package:bloc_test/bloc_test.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockNetworkInfo mockNetworkInfo;
  late MockAuthBloc mockAuthBloc;

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
    mockAuthBloc = MockAuthBloc();
    final testUser = const AuthUser(
      id: 'test',
      email: 'test@example.com',
      isEmailVerified: true,
      isAnonymous: false,
      providerIds: [],
    );
    when(() => mockAuthBloc.state).thenReturn(AuthenticatedState(testUser));
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

    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    getIt.registerSingleton<AuthBloc>(mockAuthBloc);

    await tester.pumpWidget(const TorcavApp());

    // Multiple pumps to allow for async initialization
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
  });
}
