import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/cellular/data/services/connection_snapshot_service.dart';
import 'package:torcav/features/cellular/domain/entities/cellular_status.dart';
import 'package:torcav/features/cellular/presentation/bloc/connection_compare_cubit.dart';
import 'package:torcav/core/network/connected_signal.dart';

class _FakeService extends Fake implements ConnectionSnapshotService {
  CellularStatus cellularResult = CellularStatus.unavailable;
  ConnectedSignal? wifiResult;

  @override
  Future<CellularStatus> cellular() async => cellularResult;

  @override
  Future<ConnectedSignal?> wifi() async => wifiResult;
}

ConnectedSignal _wifi(int rssi) => ConnectedSignal(
  ssid: 'HomeNet',
  bssid: 'AA:BB:CC:DD:EE:FF',
  rssi: rssi,
  frequency: 5180,
  linkSpeedMbps: 433,
  timestamp: DateTime(2026, 7, 7),
);

void main() {
  group('ConnectionCompareCubit', () {
    test('refresh loads both snapshots', () async {
      final service =
          _FakeService()
            ..wifiResult = _wifi(-60)
            ..cellularResult = const CellularStatus(
              operatorName: 'Turkcell',
              generation: '4G',
              dbm: -95,
              level: 2,
            );
      final cubit = ConnectionCompareCubit(service);
      await cubit.refresh();

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.wifi?.ssid, 'HomeNet');
      expect(cubit.state.cellular.operatorName, 'Turkcell');
      await cubit.close();
    });

    test('wifiLevel maps RSSI onto the 0..4 bucket scale', () async {
      final service = _FakeService();
      final cubit = ConnectionCompareCubit(service);

      for (final (rssi, expected) in [
        (-50, 4),
        (-60, 3),
        (-70, 2),
        (-80, 1),
        (-90, 0),
      ]) {
        service.wifiResult = _wifi(rssi);
        await cubit.refresh();
        expect(cubit.state.wifiLevel, expected, reason: 'rssi $rssi');
      }
      await cubit.close();
    });

    test('verdict favours the stronger link', () async {
      final service =
          _FakeService()
            ..wifiResult = _wifi(-60) // level 3
            ..cellularResult = const CellularStatus(generation: '4G', level: 1);
      final cubit = ConnectionCompareCubit(service);
      await cubit.refresh();
      expect(cubit.state.verdict, ConnectionVerdict.wifi);

      service.cellularResult = const CellularStatus(
        generation: '5G',
        level: 4,
      );
      await cubit.refresh();
      expect(cubit.state.verdict, ConnectionVerdict.cellular);
      await cubit.close();
    });

    test('verdict is bothWeak when both are at level <= 1', () async {
      final service =
          _FakeService()
            ..wifiResult = _wifi(-86) // level 0
            ..cellularResult = const CellularStatus(generation: '3G', level: 1);
      final cubit = ConnectionCompareCubit(service);
      await cubit.refresh();
      expect(cubit.state.verdict, ConnectionVerdict.bothWeak);
      await cubit.close();
    });

    test(
      'verdict falls back to the only measurable link, unknown when none',
      () async {
        final service = _FakeService(); // nothing available
        final cubit = ConnectionCompareCubit(service);
        await cubit.refresh();
        expect(cubit.state.verdict, ConnectionVerdict.unknown);

        service.cellularResult = const CellularStatus(
          generation: '4G',
          level: 3,
        );
        await cubit.refresh();
        expect(cubit.state.verdict, ConnectionVerdict.cellular);

        service.cellularResult = CellularStatus.unavailable;
        service.wifiResult = _wifi(-70);
        await cubit.refresh();
        expect(cubit.state.verdict, ConnectionVerdict.wifi);
        await cubit.close();
      },
    );
  });
}
