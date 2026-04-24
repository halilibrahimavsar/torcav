import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../ai/data/services/onnx_device_classifier_service.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../datasources/arp_data_source.dart';
import '../datasources/mdns_data_source.dart';
import '../datasources/netbios_data_source.dart';
import '../datasources/upnp_data_source.dart';
import '../../../settings/domain/services/app_settings_store.dart';


@LazySingleton(as: NetworkScanRepository)
class NetworkScanRepositoryImpl implements NetworkScanRepository {
  final ArpDataSource _arpDataSource;
  final MdnsDataSource _mdnsDataSource;
  final UpnpDataSource _upnpDataSource;
  final NetbiosDataSource _netbiosDataSource;
  final OnnxDeviceClassifierService _deviceClassifier;
  final AppSettingsStore _appSettingsStore;


  NetworkScanRepositoryImpl(
    this._arpDataSource,
    this._mdnsDataSource,
    this._upnpDataSource,
    this._netbiosDataSource,
    this._deviceClassifier,
    this._appSettingsStore,
  );


  @override
  Stream<Either<Failure, List<NetworkDevice>>> scanNetwork(
    String subnet,
  ) async* {
    final List<NetworkDevice> devices = [];

    await for (final host in _arpDataSource.discoverHostsStream(
      targetSubnet: subnet,
    )) {
      devices.add(
        NetworkDevice(
          ip: host.ip,
          mac: host.mac,
          vendor: host.vendor,
          hostName: host.hostName,
          latency: host.latency,
        ),
      );
      yield Right(List.from(devices));
    }
  }

  @override
  Stream<Either<Failure, HostScanResult>> scanWithProfile(
    String target, {
    NetworkScanProfile profile = NetworkScanProfile.fast,
    PortScanMethod method = PortScanMethod.auto,
  }) async* {
    try {
      // Start discovery in parallel with ARP scan to build caches
      final mdnsFuture = _mdnsDataSource.discoverServices();
      final upnpFuture = _upnpDataSource.discoverSsdp();

      // We'll wait a very short moment for mDNS/UPnP to start gathering data
      // but we won't block the ARP stream. Caches will populate as we go.
      Map<String, List<String>> mdnsMap = {};
      Map<String, String> upnpMap = {};

      // Trigger parallel resolution to populate maps
      mdnsFuture.then((res) => res.fold((_) => null, (m) => mdnsMap = m));
      upnpFuture.then((res) => res.fold((_) => null, (u) => upnpMap = u));

      await for (final host in _arpDataSource.discoverHostsStream(
        targetSubnet: target,
        profile: profile,
      )) {
        // Yield immediately to show the device in UI ASAP
        yield Right(host);

        String hostName = host.hostName;
        String deviceType = host.deviceType;
        String? netbiosName;

        // Use mDNS name if hostName is empty
        if (hostName.isEmpty && mdnsMap.containsKey(host.ip)) {
          hostName = mdnsMap[host.ip]!.first;
        }

        // Fallback to NetBIOS if still empty and safety mode allows
        if (hostName.isEmpty && !_appSettingsStore.value.strictSafetyMode) {
          final nbName = await _netbiosDataSource.queryName(host.ip);
          if (nbName != null && nbName.isNotEmpty) {
            hostName = nbName;
            netbiosName = nbName;
          }
        }

        // Fallback to Reverse DNS if still empty and safety mode allows
        if (hostName.isEmpty && !_appSettingsStore.value.strictSafetyMode) {
          hostName = await _reverseDnsLookup(host.ip);
        }

        // AI-based device classification
        bool isAiClassified = false;
        final enrichedHost = host.copyWith(
          hostName: hostName,
          netbiosName: netbiosName,
        );

        if (_appSettingsStore.value.isAiEnabled) {
          final aiResult = await _deviceClassifier.classify(enrichedHost);
          if (aiResult != null && aiResult.confidence > 0.6) {
            deviceType = aiResult.deviceType;
            isAiClassified = true;
          }
        }

        if (!isAiClassified && upnpMap.containsKey(host.ip)) {

          final upnpInfo = upnpMap[host.ip]!.toLowerCase();
          if (upnpInfo.contains('smart tv') ||
              upnpInfo.contains('tizen') ||
              upnpInfo.contains('webos')) {
            deviceType = 'Smart TV';
          } else if (upnpInfo.contains('speaker') ||
              upnpInfo.contains('sonos')) {
            deviceType = 'Audio Device';
          } else if (upnpInfo.contains('printer')) {
            deviceType = 'Printer';
          } else if (upnpInfo.contains('nas') || upnpInfo.contains('storage')) {
            deviceType = 'NAS/Storage';
          }
        }

        // Yield again with enriched data
        yield Right(
          host.copyWith(
            hostName: hostName,
            deviceType: deviceType,
            isGateway: host.isGateway || deviceType == 'Router/Gateway',
            isAiClassified: isAiClassified,
          ),
        );

      }
    } catch (e) {
      yield Left(ScanFailure(e.toString()));
    }
  }

  Future<String> _reverseDnsLookup(String ip) async {
    try {
      final address = InternetAddress(ip);
      final result = await address.reverse();
      return result.host != ip ? result.host : '';
    } catch (_) {
      return '';
    }
  }
}
