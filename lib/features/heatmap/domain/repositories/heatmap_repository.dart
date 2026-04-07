import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/heatmap_session.dart';

/// Abstract contract for persisting and retrieving heatmap sessions.
abstract class HeatmapRepository {
  /// Loads all stored sessions, ordered by creation date (newest first).
  Future<Either<Failure, List<HeatmapSession>>> getSessions();

  /// Persists a new or updated session.
  Future<Either<Failure, Unit>> saveSession(HeatmapSession session);

  /// Permanently removes a session and all its points.
  Future<Either<Failure, Unit>> deleteSession(String sessionId);
}
