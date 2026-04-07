enum ScanPhase {
  /// User hasn't started a session yet.
  idle,

  /// User is walking and measuring signal strength + wall geometry.
  scanning,

  /// Session is temporarily suspended.
  paused,

  /// Scan is finished, user is reviewing the heatmap.
  reviewing,
}
