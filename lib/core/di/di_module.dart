import 'dart:io';
import 'package:wifi_scan/wifi_scan.dart';


import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/wifi_scan/data/datasources/android_wifi_data_source.dart';
import '../../features/wifi_scan/data/datasources/linux_wifi_data_source.dart';
import '../../features/wifi_scan/data/datasources/wifi_data_source.dart';

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  NetworkInfo get networkInfo => NetworkInfo();

  @lazySingleton
  WiFiScan get wifiScan => WiFiScan.instance;

  @lazySingleton
  WifiDataSource wifiDataSource(

    AndroidWifiDataSource android,
    LinuxWifiDataSource linux,
  ) {
    if (Platform.isAndroid) return android;
    return linux;
  }
}
