/// Wi-Fi frequency band classification.
enum WifiBand { ghz24, ghz5, ghz6 }

/// Infers the Wi-Fi band from a channel number.
///
/// WARNING: ambiguous when the same channel number is valid in multiple
/// bands. Both 2.4 GHz (1-14) and 6 GHz (1, 5, 9, ...) define a "channel 1",
/// so a sample that only carries the channel number cannot be reliably
/// classified. Prefer [bandFromFrequency] whenever frequency is available.
WifiBand bandFromChannel(int channel) {
  if (channel >= 1 && channel <= 14) return WifiBand.ghz24;
  if (channel >= 32 && channel <= 177) return WifiBand.ghz5;
  return WifiBand.ghz6;
}

/// Infers the Wi-Fi band from a center frequency in MHz. This is the
/// authoritative classifier — frequencies do not collide across bands.
WifiBand bandFromFrequency(int frequency) {
  if (frequency >= 2400 && frequency < 2500) return WifiBand.ghz24;
  if (frequency >= 5000 && frequency < 5925) return WifiBand.ghz5;
  return WifiBand.ghz6; // 5925..7200 (and any unexpected high frequency)
}

/// 0 = 2.4 GHz, 1 = 5 GHz, 2 = 6 GHz — used as a tab index across the
/// spectrum UI.
int bandIndex(WifiBand band) => switch (band) {
  WifiBand.ghz24 => 0,
  WifiBand.ghz5 => 1,
  WifiBand.ghz6 => 2,
};

String bandShortLabel(WifiBand band) => switch (band) {
  WifiBand.ghz24 => '2.4 GHz',
  WifiBand.ghz5 => '5 GHz',
  WifiBand.ghz6 => '6 GHz',
};
