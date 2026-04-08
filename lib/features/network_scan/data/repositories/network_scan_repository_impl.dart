import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../ai/data/services/onnx_device_classifier_service.dart';
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
  final OnnxDeviceClassifierService _deviceClassifier;

  NetworkScanRepositoryImpl(
    this._arpDataSource,
    this._mdnsDataSource,
    this._upnpDataSource,
    this._deviceClassifier,
  );

  @override
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(
    String subnet,
  ) async {
    try {
      final discoverResult = await _arpDataSource.discoverHosts(targetSubnet: subnet);
      
      return discoverResult.fold(
        (failure) => Left(failure),
        (hosts) {
          final results = hosts
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
        },
      );
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
      
      final arpResult = results[0] as Either<Failure, List<HostScanResult>>;
      final mdnsResult = results[1] as Either<Failure, Map<String, List<String>>>;
      final upnpResult = results[2] as Either<Failure, Map<String, String>>;

      if (arpResult.isLeft()) {
        return Left(arpResult.match((l) => l, (r) => throw Exception()));
      }
      
      final List<HostScanResult> baseHosts = arpResult.getOrElse((l) => []);
      final Map<String, List<String>> mdnsMap = mdnsResult.getOrElse((l) => {});
      final Map<String, String> upnpMap = upnpResult.getOrElse((l) => {});

      // Enrich hosts with discovered info (mDNS names + UPnP + AI classification)
      final enrichedHosts = <HostScanResult>[];
      for (final host in baseHosts) {
        String hostName = host.hostName;
        String deviceType = host.deviceType;

        // Use mDNS name if hostName is empty
        if (hostName.isEmpty && mdnsMap.containsKey(host.ip)) {
          hostName = mdnsMap[host.ip]!.first;
        }

        // Build a temporary host with enriched name for AI classification
        final enrichedHost = HostScanResult(
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

        // AI-based device classification
        final aiResult = await _deviceClassifier.classify(enrichedHost);
        if (aiResult != null && aiResult.confidence > 0.6) {
          deviceType = aiResult.deviceType;
        } else if (upnpMap.containsKey(host.ip)) {
          // Fallback to UPnP heuristics when AI is unavailable or low confidence
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

        enrichedHosts.add(HostScanResult(
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
        ));
      }

      return Right<Failure, List<HostScanResult>>(enrichedHosts);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
