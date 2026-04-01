import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/monitoring/domain/entities/network_topology.dart';
import 'package:torcav/features/monitoring/domain/services/topology_builder.dart';
import 'package:torcav/features/monitoring/presentation/pages/topology_page.dart';
import 'package:torcav/features/monitoring/presentation/widgets/topology_view_data.dart';
import 'package:torcav/features/network_scan/domain/entities/network_device.dart';
import 'package:torcav/features/network_scan/domain/repositories/network_scan_repository.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_observation.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'package:torcav/core/l10n/app_localizations.dart';

import 'package:vector_math/vector_math_64.dart' hide Colors;

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockNetworkScanRepository extends Mock implements NetworkScanRepository {}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('tapping a mobile node opens the inspector', (tester) async {
    final networkInfo = MockNetworkInfo();
    final networkScanRepository = MockNetworkScanRepository();

    when(() => networkInfo.getWifiIP()).thenAnswer((_) async => '192.168.1.10');
    when(
      () => networkInfo.getWifiGatewayIP(),
    ).thenAnswer((_) async => '192.168.1.1');
    when(() => networkInfo.getWifiName()).thenAnswer((_) async => '"Lab AP"');
    when(
      () => networkInfo.getWifiBSSID(),
    ).thenAnswer((_) async => 'AA:BB:CC:DD:EE:FF');
    when(() => networkScanRepository.scanNetwork(any())).thenAnswer(
      (_) async => Right<Failure, List<NetworkDevice>>([_mobileNode]),
    );

    await _configureDependencies(networkInfo, networkScanRepository);
    getIt<ScanSessionStore>().add(_snapshot);

    await tester.pumpWidget(_buildTestApp(const TopologyPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    final topology = getIt<TopologyBuilder>().build(
      wifiNetworks: _snapshot.toLegacyNetworks(),
      lanDevices: const [_mobileNode],
      currentIp: '192.168.1.10',
      gatewayIp: '192.168.1.1',
      connectedSsid: 'Lab AP',
      connectedBssid: 'AA:BB:CC:DD:EE:FF',
    );

    final canvas = find.descendant(
      of: find.byType(InteractiveViewer),
      matching: find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onTapUp != null,
      ),
    );
    final size = tester.getSize(canvas);
    final topLeft = tester.getTopLeft(canvas);
    final tapOffset = _projectedOffset(
      topology: topology,
      size: size,
      nodeId: 'device_192.168.1.20',
    );

    await tester.tapAt(topLeft + tapOffset);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('ALICE PHONE'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });
}

Future<void> _configureDependencies(
  NetworkInfo networkInfo,
  NetworkScanRepository networkScanRepository,
) async {
  SharedPreferences.setMockInitialValues({});
  await getIt.reset();
  await configureDependencies();

  getIt.unregister<NetworkInfo>();
  getIt.registerSingleton<NetworkInfo>(networkInfo);

  getIt.unregister<NetworkScanRepository>();
  getIt.registerSingleton<NetworkScanRepository>(networkScanRepository);
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

Offset _projectedOffset({
  required NetworkTopology topology,
  required Size size,
  required String nodeId,
}) {
  final center = Offset(size.width / 2, size.height / 2);
  final positions = TopologyViewData.calculatePositions(
    topology,
    size,
    forceView: false,
  );
  final base = positions[nodeId]!;
  final matrix =
      Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.5);
  final relative = base - center;
  final projected = matrix.transform3(Vector3(relative.dx, relative.dy, 0));

  return Offset(projected.x + center.dx, projected.y + center.dy);
}

const _mobileNode = NetworkDevice(
  ip: '192.168.1.20',
  mac: '00:11:22:33:44:55',
  vendor: 'Apple',
  hostName: 'Alice Phone',
  latency: 12,
);

final _snapshot = ScanSnapshot(
  timestamp: DateTime(2026, 4, 1, 12, 30),
  backendUsed: 'android',
  interfaceName: 'wlan0',
  networks: [
    WifiObservation.fromSingleNetwork(
      WifiNetwork(
        ssid: 'Lab AP',
        bssid: 'AA:BB:CC:DD:EE:FF',
        signalStrength: -45,
        channel: 6,
        frequency: 2437,
        security: SecurityType.wpa2,
        vendor: 'Cisco',
      ),
    ),
  ],
  channelStats: const [],
  bandStats: const [],
);
