import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'package:torcav/core/error/failures.dart';
import 'package:torcav/core/services/process_runner.dart';
import 'package:torcav/features/network_scan/data/datasources/nmap_data_source.dart';

class MockProcessRunner extends Mock implements ProcessRunner {}

void main() {
  late LinuxNmapDataSource dataSource;
  late MockProcessRunner mockProcessRunner;

  setUp(() {
    mockProcessRunner = MockProcessRunner();
    dataSource = LinuxNmapDataSource(mockProcessRunner);
  });

  test('should parse nmap grepable output correctly', () async {
    const nmapOutput = '''
# Nmap 7.94 scan initiated Tue Feb 17 02:00:00 2026 as: nmap -sn -oG - 192.168.1.0/24
Host: 192.168.1.1 (Gateway)	Status: Up
Host: 192.168.1.10 ()	Status: Up
Host: 192.168.1.15 (MyPhone)	Status: Up
# Nmap done at Tue Feb 17 02:00:02 2026 -- 256 IP addresses (3 hosts up) scanned in 2.00 seconds
''';

    // Verify correct arguments are passed
    when(
      () => mockProcessRunner.run('nmap', any()),
    ).thenAnswer((_) async => ProcessResult(0, 0, nmapOutput, ''));

    final devices = await dataSource.scanSubnet('192.168.1.0/24');

    expect(devices.length, 3);

    expect(devices[0].ip, '192.168.1.1');
    expect(devices[0].hostName, 'Gateway');

    expect(devices[1].ip, '192.168.1.10');
    expect(devices[1].hostName, '');

    expect(devices[2].ip, '192.168.1.15');
    expect(devices[2].hostName, 'MyPhone');
  });

  test('should return empty list on failure', () async {
    when(
      () => mockProcessRunner.run(any(), any()),
    ).thenAnswer((_) async => ProcessResult(0, 1, '', 'Error'));

    expect(
      () => dataSource.scanSubnet('192.168.1.0/24'),
      throwsA(isA<ScanFailure>()),
    );
  });
}
