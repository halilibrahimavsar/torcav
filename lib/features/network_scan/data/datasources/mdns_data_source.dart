import 'package:injectable/injectable.dart';
import 'package:multicast_dns/multicast_dns.dart';

@LazySingleton()
class MdnsDataSource {
  /// Performs mDNS PTR lookup to find local network services and their host names.
  /// Returns a map of IP -> List of service names or host names discovered.
  Future<Map<String, List<String>>> discoverServices() async {
    final client = MDnsClient();
    await client.start();

    final discoveries = <String, List<String>>{};

    // Search for common services: _http._tcp.local, _airplay._tcp.local, _googlecast._tcp.local, etc.
    final serviceTypes = [
      '_http._tcp.local',
      '_services._dns-sd._udp.local',
      '_googlecast._tcp.local',
      '_airplay._tcp.local',
      '_raop._tcp.local', // AirPlay Audio
      '_ipp._tcp.local',  // Printer
      '_smb._tcp.local',  // Windows File Sharing
      '_device-info._tcp.local',
    ];

    try {
      for (final type in serviceTypes) {
        await for (final ptr in client.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(type),
        )) {
          // Now lookup the Service (SRV) for this PTR
          await for (final srv in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName),
          )) {
            // Now resolve the IP (A or AAAA) for the target host in SRV
            await for (final ipRecord in client.lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target),
            )) {
              final ip = ipRecord.address.address;
              final name = ptr.domainName.split('.').first;
              
              discoveries.putIfAbsent(ip, () => []).add(name);
            }
          }
        }
      }
    } catch (_) {
      // Quietly ignore network errors during discovery
    } finally {
      client.stop();
    }

    return discoveries;
  }
}
