/// Represents the survey guidance gate status.
/// Pure Dart enum for the Domain layer.
enum SurveyGate {
  none,
  noConnectedBssid,
  staleSignal,
  weakSignal,
  pdrDrift,
  originNotPlaced,
  trackingLost,
}
