/// The trust/exposure context a network is being used in.
///
/// Used by [SecurityAnalyzer] to weight findings differently — e.g. an
/// open Wi-Fi at a café is expected (`public`), while the same finding
/// on a user's `home` network is much more alarming.
enum NetworkContextType {
  /// User's own home network — strict baseline expected.
  home,

  /// Café / hotel / airport / open hotspot — relaxed encryption expectations
  /// but heightened sensitivity to lure SSIDs and credential exposure.
  public,

  /// A guest segment of a known network — natural drift permitted.
  guest,

  /// Context could not be inferred — fall back to neutral weighting.
  unknown,
}

extension NetworkContextTypeX on NetworkContextType {
  String get labelKey => switch (this) {
        NetworkContextType.home => 'networkContextHomeLabel',
        NetworkContextType.public => 'networkContextPublicLabel',
        NetworkContextType.guest => 'networkContextGuestLabel',
        NetworkContextType.unknown => 'networkContextUnknownLabel',
      };
}
