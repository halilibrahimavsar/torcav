import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/error/failures.dart';
import 'package:torcav/core/services/process_runner.dart';
import 'package:torcav/features/network_scan/data/datasources/nmap_data_source.dart';
import 'package:torcav/features/network_scan/domain/entities/network_scan_profile.dart';

class MockProcessRunner extends Mock implements ProcessRunner {}

void main() {
  late LinuxNmapDataSource dataSource;
  late MockProcessRunner mockProcessRunner;

  setUp(() {
    mockProcessRunner = MockProcessRunner();
    dataSource = LinuxNmapDataSource(mockProcessRunner);
  });

  const xmlOutput = '''
<?xml version="1.0"?>
<nmaprun>
  <host>
    <status state="up" reason="arp-response"/>
    <address addr="192.168.1.1" addrtype="ipv4"/>
    <address addr="AA:BB:CC:DD:EE:FF" addrtype="mac" vendor="GatewayVendor"/>
    <hostnames><hostname name="Gateway"/></hostnames>
    <ports>
      <port protocol="tcp" portid="80">
        <state state="open"/>
        <service name="http" product="nginx" version="1.22"/>
      </port>
    </ports>
  </host>
  <host>
    <status state="up" reason="arp-response"/>
    <address addr="192.168.1.15" addrtype="ipv4"/>
    <hostnames><hostname name="MyPhone"/></hostnames>
  </host>
</nmaprun>
''';

  test('should parse nmap xml output correctly for subnet scan', () async {
    when(
      () => mockProcessRunner.run('nmap', any()),
    ).thenAnswer((_) async => ProcessResult(0, 0, xmlOutput, ''));

    final devices = await dataSource.scanSubnet('192.168.1.0/24');

    expect(devices.length, 2);
    expect(devices[0].ip, '192.168.1.1');
    expect(devices[0].hostName, 'Gateway');
    expect(devices[0].vendor, 'GatewayVendor');
    expect(devices[1].ip, '192.168.1.15');
    expect(devices[1].hostName, 'MyPhone');
  });

  test('should parse detailed host scan profile output', () async {
    when(
      () => mockProcessRunner.run('nmap', any()),
    ).thenAnswer((_) async => ProcessResult(0, 0, xmlOutput, ''));

    final hosts = await dataSource.scanTarget(
      '192.168.1.0/24',
      profile: NetworkScanProfile.balanced,
      method: PortScanMethod.connect,
    );

    expect(hosts, isNotEmpty);
    expect(hosts.first.services, isNotEmpty);
    expect(hosts.first.services.first.port, 80);
  });

  test('should throw ScanFailure on nmap execution error', () async {
    when(
      () => mockProcessRunner.run(any(), any()),
    ).thenAnswer((_) async => ProcessResult(0, 1, '', 'Error'));

    expect(
      () => dataSource.scanSubnet('192.168.1.0/24'),
      throwsA(isA<ScanFailure>()),
    );
  });
}
