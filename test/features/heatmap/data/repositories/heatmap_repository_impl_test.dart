import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/heatmap/data/datasources/heatmap_local_data_source.dart';
import 'package:torcav/features/heatmap/data/repositories/heatmap_repository_impl.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';

class _MockDataSource extends Mock implements HeatmapLocalDataSource {}

class _FakeHeatmapSession extends Fake implements HeatmapSession {}

void main() {
  late _MockDataSource ds;
  late HeatmapRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_FakeHeatmapSession());
  });

  setUp(() {
    ds = _MockDataSource();
    repo = HeatmapRepositoryImpl(ds);
  });

  HeatmapSession session(String id) => HeatmapSession(
        id: id,
        name: 'session $id',
        points: const [],
        createdAt: DateTime(2026),
      );

  group('getSessions', () {
    test('wraps successful list in Right', () async {
      when(() => ds.getSessions())
          .thenAnswer((_) async => [session('a'), session('b')]);

      final result = await repo.getSessions();
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (list) {
        expect(list.map((s) => s.id), ['a', 'b']);
      });
    });

    test('wraps exceptions in Left(CacheFailure)', () async {
      when(() => ds.getSessions()).thenThrow(StateError('disk full'));

      final result = await repo.getSessions();
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<CacheFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('saveSession', () {
    test('returns Right(unit) on success', () async {
      when(() => ds.saveSession(any())).thenAnswer((_) async {});

      final result = await repo.saveSession(session('a'));
      expect(result.isRight(), isTrue);
    });

    test('returns Left(CacheFailure) when data source throws', () async {
      when(() => ds.saveSession(any())).thenThrow(StateError('write failed'));

      final result = await repo.saveSession(session('a'));
      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteSession', () {
    test('returns Right(unit) on success', () async {
      when(() => ds.deleteSession('a')).thenAnswer((_) async {});

      final result = await repo.deleteSession('a');
      expect(result.isRight(), isTrue);
      verify(() => ds.deleteSession('a')).called(1);
    });

    test('returns Left(CacheFailure) when data source throws', () async {
      when(() => ds.deleteSession(any())).thenThrow(StateError('missing'));

      final result = await repo.deleteSession('a');
      expect(result.isLeft(), isTrue);
    });
  });
}
