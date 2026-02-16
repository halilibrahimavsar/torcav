import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/error/failures.dart';
import 'package:torcav/core/services/process_runner.dart';
import 'package:torcav/features/wifi_scan/data/datasources/linux_wifi_data_source.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

class MockProcessRunner extends Mock implements ProcessRunner {}

void main() {
  late LinuxWifiDataSource dataSource;
  late MockProcessRunner mockProcessRunner;

  setUp(() {
    mockProcessRunner = MockProcessRunner();
    dataSource = LinuxWifiDataSource(mockProcessRunner);
  });

  group('scanNetworks', () {
    const tBssid = r'00\:11\:22\:33\:44\:55';
    const tUnescapedBssid = '00:11:22:33:44:55';
    const tSsid = 'TestNetwork';
    const tSignal = 80; // Quality
    const tSignalDbm = -60; // (80/2 - 100) = 40 - 100 = -60
    const tSecurity = 'WPA2';
    const tChannel = 6;
    const tFreq = 2437;
    const tLine = '$tBssid:$tSsid:$tSignal:$tSecurity:$tChannel:$tFreq MHz';

    // nmcli -t -f BSSID,SSID,SIGNAL,SECURITY,CHAN,FREQ device wifi list
    // 00:11:22:33:44:55:TestNetwork:80:WPA2:6:2437 MHz

    test(
      'should return list of WifiNetwork when nmcli call is successful',
      () async {
        // arrange
        when(
          () => mockProcessRunner.run(any(), any()),
        ).thenAnswer((_) async => ProcessResult(0, 0, '$tLine\n', ''));

        // act
        final result = await dataSource.scanNetworks();

        // assert
        expect(result, isA<List<WifiNetwork>>());
        expect(result.length, 1);
        expect(result.first.ssid, tSsid);
        expect(result.first.bssid, tUnescapedBssid);
        expect(result.first.signalStrength, tSignalDbm);
        expect(result.first.security, SecurityType.wpa2);
        expect(result.first.channel, tChannel);
        expect(result.first.frequency, tFreq);
      },
    );

    test('should throw ScanFailure when nmcli call fails', () async {
      // arrange
      when(
        () => mockProcessRunner.run(any(), any()),
      ).thenAnswer((_) async => ProcessResult(0, 1, '', 'Error'));

      // act
      final call = dataSource.scanNetworks;

      // assert
      expect(call(), throwsA(isA<ScanFailure>()));
    });

    test('should handle escaped colons in SSID correctly', () async {
      // SSID: "Test:Colons" -> Escaped in nmcli terse: "Test\:Colons"
      // Line: BSSID:Test\:Colons:Signal...
      const tSsidWithColon = 'Test:Colons';
      const tEscapedSsid = r'Test\:Colons';
      const tLineWithColon =
          '$tBssid:$tEscapedSsid:$tSignal:$tSecurity:$tChannel:$tFreq MHz';

      when(
        () => mockProcessRunner.run(any(), any()),
      ).thenAnswer((_) async => ProcessResult(0, 0, tLineWithColon, ''));

      final result = await dataSource.scanNetworks();

      expect(result.first.ssid, tSsidWithColon);
    });

    test('should handle backslashes correctly', () async {
      // SSID: "Test\Backslash" -> Escaped in nmcli terse: "Test\\Backslash"
      const tSsidWithBackslash = r'Test\Backslash';
      const tEscapedSsid = r'Test\\Backslash';
      const tLineWithBackslash =
          '$tBssid:$tEscapedSsid:$tSignal:$tSecurity:$tChannel:$tFreq MHz';

      when(
        () => mockProcessRunner.run(any(), any()),
      ).thenAnswer((_) async => ProcessResult(0, 0, tLineWithBackslash, ''));

      final result = await dataSource.scanNetworks();

      expect(result.first.ssid, tSsidWithBackslash);
    });
  });
}
