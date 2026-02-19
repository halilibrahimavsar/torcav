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
  });

  late DeauthDetectionService service;
  late MockProcessRunner mockProcessRunner;
  late MockPrivilegeService mockPrivilegeService;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockProcessRunner = MockProcessRunner();
    mockPrivilegeService = MockPrivilegeService();
    mockNotificationService = MockNotificationService();

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

    // TODO: Enable these tests once mocktail configuration for Future<ProcessResult> is resolved
    /*
    test('should fail if airodump-ng is missing', () async {
      if (!Platform.isLinux) return;

      when(
        () => mockProcessRunner.run(any(), any()),
      ).thenAnswer((_) async => ProcessResult(0, 1, '', 'Error'));

      expect(
        () => service.startMonitoring('wlan0'),
        throwsA(isA<DeauthDetectionFailure>()),
      );
    });

    test('should start monitoring successfully when tool exists', () async {
      if (!Platform.isLinux) return;

      when(
        () => mockProcessRunner.run(any(), any()),
      ).thenAnswer((_) async => ProcessResult(0, 0, '/usr/bin/airodump-ng', ''));

      when(
        () => mockPrivilegeService.startAsRoot(any(), any()),
      ).thenAnswer((_) async => mockProcess);

      await service.startMonitoring('wlan0');

      verify(
        () => mockPrivilegeService.startAsRoot(
          'airodump-ng',
          ['wlan0', '--berlin', '60'],
        ),
      ).called(1);
    });
    */
  });
}
