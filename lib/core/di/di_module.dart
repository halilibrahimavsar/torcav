import 'dart:io';
import 'package:wifi_scan/wifi_scan.dart';

import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../features/wifi_scan/data/datasources/android_wifi_data_source.dart';
import '../../features/wifi_scan/data/datasources/linux_wifi_data_source.dart';
import '../../features/wifi_scan/data/datasources/wifi_data_source.dart';
import '../../features/network_scan/data/datasources/arp_data_source.dart';
import '../../features/network_scan/domain/repositories/arp_table_reader.dart';

@module
abstract class AppModule {
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
    if (Platform.isLinux) return linux;
    throw UnsupportedError(
      'WifiDataSource is not implemented for ${Platform.operatingSystem}',
    );
  }

  /// Exposes the ARP table behind its domain contract so `security` can read
  /// it without importing `network_scan`'s data layer. Same instance — this
  /// is a narrowing, not a second object.
  @lazySingleton
  ArpTableReader arpTableReader(ArpDataSource source) => source;
}
