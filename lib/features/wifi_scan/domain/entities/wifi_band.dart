/// Wi-Fi frequency band classification.
enum WifiBand { ghz24, ghz5, ghz6 }

/// Infers the Wi-Fi band from a channel number.
///
/// Channels 1-14 → 2.4 GHz, 32-177 → 5 GHz, everything else → 6 GHz.
WifiBand bandFromChannel(int channel) {
  if (channel >= 1 && channel <= 14) return WifiBand.ghz24;
  if (channel >= 32 && channel <= 177) return WifiBand.ghz5;
  return WifiBand.ghz6;
}
