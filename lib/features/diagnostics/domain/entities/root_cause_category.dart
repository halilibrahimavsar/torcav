/// Five root-cause buckets the Speed Doctor can classify a slow connection
/// into, plus a healthy fallback when no threshold is breached.
enum RootCauseCategory {
  weakSignal,
  crowdedChannel,
  bufferbloat,
  ispSlow,
  slowDns,
  healthy,
}
