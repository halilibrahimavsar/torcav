import '../entities/heatmap_session.dart';

/// Abstract contract for persisting and retrieving heatmap sessions.
abstract class HeatmapRepository {
  /// Loads all stored sessions, ordered by creation date (newest first).
  Future<List<HeatmapSession>> getSessions();

  /// Persists a new or updated session.
  Future<void> saveSession(HeatmapSession session);

  /// Permanently removes a session and all its points.
  Future<void> deleteSession(String sessionId);
}
