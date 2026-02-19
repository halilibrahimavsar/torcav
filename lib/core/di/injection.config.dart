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

import '../../features/monitoring/data/repositories/heatmap_repository_impl.dart'
    as _i335;
import '../../features/monitoring/data/repositories/monitoring_repository_impl.dart'
    as _i592;
import '../../features/monitoring/data/repositories/speed_test_repository_impl.dart'
    as _i528;
import '../../features/monitoring/data/services/deauth_detection_service.dart'
    as _i328;
import '../../features/monitoring/domain/repositories/heatmap_repository.dart'
    as _i494;
import '../../features/monitoring/domain/repositories/monitoring_repository.dart'
    as _i365;
import '../../features/monitoring/domain/repositories/speed_test_repository.dart'
    as _i890;
import '../../features/monitoring/domain/services/topology_builder.dart'
    as _i892;
import '../../features/monitoring/domain/usecases/get_zone_averages_usecase.dart'
    as _i725;
import '../../features/monitoring/domain/usecases/log_heatmap_point_usecase.dart'
    as _i102;
import '../../features/monitoring/domain/usecases/run_speed_test_usecase.dart'
    as _i1024;
import '../../features/monitoring/presentation/bloc/heatmap_bloc.dart' as _i573;
import '../../features/monitoring/presentation/bloc/monitoring_bloc.dart'
    as _i613;
import '../../features/monitoring/presentation/bloc/monitoring_hub_bloc.dart'
    as _i374;
import '../../features/network_scan/data/datasources/arp_data_source.dart'
    as _i1066;
import '../../features/network_scan/data/datasources/nmap_data_source.dart'
    as _i424;
import '../../features/network_scan/data/repositories/network_scan_repository_impl.dart'
    as _i551;
import '../../features/network_scan/domain/repositories/network_scan_repository.dart'
    as _i1073;
import '../../features/network_scan/presentation/bloc/network_scan_bloc.dart'
    as _i739;
import '../../features/reports/data/repositories/report_export_repository_impl.dart'
    as _i953;
import '../../features/reports/domain/repositories/report_export_repository.dart'
    as _i119;
import '../../features/reports/domain/usecases/generate_report_usecase.dart'
    as _i367;
import '../../features/reports/presentation/bloc/reports_bloc.dart' as _i554;
import '../../features/security/data/datasources/security_local_data_source.dart'
    as _i499;
import '../../features/security/data/repositories/active_security_repository_impl.dart'
    as _i586;
import '../../features/security/data/repositories/security_repository_impl.dart'
    as _i997;
import '../../features/security/domain/repositories/active_security_repository.dart'
    as _i508;
import '../../features/security/domain/repositories/security_repository.dart'
    as _i578;
import '../../features/security/domain/services/consent_guard.dart' as _i156;
import '../../features/security/domain/services/security_event_store.dart'
    as _i1048;
import '../../features/security/domain/usecases/analyze_network_security_usecase.dart'
    as _i87;
import '../../features/security/domain/usecases/capture_handshake_usecase.dart'
    as _i467;
import '../../features/security/domain/usecases/run_active_defense_check_usecase.dart'
    as _i809;
import '../../features/security/domain/usecases/security_analyzer.dart'
    as _i471;
import '../../features/security/presentation/bloc/security_bloc.dart' as _i676;
import '../../features/security/presentation/bloc/wifi_details_bloc.dart'
    as _i361;
import '../../features/settings/domain/services/app_settings_store.dart'
    as _i552;
import '../../features/wifi_scan/data/datasources/android_wifi_data_source.dart'
    as _i672;
import '../../features/wifi_scan/data/datasources/channel_rating_local_data_source.dart'
    as _i305;
import '../../features/wifi_scan/data/datasources/linux_wifi_data_source.dart'
    as _i653;
import '../../features/wifi_scan/data/datasources/scan_persistence_data_source.dart'
    as _i790;
import '../../features/wifi_scan/data/datasources/wifi_data_source.dart'
    as _i1012;
import '../../features/wifi_scan/data/repositories/channel_rating_repository_impl.dart'
    as _i671;
import '../../features/wifi_scan/data/repositories/wifi_repository_impl.dart'
    as _i433;
import '../../features/wifi_scan/domain/repositories/channel_rating_repository.dart'
    as _i332;
import '../../features/wifi_scan/domain/repositories/wifi_repository.dart'
    as _i1027;
import '../../features/wifi_scan/domain/services/channel_rating_engine.dart'
    as _i969;
import '../../features/wifi_scan/domain/services/scan_diff_engine.dart'
    as _i557;
import '../../features/wifi_scan/domain/services/scan_session_store.dart'
    as _i797;
import '../../features/wifi_scan/domain/usecases/get_historical_best_channel.dart'
    as _i519;
import '../../features/wifi_scan/domain/usecases/scan_wifi.dart' as _i451;
import '../../features/wifi_scan/presentation/bloc/wifi_scan_bloc.dart'
    as _i968;
import '../data/database_helper.dart' as _i941;
import '../i18n/locale_cubit.dart' as _i734;
import '../services/notification_service.dart' as _i941;
import '../services/privilege_service.dart' as _i286;
import '../services/process_runner.dart' as _i522;
import '../storage/app_database.dart' as _i690;
import '../theme/theme_cubit.dart' as _i611;
import 'app_module.dart' as _i460;

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
    gh.lazySingleton<_i690.AppDatabase>(() => _i690.AppDatabase());
    gh.lazySingleton<_i941.DatabaseHelper>(() => _i941.DatabaseHelper());
    gh.lazySingleton<_i797.ScanSessionStore>(() => _i797.ScanSessionStore());
    gh.lazySingleton<_i471.SecurityAnalyzer>(() => _i471.SecurityAnalyzer());
    gh.lazySingleton<_i156.ConsentGuard>(() => _i156.ConsentGuard());
    gh.lazySingleton<_i1048.SecurityEventStore>(
      () => _i1048.SecurityEventStore(),
    );
    gh.lazySingleton<_i1066.ArpDataSource>(() => _i1066.ArpDataSource());
    gh.lazySingleton<_i552.AppSettingsStore>(() => _i552.AppSettingsStore());
    gh.lazySingleton<_i969.ChannelRatingEngine>(
      () => _i969.ChannelRatingEngine(),
    );
    gh.lazySingleton<_i941.NotificationService>(
      () => _i941.NotificationService(),
    );
    gh.lazySingleton<_i557.ScanDiffEngine>(() => _i557.ScanDiffEngine());
    gh.lazySingleton<_i892.TopologyBuilder>(() => _i892.TopologyBuilder());
    gh.lazySingleton<_i522.ProcessRunner>(() => _i522.ProcessRunnerImpl());
    gh.singleton<_i734.LocaleCubit>(
      () => _i734.LocaleCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i611.ThemeCubit>(
      () => _i611.ThemeCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i119.ReportExportRepository>(
      () => _i953.ReportExportRepositoryImpl(),
    );
    gh.lazySingleton<_i494.HeatmapRepository>(
      () => _i335.HeatmapRepositoryImpl(),
    );
    gh.lazySingleton<_i790.ScanPersistenceDataSource>(
      () => _i790.ScanPersistenceDataSource(gh<_i690.AppDatabase>()),
    );
    gh.lazySingleton<_i1012.WifiDataSource>(
      () => _i672.AndroidWifiDataSource(),
      instanceName: 'android',
    );
    gh.lazySingleton<_i499.SecurityLocalDataSource>(
      () => _i499.SecurityLocalDataSourceImpl(gh<_i941.DatabaseHelper>()),
    );
    gh.lazySingleton<_i286.PrivilegeService>(
      () => _i286.PrivilegeServiceImpl(gh<_i522.ProcessRunner>()),
    );
    gh.lazySingleton<_i367.GenerateReportUseCase>(
      () => _i367.GenerateReportUseCase(gh<_i119.ReportExportRepository>()),
    );
    gh.lazySingleton<_i305.ChannelRatingLocalDataSource>(
      () => _i305.ChannelRatingLocalDataSourceImpl(gh<_i941.DatabaseHelper>()),
    );
    gh.lazySingleton<_i890.SpeedTestRepository>(
      () => _i528.SpeedTestRepositoryImpl(gh<_i522.ProcessRunner>()),
    );
    gh.lazySingleton<_i508.ActiveSecurityRepository>(
      () => _i586.ActiveSecurityRepositoryImpl(
        gh<_i156.ConsentGuard>(),
        gh<_i522.ProcessRunner>(),
        gh<_i1048.SecurityEventStore>(),
      ),
    );
    gh.lazySingleton<_i328.DeauthDetectionService>(
      () => _i328.DeauthDetectionService(
        gh<_i522.ProcessRunner>(),
        gh<_i286.PrivilegeService>(),
        gh<_i941.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i1024.RunSpeedTestUseCase>(
      () => _i1024.RunSpeedTestUseCase(gh<_i890.SpeedTestRepository>()),
    );
    gh.lazySingleton<_i332.ChannelRatingRepository>(
      () => _i671.ChannelRatingRepositoryImpl(
        gh<_i305.ChannelRatingLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i102.LogHeatmapPointUseCase>(
      () => _i102.LogHeatmapPointUseCase(gh<_i494.HeatmapRepository>()),
    );
    gh.lazySingleton<_i725.GetZoneAveragesUseCase>(
      () => _i725.GetZoneAveragesUseCase(gh<_i494.HeatmapRepository>()),
    );
    gh.lazySingleton<_i1012.WifiDataSource>(
      () => _i653.LinuxWifiDataSource(
        gh<_i522.ProcessRunner>(),
        gh<_i286.PrivilegeService>(),
      ),
      instanceName: 'linux',
    );
    gh.factory<_i573.HeatmapBloc>(
      () => _i573.HeatmapBloc(
        gh<_i725.GetZoneAveragesUseCase>(),
        gh<_i102.LogHeatmapPointUseCase>(),
      ),
    );
    gh.lazySingleton<_i424.NmapDataSource>(
      () => _i424.LinuxNmapDataSource(gh<_i286.PrivilegeService>()),
    );
    gh.lazySingleton<_i1027.WifiRepository>(
      () => _i433.WifiRepositoryImpl(
        gh<_i1012.WifiDataSource>(instanceName: 'linux'),
        gh<_i1012.WifiDataSource>(instanceName: 'android'),
      ),
    );
    gh.lazySingleton<_i467.CaptureHandshakeUseCase>(
      () => _i467.CaptureHandshakeUseCase(gh<_i508.ActiveSecurityRepository>()),
    );
    gh.lazySingleton<_i809.RunActiveDefenseCheckUseCase>(
      () => _i809.RunActiveDefenseCheckUseCase(
        gh<_i508.ActiveSecurityRepository>(),
      ),
    );
    gh.lazySingleton<_i519.GetBestHistoricalChannel>(
      () => _i519.GetBestHistoricalChannel(gh<_i332.ChannelRatingRepository>()),
    );
    gh.factory<_i554.ReportsBloc>(
      () => _i554.ReportsBloc(gh<_i367.GenerateReportUseCase>()),
    );
    gh.lazySingleton<_i578.SecurityRepository>(
      () => _i997.SecurityRepositoryImpl(gh<_i499.SecurityLocalDataSource>()),
    );
    gh.lazySingleton<_i87.AnalyzeNetworkSecurityUseCase>(
      () => _i87.AnalyzeNetworkSecurityUseCase(gh<_i578.SecurityRepository>()),
    );
    gh.factory<_i676.SecurityBloc>(
      () => _i676.SecurityBloc(
        gh<_i578.SecurityRepository>(),
        gh<_i87.AnalyzeNetworkSecurityUseCase>(),
        gh<_i797.ScanSessionStore>(),
      ),
    );
    gh.factory<_i361.WifiDetailsBloc>(
      () => _i361.WifiDetailsBloc(
        gh<_i471.SecurityAnalyzer>(),
        gh<_i467.CaptureHandshakeUseCase>(),
        gh<_i809.RunActiveDefenseCheckUseCase>(),
      ),
    );
    gh.factory<_i374.MonitoringHubBloc>(
      () => _i374.MonitoringHubBloc(gh<_i1024.RunSpeedTestUseCase>()),
    );
    gh.lazySingleton<_i365.MonitoringRepository>(
      () => _i592.MonitoringRepositoryImpl(gh<_i1027.WifiRepository>()),
    );
    gh.lazySingleton<_i1073.NetworkScanRepository>(
      () => _i551.NetworkScanRepositoryImpl(
        gh<_i424.NmapDataSource>(),
        gh<_i1066.ArpDataSource>(),
      ),
    );
    gh.lazySingleton<_i451.ScanWifi>(
      () => _i451.ScanWifi(gh<_i1027.WifiRepository>()),
    );
    gh.factory<_i739.NetworkScanBloc>(
      () => _i739.NetworkScanBloc(gh<_i1073.NetworkScanRepository>()),
    );
    gh.factory<_i968.WifiScanBloc>(
      () => _i968.WifiScanBloc(gh<_i451.ScanWifi>()),
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
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
