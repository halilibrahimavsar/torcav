/// Which platform backend a Wi-Fi scan should prefer.
///
/// Lives in `core` rather than `wifi_scan` because it is a *persisted user
/// setting* (`AppSettings.defaultBackendPreference`) as much as a scan
/// parameter. Keeping it here lets `AppSettings` stay free of feature
/// imports, which is what broke the `settings ↔ wifi_scan` dependency cycle.
enum WifiBackendPreference { auto, nmcli, iw, android }
