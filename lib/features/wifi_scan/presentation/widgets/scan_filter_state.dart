import '../../domain/entities/wifi_band.dart';
import '../../domain/entities/wifi_observation.dart';

enum ScanSortBy { signal, ssid, channel, security }

const _sentinel = Object();

class ScanFilterState {
  final String query;
  final ScanSortBy sortBy;
  final WifiBand? band;

  const ScanFilterState({
    this.query = '',
    this.sortBy = ScanSortBy.signal,
    this.band,
  });

  ScanFilterState copyWith({
    String? query,
    ScanSortBy? sortBy,
    Object? band = _sentinel,
  }) {
    return ScanFilterState(
      query: query ?? this.query,
      sortBy: sortBy ?? this.sortBy,
      band: band == _sentinel ? this.band : band as WifiBand?,
    );
  }

  static List<WifiObservation> apply(
    List<WifiObservation> networks,
    ScanFilterState filter, {
    Set<String> pinned = const {},
  }) {
    var result =
        networks.where((n) {
          final q = filter.query.trim().toLowerCase();
          if (q.isNotEmpty) {
            if (!n.ssid.toLowerCase().contains(q) &&
                !n.bssid.toLowerCase().contains(q) &&
                !n.vendor.toLowerCase().contains(q)) {
              return false;
            }
          }
          if (filter.band != null) {
            final freq = n.frequency;
            final networkBand =
                freq >= 5925
                    ? WifiBand.ghz6
                    : freq >= 5000
                    ? WifiBand.ghz5
                    : WifiBand.ghz24;
            if (networkBand != filter.band) return false;
          }
          return true;
        }).toList();

    switch (filter.sortBy) {
      case ScanSortBy.signal:
        result.sort((a, b) => b.avgSignalDbm.compareTo(a.avgSignalDbm));
      case ScanSortBy.ssid:
        result.sort(
          (a, b) => a.ssid.toLowerCase().compareTo(b.ssid.toLowerCase()),
        );
      case ScanSortBy.channel:
        result.sort((a, b) => a.channel.compareTo(b.channel));
      case ScanSortBy.security:
        result.sort((a, b) => a.security.index.compareTo(b.security.index));
    }

    if (pinned.isNotEmpty) {
      result.sort((a, b) {
        final ap = pinned.contains(a.bssid) ? 0 : 1;
        final bp = pinned.contains(b.bssid) ? 0 : 1;
        return ap.compareTo(bp);
      });
    }

    return result;
  }
}
