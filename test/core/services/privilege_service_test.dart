import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/services/privilege_service.dart';
import 'package:torcav/core/services/process_runner.dart';

class MockProcessRunner extends Mock implements ProcessRunner {}

void main() {
  late PrivilegeService service;
  late MockProcessRunner mockProcessRunner;

  setUp(() {
    mockProcessRunner = MockProcessRunner();
    service = PrivilegeServiceImpl(mockProcessRunner);
  });

  group('isRoot', () {
    test('should return true when id -u returns 0', () async {
      when(
        () => mockProcessRunner.run('id', ['-u']),
      ).thenAnswer((_) async => ProcessResult(0, 0, '0\n', ''));

      // Mock Platform? No, we can't easily mock static Platform properties in standard test.
      // We assume running on Linux host for this test context or skip if not.
      // Or we can just test the logic assuming it reaches the process call.

      if (Platform.isLinux || Platform.isMacOS) {
        final result = await service.isRoot();
        expect(result, true);
      }
    });

    test('should return false when id -u returns non-0', () async {
      when(
        () => mockProcessRunner.run('id', ['-u']),
      ).thenAnswer((_) async => ProcessResult(0, 0, '1000\n', ''));

      if (Platform.isLinux || Platform.isMacOS) {
        final result = await service.isRoot();
        expect(result, false);
      }
    });
  });
}
