import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../datasources/arp_data_source.dart';
import '../datasources/mdns_data_source.dart';
import '../datasources/upnp_data_source.dart';

@LazySingleton(as: NetworkScanRepository)
class NetworkScanRepositoryImpl implements NetworkScanRepository {
  final ArpDataSource _arpDataSource;
  final MdnsDataSource _mdnsDataSource;
  final UpnpDataSource _upnpDataSource;

  NetworkScanRepositoryImpl(
    this._arpDataSource,
    this._mdnsDataSource,
    this._upnpDataSource,
  );

  @override
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(
    String subnet,
  ) async {
    try {
      final results = (await _arpDataSource.discoverHosts(targetSubnet: subnet))
          .map(
            (h) => NetworkDevice(
              ip: h.ip,
              mac: h.mac,
              vendor: h.vendor,
              hostName: h.hostName,
              latency: h.latency,
            ),
          )
          .toList();

      return Right(results);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HostScanResult>>> scanWithProfile(
    String target, {
    NetworkScanProfile profile = NetworkScanProfile.fast,
    PortScanMethod method = PortScanMethod.auto,
  }) async {
    try {
      // Start discovery in parallel with ARP scan
      final mdnsFuture = _mdnsDataSource.discoverServices();
      final upnpFuture = _upnpDataSource.discoverSsdp();
      final arpFuture = _arpDataSource.discoverHosts(
        targetSubnet: target,
        profile: profile,
      );

      final results = await Future.wait([arpFuture, mdnsFuture, upnpFuture]);
      
      final List<HostScanResult> baseHosts = results[0] as List<HostScanResult>;
      final Map<String, List<String>> mdnsMap = results[1] as Map<String, List<String>>;
      final Map<String, String> upnpMap = results[2] as Map<String, String>;

      // Enrich hosts with discovered info
      final enrichedHosts = baseHosts.map((host) {
        String hostName = host.hostName;
        String deviceType = host.deviceType;
        
        // Use mDNS name if hostName is empty
        if (hostName.isEmpty && mdnsMap.containsKey(host.ip)) {
          hostName = mdnsMap[host.ip]!.first;
        }

        // Refine device type if UPnP info is available
        if (upnpMap.containsKey(host.ip)) {
          final upnpInfo = upnpMap[host.ip]!.toLowerCase();
          if (upnpInfo.contains('smart tv') || upnpInfo.contains('tizen') || upnpInfo.contains('webos')) {
            deviceType = 'Smart TV';
          } else if (upnpInfo.contains('speaker') || upnpInfo.contains('sonos')) {
            deviceType = 'Audio Device';
          } else if (upnpInfo.contains('printer')) {
            deviceType = 'Printer';
          } else if (upnpInfo.contains('nas') || upnpInfo.contains('storage')) {
            deviceType = 'NAS/Storage';
          }
        }

        return HostScanResult(
          ip: host.ip,
          mac: host.mac,
          vendor: host.vendor,
          hostName: hostName,
          osGuess: host.osGuess,
          latency: host.latency,
          services: host.services,
          exposureFindings: host.exposureFindings,
          exposureScore: host.exposureScore,
          deviceType: deviceType,
        );
      }).toList();

      return Right<Failure, List<HostScanResult>>(enrichedHosts);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
