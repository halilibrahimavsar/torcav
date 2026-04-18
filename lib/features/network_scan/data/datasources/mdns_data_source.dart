import 'package:injectable/injectable.dart';
import 'package:multicast_dns/multicast_dns.dart';

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';

@LazySingleton()
class MdnsDataSource {
  /// Performs mDNS PTR lookup to find local network services and their host names.
  /// Returns a map of IP -> List of service names or host names discovered.
  Future<Either<Failure, Map<String, List<String>>>> discoverServices() async {
    final client = MDnsClient();
    try {
      await client.start();
    } catch (e) {
      // On some Android versions, even the default bind can trigger reusePort errors
      // or other socket issues. We catch it here to prevent total failure.
      return Left(ScanFailure('mDNS client failed to start: $e'));
    }

    final discoveries = <String, List<String>>{};

    // Broad set of common LAN service announcements. On Android 11+ this is
    // the primary identification channel because MAC addresses are hidden.
    final serviceTypes = [
      '_http._tcp.local',
      '_services._dns-sd._udp.local',
      '_googlecast._tcp.local', // Chromecast / Google TV / Nest
      '_airplay._tcp.local', // Apple TV
      '_raop._tcp.local', // AirPlay Audio (HomePod, AirPort)
      '_ipp._tcp.local', // Printer (IPP)
      '_printer._tcp.local', // Printer (LPD)
      '_pdl-datastream._tcp.local', // HP JetDirect
      '_smb._tcp.local', // Windows/Samba file sharing
      '_afpovertcp._tcp.local', // Apple File Protocol
      '_nfs._tcp.local', // NFS share
      '_device-info._tcp.local',
      '_workstation._tcp.local', // Linux/macOS workstation
      '_companion-link._tcp.local', // iPhone/iPad Handoff
      '_apple-mobdev2._tcp.local', // iPhone/iPad tethering
      '_homekit._tcp.local', // HomeKit accessory
      '_hap._tcp.local', // HomeKit Accessory Protocol
      '_spotify-connect._tcp.local', // Spotify Connect speaker
      '_sonos._tcp.local', // Sonos speaker
      '_miio._udp.local', // Xiaomi Mi Home
      '_hue._tcp.local', // Philips Hue bridge
      '_tplink._tcp.local', // TP-Link Kasa
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
    } catch (e) {
      return Left(ScanFailure('mDNS discovery failed: $e'));
    } finally {
      client.stop();
    }

    return Right(discoveries);
  }
}
