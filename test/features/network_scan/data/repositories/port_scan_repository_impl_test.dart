import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/network_scan/data/datasources/port_scan_data_source.dart';
import 'package:torcav/features/network_scan/data/repositories/port_scan_repository_impl.dart';
import 'package:torcav/features/network_scan/domain/entities/port_scan_event.dart';
import 'package:torcav/features/network_scan/domain/entities/service_fingerprint.dart';

class _MockPortScanDataSource extends Mock implements PortScanDataSource {}

void main() {
  late _MockPortScanDataSource ds;
  late PortScanRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    ds = _MockPortScanDataSource();
    repo = PortScanRepositoryImpl(ds);
  });

  group('scanPorts', () {
    test('wraps data-source result in Right', () async {
      const fingerprint = ServiceFingerprint(
        port: 80,
        protocol: 'tcp',
        serviceName: 'http',
      );
      when(() => ds.scanPorts('192.168.1.1'))
          .thenAnswer((_) async => [fingerprint]);

      final result = await repo.scanPorts('192.168.1.1');
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (list) {
        expect(list, [fingerprint]);
      });
    });

    test('wraps exceptions in Left(ScanFailure)', () async {
      when(() => ds.scanPorts(any())).thenThrow(StateError('socket denied'));

      final result = await repo.scanPorts('192.168.1.1');
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ScanFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('scanPortsReactive', () {
    test('delegates to data source', () {
      const event = PortScanEvent(
        totalCount: 1,
        scannedCount: 1,
        currentPort: 80,
      );
      when(
        () => ds.scanPortsReactive(
          any(),
          ports: any(named: 'ports'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) => Stream.value(event));

      final stream = repo.scanPortsReactive('192.168.1.1');
      expect(stream, emits(event));
    });
  });
}
