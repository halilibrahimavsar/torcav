import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torcav/core/di/injection.dart';
import 'package:torcav/features/app_shell/presentation/pages/profile_hub_page.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_observation.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/core/theme/theme_cubit.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('renders factual profile data without placeholder values', (
    tester,
  ) async {
    final networkInfo = MockNetworkInfo();
    when(
      () => networkInfo.getWifiName(),
    ).thenAnswer((_) async => '"Test SSID"');
    when(() => networkInfo.getWifiIP()).thenAnswer((_) async => '192.168.1.10');
    when(
      () => networkInfo.getWifiGatewayIP(),
    ).thenAnswer((_) async => '192.168.1.1');

    await _configureDependencies(networkInfo);
    getIt<ScanSessionStore>().add(_snapshot());

    await tester.pumpWidget(_buildTestApp(const ProfileHubPage()));
    await tester.pumpAndSettle();

    expect(find.text('Test SSID'), findsOneWidget);
    expect(find.text('192.168.1.10'), findsOneWidget);
    expect(find.text('192.168.1.1'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Networks (1)'), findsOneWidget);
    expect(find.text('ANDROID'), findsOneWidget);

    expect(find.text('OPERATOR_01'), findsNothing);
    expect(find.text('TR-9982-CX'), findsNothing);
    expect(find.text('ENTERPRISE_ELITE'), findsNothing);
    expect(find.text('AES-256-GCM'), findsNothing);
    expect(find.text('98.2%'), findsNothing);
  });

  testWidgets('renders empty factual state when runtime data is unavailable', (
    tester,
  ) async {
    final networkInfo = MockNetworkInfo();
    when(() => networkInfo.getWifiName()).thenAnswer((_) async => null);
    when(() => networkInfo.getWifiIP()).thenAnswer((_) async => null);
    when(() => networkInfo.getWifiGatewayIP()).thenAnswer((_) async => null);

    await _configureDependencies(networkInfo);

    await tester.pumpWidget(_buildTestApp(const ProfileHubPage()));
    await tester.pumpAndSettle();

    expect(
      find.text('No scan snapshot is available yet. Run a Wi-Fi scan first.'),
      findsOneWidget,
    );
    expect(find.text('—'), findsAtLeastNWidgets(3));
  });
}

Future<void> _configureDependencies(NetworkInfo networkInfo) async {
  SharedPreferences.setMockInitialValues({});
  await getIt.reset();
  await configureDependencies();

  getIt.unregister<NetworkInfo>();
  getIt.registerSingleton<NetworkInfo>(networkInfo);
}

Widget _buildTestApp(Widget child) {
  return BlocProvider<ThemeCubit>.value(
    value: getIt<ThemeCubit>(),
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

ScanSnapshot _snapshot() {
  const network = WifiNetwork(
    ssid: 'Test SSID',
    bssid: 'AA:BB:CC:DD:EE:FF',
    signalStrength: -48,
    channel: 6,
    frequency: 2437,
    security: SecurityType.wpa2,
    vendor: 'Cisco',
  );

  return ScanSnapshot(
    timestamp: DateTime(2026, 4, 1, 12, 30),
    backendUsed: 'android',
    interfaceName: 'wlan0',
    networks: [WifiObservation.fromSingleNetwork(network)],
    channelStats: const [],
    bandStats: const [],
  );
}
