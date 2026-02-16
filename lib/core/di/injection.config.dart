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

import '../../features/monitoring/data/repositories/monitoring_repository_impl.dart'
    as _i592;
import '../../features/monitoring/domain/repositories/monitoring_repository.dart'
    as _i365;
import '../../features/monitoring/domain/usecases/channel_analyzer.dart'
    as _i790;
import '../../features/monitoring/presentation/bloc/monitoring_bloc.dart'
    as _i613;
import '../../features/network_scan/data/datasources/nmap_data_source.dart'
    as _i424;
import '../../features/network_scan/data/repositories/network_scan_repository_impl.dart'
    as _i551;
import '../../features/network_scan/domain/repositories/network_scan_repository.dart'
    as _i1073;
import '../../features/network_scan/presentation/bloc/network_scan_bloc.dart'
    as _i739;
import '../../features/security/domain/usecases/security_analyzer.dart'
    as _i471;
import '../../features/security/presentation/bloc/wifi_details_bloc.dart'
    as _i361;
import '../../features/wifi_scan/data/datasources/android_wifi_data_source.dart'
    as _i672;
import '../../features/wifi_scan/data/datasources/linux_wifi_data_source.dart'
    as _i653;
import '../../features/wifi_scan/data/datasources/wifi_data_source.dart'
    as _i1012;
import '../../features/wifi_scan/data/repositories/wifi_repository_impl.dart'
    as _i433;
import '../../features/wifi_scan/domain/repositories/wifi_repository.dart'
    as _i1027;
import '../../features/wifi_scan/domain/usecases/scan_wifi.dart' as _i451;
import '../../features/wifi_scan/presentation/bloc/wifi_scan_bloc.dart'
    as _i968;
import '../services/privilege_service.dart' as _i286;
import '../services/process_runner.dart' as _i522;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i471.SecurityAnalyzer>(() => _i471.SecurityAnalyzer());
    gh.lazySingleton<_i790.ChannelAnalyzer>(() => _i790.ChannelAnalyzer());
    gh.lazySingleton<_i522.ProcessRunner>(() => _i522.ProcessRunnerImpl());
    gh.lazySingleton<_i1012.WifiDataSource>(
      () => _i672.AndroidWifiDataSource(),
      instanceName: 'android',
    );
    gh.lazySingleton<_i1012.WifiDataSource>(
      () => _i653.LinuxWifiDataSource(gh<_i522.ProcessRunner>()),
      instanceName: 'linux',
    );
    gh.lazySingleton<_i286.PrivilegeService>(
      () => _i286.PrivilegeService(gh<_i522.ProcessRunner>()),
    );
    gh.lazySingleton<_i424.NmapDataSource>(
      () => _i424.LinuxNmapDataSource(gh<_i522.ProcessRunner>()),
    );
    gh.factory<_i361.WifiDetailsBloc>(
      () => _i361.WifiDetailsBloc(gh<_i471.SecurityAnalyzer>()),
    );
    gh.lazySingleton<_i1027.WifiRepository>(
      () => _i433.WifiRepositoryImpl(
        gh<_i1012.WifiDataSource>(instanceName: 'linux'),
        gh<_i1012.WifiDataSource>(instanceName: 'android'),
      ),
    );
    gh.lazySingleton<_i1073.NetworkScanRepository>(
      () => _i551.NetworkScanRepositoryImpl(gh<_i424.NmapDataSource>()),
    );
    gh.factory<_i739.NetworkScanBloc>(
      () => _i739.NetworkScanBloc(gh<_i1073.NetworkScanRepository>()),
    );
    gh.lazySingleton<_i365.MonitoringRepository>(
      () => _i592.MonitoringRepositoryImpl(gh<_i1027.WifiRepository>()),
    );
    gh.factory<_i613.MonitoringBloc>(
      () => _i613.MonitoringBloc(
        gh<_i365.MonitoringRepository>(),
        gh<_i790.ChannelAnalyzer>(),
      ),
    );
    gh.lazySingleton<_i451.ScanWifi>(
      () => _i451.ScanWifi(gh<_i1027.WifiRepository>()),
    );
    gh.factory<_i968.WifiScanBloc>(
      () => _i968.WifiScanBloc(gh<_i451.ScanWifi>()),
    );
    return this;
  }
}
