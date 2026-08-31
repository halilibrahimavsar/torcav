import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/network_scan/domain/entities/port_scan_event.dart';
import 'package:torcav/features/network_scan/domain/entities/service_fingerprint.dart';
import 'package:torcav/features/network_scan/domain/repositories/port_scan_repository.dart';
import 'package:torcav/features/network_scan/domain/usecases/port_scan_usecase.dart';

class _MockPortScanRepository extends Mock implements PortScanRepository {}

void main() {
  late _MockPortScanRepository repo;
  late PortScanUseCase usecase;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    repo = _MockPortScanRepository();
    usecase = PortScanUseCase(repo);
  });

  test('call() delegates to repository.scanPorts', () async {
    when(() => repo.scanPorts('192.168.1.4'))
        .thenAnswer((_) async => const Right(<ServiceFingerprint>[]));

    final result = await usecase('192.168.1.4');
    expect(result.isRight(), isTrue);
    verify(() => repo.scanPorts('192.168.1.4')).called(1);
  });

  test('call() propagates Left failures', () async {
    when(() => repo.scanPorts(any())).thenAnswer(
      (_) async => const Left(ScanFailure('denied')),
    );

    final result = await usecase('192.168.1.4');
    expect(result.isLeft(), isTrue);
  });

  test('callReactive() delegates to repository.scanPortsReactive', () {
    const event = PortScanEvent(
      totalCount: 5,
      scannedCount: 1,
      currentPort: 80,
    );
    when(
      () => repo.scanPortsReactive(
        any(),
        ports: any(named: 'ports'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((_) => Stream.value(event));

    expect(usecase.callReactive('192.168.1.4'), emits(event));
  });

  // The use case is the last gate before a socket opens, so it refuses a
  // non-private target regardless of what the caller passed.
  test('refuses a public address without touching the repository', () async {
    final result = await usecase('8.8.8.8');

    expect(result.isLeft(), isTrue);
    verifyNever(() => repo.scanPorts(any()));
  });

  test('the reactive path refuses a public address too', () {
    expect(usecase.callReactive('8.8.8.8'), emitsDone);
    verifyNever(() => repo.scanPortsReactive(any()));
  });
}
