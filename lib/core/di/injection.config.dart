// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:network_info_plus/network_info_plus.dart' as _i846;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/ai/data/services/onnx_device_classifier_service.dart'
    as _i265;
import '../../features/heatmap/data/datasources/barometer_datasource.dart'
    as _i761;
import '../../features/heatmap/data/datasources/heatmap_local_data_source.dart'
    as _i652;
import '../../features/heatmap/data/datasources/position_datasource.dart'
    as _i989;
import '../../features/heatmap/data/datasources/wall_detector_datasource.dart'
    as _i543;
import '../../features/heatmap/data/repositories/heatmap_repository_impl.dart'
    as _i531;
import '../../features/heatmap/domain/repositories/heatmap_repository.dart'
    as _i747;
import '../../features/heatmap/domain/usecases/finalize_floor_plan.dart'
    as _i960;
import '../../features/heatmap/domain/usecases/get_heatmap_sessions_usecase.dart'
    as _i716;
import '../../features/heatmap/domain/usecases/record_heatmap_point_usecase.dart'
    as _i737;
import '../../features/heatmap/presentation/bloc/heatmap_bloc.dart' as _i931;
import '../../features/monitoring/data/repositories/heatmap_repository_impl.dart'
    as _i335;
import '../../features/monitoring/data/repositories/monitoring_repository_impl.dart'
    as _i592;
import '../../features/monitoring/data/repositories/topology_repository_impl.dart'
    as _i21;
import '../../features/monitoring/domain/repositories/heatmap_repository.dart'
    as _i494;
import '../../features/monitoring/domain/repositories/monitoring_repository.dart'
    as _i365;
import '../../features/monitoring/domain/repositories/topology_repository.dart'
    as _i244;
import '../../features/monitoring/domain/services/topology_builder.dart'
    as _i892;
import '../../features/monitoring/domain/usecases/get_topology_usecase.dart'
    as _i422;
import '../../features/monitoring/domain/usecases/get_zone_averages_usecase.dart'
    as _i725;
import '../../features/monitoring/domain/usecases/log_heatmap_point_usecase.dart'
    as _i102;
import '../../features/monitoring/domain/usecases/ping_node_usecase.dart'
    as _i534;
import '../../features/monitoring/presentation/bloc/heatmap_bloc.dart' as _i573;
import '../../features/monitoring/presentation/bloc/monitoring_bloc.dart'
    as _i613;
import '../../features/monitoring/presentation/bloc/topology_bloc.dart' as _i95;
import '../../features/network_scan/data/datasources/arp_data_source.dart'
    as _i1066;
import '../../features/network_scan/data/datasources/lan_scan_history_local_data_source.dart'
    as _i190;
import '../../features/network_scan/data/datasources/mdns_data_source.dart'
    as _i165;
import '../../features/network_scan/data/datasources/upnp_data_source.dart'
    as _i119;
import '../../features/network_scan/data/repositories/network_scan_repository_impl.dart'
    as _i551;
import '../../features/network_scan/domain/repositories/network_scan_repository.dart'
    as _i1073;
import '../../features/network_scan/domain/services/new_device_detector.dart'
    as _i505;
import '../../features/network_scan/presentation/bloc/network_scan_bloc.dart'
    as _i739;
import '../../features/performance/data/repositories/speed_test_history_repository_impl.dart'
    as _i77;
import '../../features/performance/data/repositories/speed_test_repository_impl.dart'
    as _i275;
import '../../features/performance/domain/repositories/speed_test_history_repository.dart'
    as _i885;
import '../../features/performance/domain/repositories/speed_test_repository.dart'
    as _i389;
import '../../features/performance/domain/usecases/run_speed_test_usecase.dart'
    as _i510;
import '../../features/performance/presentation/bloc/performance_bloc.dart'
    as _i58;
import '../../features/reports/data/repositories/report_export_repository_impl.dart'
    as _i953;
import '../../features/reports/domain/repositories/report_export_repository.dart'
    as _i119;
import '../../features/reports/domain/usecases/generate_report_usecase.dart'
    as _i367;
import '../../features/reports/presentation/bloc/reports_bloc.dart' as _i554;
import '../../features/security/data/datasources/dns_test_data_source.dart'
    as _i991;
import '../../features/security/data/datasources/security_local_data_source.dart'
    as _i499;
import '../../features/security/data/repositories/security_repository_impl.dart'
    as _i997;
import '../../features/security/domain/repositories/security_repository.dart'
    as _i578;
import '../../features/security/domain/services/captive_portal_detector.dart'
    as _i363;
import '../../features/security/domain/usecases/analyze_network_security_usecase.dart'
    as _i87;
import '../../features/security/domain/usecases/deauth_detector.dart' as _i363;
import '../../features/security/domain/usecases/dns_leak_test_usecase.dart'
    as _i315;
import '../../features/security/domain/usecases/security_analyzer.dart'
    as _i471;
import '../../features/security/presentation/bloc/notification/notification_bloc.dart'
    as _i796;
import '../../features/security/presentation/bloc/security_bloc.dart' as _i676;
import '../../features/security/presentation/bloc/wifi_details_bloc.dart'
    as _i361;
import '../../features/settings/domain/services/app_settings_store.dart'
    as _i552;
import '../../features/wifi_scan/data/datasources/android_wifi_data_source.dart'
    as _i672;
import '../../features/wifi_scan/data/datasources/channel_rating_local_data_source.dart'
    as _i305;
import '../../features/wifi_scan/data/datasources/wifi_data_source.dart'
    as _i1012;
import '../../features/wifi_scan/data/datasources/wifi_scan_history_local_data_source.dart'
    as _i239;
import '../../features/wifi_scan/data/repositories/channel_rating_repository_impl.dart'
    as _i671;
import '../../features/wifi_scan/data/repositories/wifi_repository_impl.dart'
    as _i433;
import '../../features/wifi_scan/data/services/favorites_store.dart' as _i696;
import '../../features/wifi_scan/domain/repositories/channel_rating_repository.dart'
    as _i332;
import '../../features/wifi_scan/domain/repositories/wifi_repository.dart'
    as _i1027;
import '../../features/wifi_scan/domain/services/channel_rating_engine.dart'
    as _i969;
import '../../features/wifi_scan/domain/services/scan_session_store.dart'
    as _i797;
import '../../features/wifi_scan/domain/usecases/get_historical_best_channel.dart'
    as _i519;
import '../../features/wifi_scan/domain/usecases/scan_wifi.dart' as _i451;
import '../../features/wifi_scan/presentation/bloc/wifi_scan_bloc.dart'
    as _i968;
import '../l10n/locale_cubit.dart' as _i171;
import '../services/notification_service.dart' as _i941;
import '../storage/app_database.dart' as _i690;
import '../theme/theme_cubit.dart' as _i611;
import 'di_module.dart' as _i211;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i846.NetworkInfo>(() => appModule.networkInfo);
    gh.lazySingleton<_i941.NotificationService>(
      () => _i941.NotificationService(),
    );
    gh.lazySingleton<_i690.AppDatabase>(() => _i690.AppDatabase());
    gh.lazySingleton<_i969.ChannelRatingEngine>(
      () => _i969.ChannelRatingEngine(),
    );
    gh.lazySingleton<_i363.DeauthDetector>(() => _i363.DeauthDetector());
    gh.lazySingleton<_i471.SecurityAnalyzer>(() => _i471.SecurityAnalyzer());
    gh.lazySingleton<_i991.DnsDataSource>(() => _i991.DnsDataSource());
    gh.lazySingleton<_i1066.ArpDataSource>(() => _i1066.ArpDataSource());
    gh.lazySingleton<_i165.MdnsDataSource>(() => _i165.MdnsDataSource());
    gh.lazySingleton<_i119.UpnpDataSource>(() => _i119.UpnpDataSource());
    gh.lazySingleton<_i892.TopologyBuilder>(() => _i892.TopologyBuilder());
    gh.lazySingleton<_i960.FinalizeFloorPlan>(() => _i960.FinalizeFloorPlan());
    gh.lazySingleton<_i265.OnnxDeviceClassifierService>(
      () => _i265.OnnxDeviceClassifierService(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i1073.NetworkScanRepository>(
      () => _i551.NetworkScanRepositoryImpl(
        gh<_i1066.ArpDataSource>(),
        gh<_i165.MdnsDataSource>(),
        gh<_i119.UpnpDataSource>(),
        gh<_i265.OnnxDeviceClassifierService>(),
      ),
    );
    gh.lazySingleton<_i494.HeatmapRepository>(
      () => _i335.HeatmapRepositoryImpl(gh<_i690.AppDatabase>()),
    );
    gh.lazySingleton<_i499.SecurityLocalDataSource>(
      () => _i499.SecurityLocalDataSourceImpl(gh<_i690.AppDatabase>()),
    );
    gh.lazySingleton<_i885.SpeedTestHistoryRepository>(
      () => _i77.SpeedTestHistoryRepositoryImpl(gh<_i690.AppDatabase>()),
    );
    gh.lazySingleton<_i190.LanScanHistoryLocalDataSource>(
      () => _i190.LanScanHistoryLocalDataSourceImpl(gh<_i690.AppDatabase>()),
    );
    gh.singleton<_i171.LocaleCubit>(
      () => _i171.LocaleCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i611.ThemeCubit>(
      () => _i611.ThemeCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i696.FavoritesStore>(
      () => _i696.FavoritesStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i505.NewDeviceDetector>(
      () => _i505.NewDeviceDetector(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i552.AppSettingsStore>(
      () => _i552.AppSettingsStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i652.HeatmapLocalDataSource>(
      () => _i652.HeatmapLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i119.ReportExportRepository>(
      () => _i953.ReportExportRepositoryImpl(),
    );
    gh.lazySingleton<_i989.PositionDataSource>(
      () => _i989.PositionDataSourceImpl(),
    );
    gh.lazySingleton<_i305.ChannelRatingLocalDataSource>(
      () => _i305.ChannelRatingLocalDataSourceImpl(gh<_i690.AppDatabase>()),
    );
    gh.lazySingleton<_i102.LogHeatmapPointUseCase>(
      () => _i102.LogHeatmapPointUseCase(gh<_i494.HeatmapRepository>()),
    );
    gh.lazySingleton<_i725.GetZoneAveragesUseCase>(
      () => _i725.GetZoneAveragesUseCase(gh<_i494.HeatmapRepository>()),
    );
    gh.factory<_i573.HeatmapBloc>(
      () => _i573.HeatmapBloc(
        gh<_i725.GetZoneAveragesUseCase>(),
        gh<_i102.LogHeatmapPointUseCase>(),
      ),
    );
    gh.factory<_i739.NetworkScanBloc>(
      () => _i739.NetworkScanBloc(
        gh<_i1073.NetworkScanRepository>(),
        gh<_i505.NewDeviceDetector>(),
      ),
    );
    gh.lazySingleton<_i543.WallDetectorDataSource>(
      () => _i543.WallDetectorDataSourceImpl(),
    );
    gh.lazySingleton<_i389.SpeedTestRepository>(
      () => const _i275.SpeedTestRepositoryImpl(),
    );
    gh.lazySingleton<_i761.BarometerDataSource>(
      () => _i761.BarometerDataSourceImpl(),
    );
    gh.lazySingleton<_i1012.WifiDataSource>(
      () => _i672.AndroidWifiDataSource(),
    );
    gh.lazySingleton<_i239.WifiScanHistoryLocalDataSource>(
      () => _i239.WifiScanHistoryLocalDataSourceImpl(gh<_i690.AppDatabase>()),
    );
    gh.lazySingleton<_i363.CaptivePortalDetector>(
      () => _i363.CaptivePortalDetector(gh<_i846.NetworkInfo>()),
    );
    gh.lazySingleton<_i578.SecurityRepository>(
      () => _i997.SecurityRepositoryImpl(
        gh<_i499.SecurityLocalDataSource>(),
        gh<_i941.NotificationService>(),
        gh<_i363.DeauthDetector>(),
        gh<_i471.SecurityAnalyzer>(),
        gh<_i991.DnsDataSource>(),
      ),
    );
    gh.factory<_i361.WifiDetailsBloc>(
      () => _i361.WifiDetailsBloc(
        gh<_i471.SecurityAnalyzer>(),
        gh<_i578.SecurityRepository>(),
      ),
    );
    gh.lazySingleton<_i367.GenerateReportUseCase>(
      () => _i367.GenerateReportUseCase(gh<_i119.ReportExportRepository>()),
    );
    gh.lazySingleton<_i1027.WifiRepository>(
      () => _i433.WifiRepositoryImpl(gh<_i1012.WifiDataSource>()),
    );
    gh.factory<_i554.ReportsBloc>(
      () => _i554.ReportsBloc(gh<_i367.GenerateReportUseCase>()),
    );
    gh.lazySingleton<_i747.HeatmapRepository>(
      () => _i531.HeatmapRepositoryImpl(gh<_i652.HeatmapLocalDataSource>()),
    );
    gh.lazySingleton<_i797.ScanSessionStore>(
      () => _i797.ScanSessionStore(gh<_i239.WifiScanHistoryLocalDataSource>()),
    );
    gh.lazySingleton<_i315.DnsLeakTestUsecase>(
      () => _i315.DnsLeakTestUsecase(gh<_i991.DnsDataSource>()),
    );
    gh.lazySingleton<_i365.MonitoringRepository>(
      () => _i592.MonitoringRepositoryImpl(gh<_i1027.WifiRepository>()),
    );
    gh.lazySingleton<_i244.TopologyRepository>(
      () => _i21.TopologyRepositoryImpl(
        gh<_i846.NetworkInfo>(),
        gh<_i797.ScanSessionStore>(),
        gh<_i1073.NetworkScanRepository>(),
        gh<_i892.TopologyBuilder>(),
      ),
    );
    gh.lazySingleton<_i510.RunSpeedTestUseCase>(
      () => _i510.RunSpeedTestUseCase(gh<_i389.SpeedTestRepository>()),
    );
    gh.lazySingleton<_i332.ChannelRatingRepository>(
      () => _i671.ChannelRatingRepositoryImpl(
        gh<_i305.ChannelRatingLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i451.ScanWifi>(
      () => _i451.ScanWifi(gh<_i1027.WifiRepository>()),
    );
    gh.factory<_i58.PerformanceBloc>(
      () => _i58.PerformanceBloc(
        gh<_i510.RunSpeedTestUseCase>(),
        gh<_i885.SpeedTestHistoryRepository>(),
      ),
    );
    gh.lazySingleton<_i519.GetBestHistoricalChannel>(
      () => _i519.GetBestHistoricalChannel(gh<_i332.ChannelRatingRepository>()),
    );
    gh.lazySingleton<_i87.AnalyzeNetworkSecurityUseCase>(
      () => _i87.AnalyzeNetworkSecurityUseCase(gh<_i578.SecurityRepository>()),
    );
    gh.factory<_i796.NotificationBloc>(
      () => _i796.NotificationBloc(gh<_i578.SecurityRepository>()),
    );
    gh.factory<_i968.WifiScanBloc>(
      () =>
          _i968.WifiScanBloc(gh<_i451.ScanWifi>(), gh<_i696.FavoritesStore>()),
    );
    gh.factory<_i676.SecurityBloc>(
      () => _i676.SecurityBloc(
        gh<_i578.SecurityRepository>(),
        gh<_i87.AnalyzeNetworkSecurityUseCase>(),
        gh<_i797.ScanSessionStore>(),
        gh<_i471.SecurityAnalyzer>(),
        gh<_i315.DnsLeakTestUsecase>(),
      ),
    );
    gh.lazySingleton<_i737.RecordHeatmapPointUsecase>(
      () => _i737.RecordHeatmapPointUsecase(gh<_i747.HeatmapRepository>()),
    );
    gh.lazySingleton<_i716.GetHeatmapSessionsUsecase>(
      () => _i716.GetHeatmapSessionsUsecase(gh<_i747.HeatmapRepository>()),
    );
    gh.lazySingleton<_i422.GetTopologyUseCase>(
      () => _i422.GetTopologyUseCase(gh<_i244.TopologyRepository>()),
    );
    gh.lazySingleton<_i534.PingNodeUseCase>(
      () => _i534.PingNodeUseCase(gh<_i244.TopologyRepository>()),
    );
    gh.factory<_i931.HeatmapBloc>(
      () => _i931.HeatmapBloc(
        gh<_i716.GetHeatmapSessionsUsecase>(),
        gh<_i747.HeatmapRepository>(),
        gh<_i543.WallDetectorDataSource>(),
        gh<_i989.PositionDataSource>(),
        gh<_i451.ScanWifi>(),
        gh<_i846.NetworkInfo>(),
        gh<_i761.BarometerDataSource>(),
        gh<_i960.FinalizeFloorPlan>(),
      ),
    );
    gh.factory<_i613.MonitoringBloc>(
      () => _i613.MonitoringBloc(
        gh<_i365.MonitoringRepository>(),
        gh<_i969.ChannelRatingEngine>(),
        gh<_i797.ScanSessionStore>(),
        gh<_i332.ChannelRatingRepository>(),
        gh<_i519.GetBestHistoricalChannel>(),
      ),
    );
    gh.factory<_i95.TopologyBloc>(
      () => _i95.TopologyBloc(
        gh<_i422.GetTopologyUseCase>(),
        gh<_i534.PingNodeUseCase>(),
        gh<_i244.TopologyRepository>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i211.AppModule {}
