# Torcav Audit Summary (Kısım 0–14)

**Audit period:** 2026-05-12 → 2026-05-13
**Scope:** Full repository — 336 Dart files + Android/iOS native + CI + docs.
**Method:** Kanıt-tabanlı, kısım kısım denetim. Her iddia git/grep/build çıktısıyla doğrulandı.

## At a glance

```
22 commits | 14 detailed reports | ~700 lines dead code removed
APK 49.4 MB → 47.2 MB (-2.2 MB) | ARB 1641 → 1516 keys
debugPrint 6 → 0 | core/ empty dirs 4 → 0
8 hallucinations caught (saved hours of wrong refactor)
50+ fixes applied | 70+ compliance positives verified
1 release-blocker remaining (release keystore — B12.7)
```

## Reports

| Kısım | Subject | Findings | Fixes |
|---|---|---|---|
| [00](kisim_00_kok_temizlik.md) | Root cleanup | 8 | 7 |
| [01](kisim_01_giris_core_i.md) | Entry & Core I | 10 | 5 |
| [02](kisim_02_core_ii.md) | Core II (router/net/utils) | 3 | 1 |
| [03](kisim_03_localization.md) | Localization | 9 | 5 |
| [04](kisim_04_tema_ui.md) | Theme & UI | 6 | 3 |
| [05](kisim_05_storage_services.md) 🔴 | Storage & Services | 10 | 7 |
| [06](kisim_06_splash_appshell.md) 🔴 | Splash & Onboarding | 10 | 5 |
| [07](kisim_07_wifi_network_scan.md) 🟢 | Wi-Fi / Network Scan | 8 | 0 |
| [08a](kisim_08a_security_engines.md) 🟢 | Security engines | 9 | 2 |
| [08b](kisim_08b_vuln_db_ai.md) 🟢 | Vuln DB & AI | 7 | 0 |
| [08c](kisim_08c_security_ui.md) | Security UI | 7 | 3 |
| [09](kisim_09_monitoring_diagnostics_ping.md) 🔴 | Monitoring / VPN | 5 | 1 |
| [10](kisim_10_dashboard_reports_performance.md) | Dashboard / Reports | 5 | 1 |
| [11](kisim_11_settings_heatmap.md) 🟢 | Settings / Heatmap | 4 | 1 |
| [12](kisim_12_android_ios_native.md) 🔴 | Android & iOS native | 7 | 6 |
| [13](kisim_13_test_ci.md) | Test & CI/CD | 6 | 1 |
| [14](kisim_14_play_store_final.md) | Play Store final | — | — |

🔴 = densest fix sections | 🟢 = cleaner-than-expected sections

## Key documents

- **`PLAY_STORE_DATA_SAFETY.md`** — Updated canonical source for Play Console form
- **`PRIVACY_POLICY.md`** — Verified intact; minor version bump suggested
- **`internal/failure_refactor_backlog.md`** — Post-release refactor plan
- **`internal/untranslated_keys_list.md`** — 353 ARB keys for TR/DE/KU translation

## Top compliance wins

1. **Hive AES-256 encryption** added — BSSID/MAC/heatmap no longer plaintext on disk
2. **Onboarding mandatory** — ToS/Privacy/Age/Authorization acknowledged before app use
3. **VPN prominent disclosure** before system permission request (Play VPN policy)
4. **All `debugPrint`/`print` eliminated** — clean release logging
5. **Firebase removed** — no inadvertent Data Safety declaration burden, -2.2 MB APK
6. **targetSdk 35** — Play Console 2026 ready
7. **NEARBY_WIFI_DEVICES + neverForLocation** — modern Wi-Fi scan path

## Remaining release-blocker

**B12.7:** Release keystore not yet configured (`signingConfig = signingConfigs.getByName("debug")`).
See [Kısım 14](kisim_14_play_store_final.md) §"Sürüm Engelleyici Kalan" for full steps.

## Hallucination catches

GPT-generated initial roadmaps led with 8 incorrect claims. Evidence-based verification flipped them:

1. `Failure` Equatable bug (Kısım 1) — package source already handles `runtimeType`
2. `AndroidOptions()` weak encryption (Kısım 1) — v10 default is AES-GCM
3. PRAGMA SQL injection (Kısım 5) — UUID v4 character set safe
4. `CaptivePortalDetector` actively used (Kısım 8a) — actually dead, then wired
5. `HardeningCheckMeta` strings reach UI (Kısım 8a) — UI uses l10n extension, fields dead
6. `SecurityFinding` hardcoded titles to UI (Kısım 8c) — `vulnerability_extensions.dart` switches on ruleId
7. `EvilTwinExplanation` strings to UI (Kısım 8c) — UI uses `assessment` + l10n directly
8. `dns_test_data_source` strings to UI (Kısım 8c) — `dns_security_card` uses l10n

**Lesson:** "string exists in domain → user sees it" was false in 5 cases. Always trace the UI consumer.
