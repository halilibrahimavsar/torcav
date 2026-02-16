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
import '../services/process_runner.dart' as _i522;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i522.ProcessRunner>(() => _i522.ProcessRunnerImpl());
    gh.lazySingleton<_i1012.WifiDataSource>(
      () => _i653.LinuxWifiDataSource(gh<_i522.ProcessRunner>()),
    );
    gh.lazySingleton<_i1027.WifiRepository>(
      () => _i433.WifiRepositoryImpl(gh<_i1012.WifiDataSource>()),
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
