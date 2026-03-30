import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../datasources/arp_data_source.dart';
import '../datasources/nmap_data_source.dart';

@LazySingleton(as: NetworkScanRepository)
class NetworkScanRepositoryImpl implements NetworkScanRepository {
  final NmapDataSource _dataSource;
  final ArpDataSource _arpDataSource;
  final AppDatabase _appDatabase;

  NetworkScanRepositoryImpl(
    this._dataSource,
    this._arpDataSource,
    this._appDatabase,
  );

  @override
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(
    String subnet,
  ) async {
    try {
      final devices = await _dataSource.scanSubnet(subnet);
      final results = devices.isNotEmpty
          ? devices
          : (await _arpDataSource.discoverHosts(targetSubnet: subnet))
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

      // Persist results (basic mapping to NetworkDevice)
      await _persistNetworkDevices(results, subnet);

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
      final hosts = await _dataSource.scanTarget(
        target,
        profile: profile,
        method: method,
      );

      final results = hosts.isNotEmpty
          ? hosts
          : await _arpDataSource.discoverHosts(
              targetSubnet: target,
              profile: profile,
            );

      // Persist full HostScanResults
      await _persistHostScanResults(results, target);

      return Right(results);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  Future<void> _persistNetworkDevices(
    List<NetworkDevice> devices,
    String target,
  ) async {
    final db = await _appDatabase.database;
    final sessionId = await _createSession(db, 'arp/nmap', target);

    await db.transaction((txn) async {
      for (final device in devices) {
        await txn.insert('network_hosts', {
          'session_id': sessionId,
          'ip': device.ip,
          'mac': device.mac,
          'vendor': device.vendor,
          'host_name': device.hostName,
          'os_guess': 'Unknown',
          'exposure_score': 0.0,
        });
      }
    });
  }

  Future<void> _persistHostScanResults(
    List<HostScanResult> results,
    String target,
  ) async {
    final db = await _appDatabase.database;
    final sessionId = await _createSession(db, 'nmap', target);

    await db.transaction((txn) async {
      for (final host in results) {
        final hostId = await txn.insert('network_hosts', {
          'session_id': sessionId,
          'ip': host.ip,
          'mac': host.mac,
          'vendor': host.vendor,
          'host_name': host.hostName,
          'os_guess': host.osGuess,
          'exposure_score': host.exposureScore,
        });

        // Persist services
        for (final service in host.services) {
          await txn.insert('network_services', {
            'host_id': hostId,
            'port': service.port,
            'protocol': service.protocol,
            'service_name': service.serviceName,
            'product': service.product,
            'version': service.version,
          });
        }

        // Persist vulnerabilities
        for (final vuln in host.vulnerabilities) {
          await txn.insert('network_vulnerabilities', {
            'host_id': hostId,
            'script_id': vuln.id,
            'summary': vuln.summary,
            'severity': vuln.risk.name,
          });
        }
      }
    });
  }

  Future<int> _createSession(Database db, String backend, String target) async {
    return await db.insert('scan_sessions', {
      'created_at': DateTime.now().toIso8601String(),
      'backend_used': backend,
      'interface_name': target, // Using target as interface/target context
    });
  }
}
