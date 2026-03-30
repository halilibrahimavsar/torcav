import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/services/notification_service.dart';
import 'package:torcav/core/services/privilege_service.dart';
import 'package:torcav/core/services/process_runner.dart';
import 'package:torcav/features/monitoring/data/services/deauth_detection_service.dart';

class MockProcessRunner extends Mock implements ProcessRunner {}

class MockPrivilegeService extends Mock implements PrivilegeService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockProcess extends Mock implements Process {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(ProcessSignal.sigterm);
  });

  late DeauthDetectionService service;
  late MockProcessRunner mockProcessRunner;
  late MockPrivilegeService mockPrivilegeService;
  late MockNotificationService mockNotificationService;
  late MockProcess mockProcess;

  setUp(() {
    mockProcessRunner = MockProcessRunner();
    mockPrivilegeService = MockPrivilegeService();
    mockNotificationService = MockNotificationService();
    mockProcess = MockProcess();

    // Default stubs
    when(() => mockProcess.kill(any())).thenReturn(true);
    when(() => mockProcess.stdout).thenAnswer((_) => const Stream.empty());
    when(() => mockProcess.stderr).thenAnswer((_) => const Stream.empty());
    when(() => mockProcess.exitCode).thenAnswer((_) => Future.value(0));

    service = DeauthDetectionService(
      mockProcessRunner,
      mockPrivilegeService,
      mockNotificationService,
    );
  });

  tearDown(() {
    service.dispose();
  });

  group('startMonitoring', () {
    test('should return false if not on Linux (simulated)', () async {
      if (!Platform.isLinux) {
        final result = await service.startMonitoring('wlan0');
        expect(result, false);
      }
    });

    test('should return false if airodump-ng is missing', () async {
      // Simple mock for which command failure
      when(
        () => mockProcessRunner.run('which', ['airodump-ng']),
      ).thenAnswer((_) async => ProcessResult(0, 1, '', 'Error'));

      final result = await service.startMonitoring('wlan0');
      expect(result, false);
    });

    test('should start monitoring successfully when tool exists', () async {
      when(() => mockProcessRunner.run('which', ['airodump-ng'])).thenAnswer(
        (_) async => ProcessResult(0, 0, '/usr/bin/airodump-ng', ''),
      );

      when(
        () => mockPrivilegeService.startAsRoot(any(), any()),
      ).thenAnswer((_) async => mockProcess);

      final result = await service.startMonitoring('wlan0');
      expect(result, true);

      verify(
        () => mockPrivilegeService.startAsRoot('airodump-ng', [
          'wlan0',
          '--berlin',
          '60',
        ]),
      ).called(1);
    });
  });
}
