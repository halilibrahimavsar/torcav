import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'package:torcav/features/network_scan/domain/repositories/lan_scan_history_repository.dart';
import '../../../network_scan/domain/entities/host_scan_result.dart';
import '../../../performance/domain/repositories/speed_test_history_repository.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../domain/entities/home_health_report.dart';
import '../../domain/services/home_health_report_builder.dart';

class HomeHealthState extends Equatable {
  const HomeHealthState({this.loading = false, this.report});

  final bool loading;

  /// Null until a scan exists to build from — the report summarises what the
  /// other tools measured, it does not measure anything itself.
  final HomeHealthReport? report;

  HomeHealthState copyWith({bool? loading, HomeHealthReport? report}) =>
      HomeHealthState(
        loading: loading ?? this.loading,
        report: report ?? this.report,
      );

  @override
  List<Object?> get props => [loading, report];
}

/// Gathers the four signals the home-health report scores and hands them to
/// [HomeHealthReportBuilder].
///
/// Every input is optional by design: the builder scores a missing signal as
/// neutral rather than refusing to produce a report, so a user who has only
/// run a Wi-Fi scan still sees something useful.
@injectable
class HomeHealthCubit extends Cubit<HomeHealthState> {
  HomeHealthCubit(
    this._builder,
    this._scanStore,
    this._speedRepository,
    this._lanHistory,
    this._networkInfo,
  ) : super(const HomeHealthState());

  final HomeHealthReportBuilder _builder;
  final ScanSessionStore _scanStore;
  final SpeedTestHistoryRepository _speedRepository;
  final LanScanHistoryRepository _lanHistory;
  final NetworkInfo _networkInfo;

  Future<void> load({int? securityScore}) async {
    emit(state.copyWith(loading: true));

    final snapshot = _scanStore.latest;
    if (snapshot == null || snapshot.networks.isEmpty) {
      emit(const HomeHealthState());
      return;
    }

    final networks =
        snapshot.networks.map((n) => n.toWifiNetwork()).toList();
    final connected = await _connectedNetwork(networks);

    final speedResults = await _speedRepository.getRecent(limit: 1);
    final lanHosts = await _latestLanHosts();

    if (isClosed) return;
    emit(
      HomeHealthState(
        report: _builder.build(
          connectedSsid: connected?.ssid ?? '',
          connectedNetwork: connected,
          speedTest: speedResults.isEmpty ? null : speedResults.first,
          securityScore: securityScore,
          lanHosts: lanHosts,
        ),
      ),
    );
  }

  Future<WifiNetwork?> _connectedNetwork(List<WifiNetwork> networks) async {
    try {
      final bssid = (await _networkInfo.getWifiBSSID())?.toUpperCase();
      if (bssid != null && bssid.isNotEmpty) {
        for (final n in networks) {
          if (n.bssid.toUpperCase() == bssid) return n;
        }
      }
    } catch (_) {
      // Location permission denied or platform error — fall through to the
      // strongest visible network, which is the connected one often enough
      // to keep the report useful.
    }
    return networks.reduce(
      (a, b) => a.signalStrength >= b.signalStrength ? a : b,
    );
  }

  Future<List<HostScanResult>> _latestLanHosts() async {
    try {
      final session = await _lanHistory.getLatestSession();
      return session?.hosts ?? const [];
    } catch (_) {
      return const [];
    }
  }
}
