# Torcav Project TODO List

> Last updated: 2026-05-08. Major Play-Store-readiness sweep completed.
> Most P0 items below are now closed; check the [Closed] section at the
> end for the historical list. Active work focuses on v1.1 follow-ups.

## [P0] Remaining Pre-Release Tasks

- [ ] **Production keystore (Android)**: Generate a release keystore and
      configure `signingConfigs.release` in `android/app/build.gradle.kts`.
      Currently the release build is signed with the debug key. **Hard
      blocker for Play Store submission.**
- [ ] **Apple Developer Program enrolment** (individual): $99/year. Required
      for App Store submission and for the BGAppRefreshTask entitlement to
      function on signed builds.
- [ ] **Privacy Policy hosting**: Create `torcav-privacy` public GitHub
      repository, copy `docs/PRIVACY_POLICY.md` to `index.md`, enable
      GitHub Pages. Then update `_privacyPolicyUrl` in
      `lib/features/settings/presentation/pages/privacy_policy_page.dart`
      to the live URL. See `docs/PRIVACY_POLICY_HOSTING.md` for steps.
- [ ] **Play Console Data Safety form**: Fill in the data inventory based
      on Privacy Policy section 2 ("What data does Torcav collect?").

## [v1.1] Crash Analytics — Sentry

Deferred from v1.0 because there is no production crash data yet to
analyse. Re-evaluate after first 1-2 weeks of public availability.

- [ ] Add `sentry_flutter` to pubspec.yaml
- [ ] Create a Sentry account (free tier: 5,000 errors/month is plenty
      for an individual developer)
- [ ] Store the DSN in a build-time `--dart-define` so it doesn't land
      in source control
- [ ] Add `Settings → Privacy → Send crash reports` toggle, **default OFF**
- [ ] Update Privacy Policy:
    - Add Sentry as a data processor
    - Document what's sent (stack traces, OS version, app version, route)
    - Document what's redacted (BSSID, MAC, SSID via `beforeSend` hook)
    - Link to Sentry's DPA
- [ ] `beforeSend` PII redaction:
    - Mask all BSSID-shaped strings with `XX:XX:XX:XX:XX:XX`
    - Mask the last 3 octets of any MAC
    - Drop any field named `ssid` / `password` / `apiKey`
- [ ] Test the opt-in flow: enable, force a crash, verify it appears in
      Sentry; then disable, force another, verify nothing arrives

## [P1] Technical Debt & Quality

- [ ] **Refactor Large Files**: Split massive widget trees into smaller,
      maintainable components (Target: <500 lines per file).
    - [ ] `lib/features/monitoring/presentation/pages/topology_page.dart` (~1300 lines)
    - [ ] `lib/features/settings/presentation/pages/settings_page.dart` (~1300 lines)
    - [ ] `lib/features/dashboard/presentation/pages/dashboard_page.dart` (~1200 lines)
    - [ ] `lib/features/network_scan/presentation/widgets/host_device_card.dart` (~1000 lines)
    - [ ] `lib/features/reports/presentation/pages/reports_page.dart` (~750 lines)
- [ ] **Repo Hygiene**: Clean up stale analysis files from the project root.
    - [ ] Remove `analysis_results.txt`, `current_analysis.txt`, etc.
- [ ] **Localization completeness**: Speed Doctor explainer paragraphs,
      Evil Twin explainer signal labels, action verbs are still inline
      English. Migrate to ARB across en/tr/de/ku.

## [P2] Feature Polish

- [ ] **Dashboard Enhancements**:
    - [ ] Implement real-time data refresh for the dashboard.
- [ ] **Scanning Improvements**:
    - [ ] Add IPv6 support to the LAN scanner.
    - [ ] Implement rate-limiting for port scans to prevent network congestion.
- [ ] **Heatmap Optimization**:
    - [ ] Optimize sensor sampling rates to reduce battery drain during active sessions.

## [P3] Future Roadmap

- [ ] **Reporting**: Encrypted PDF export with proper PDF-spec encryption
      (current `.torcav-pdf` is lightweight obfuscation, not bank-grade).
- [ ] **Widgets**: Home Screen widgets for quick signal strength and
      security status monitoring.
- [ ] **Speed Doctor history**: Persist the last N diagnoses for trend
      analysis.

## [Closed] Completed

These items were resolved during the v1.0 readiness sweep:

- ✅ Permissions cleanup (`AndroidManifest.xml` — `BODY_SENSORS`,
  `RECORD_AUDIO`, `READ/WRITE_EXTERNAL_STORAGE`,
  `FOREGROUND_SERVICE_MEDIA_PROJECTION`, etc. all `tools:node="remove"`).
- ✅ Bundle ID migrated to `dev.halilibrahim.torcav` across Android, iOS,
  macOS and Linux.
- ✅ Firebase/`google-services` plugin removed from
  `android/settings.gradle.kts`.
- ✅ Privacy Policy populated (`docs/PRIVACY_POLICY.md` + in-app card UI +
  GitHub Pages hosting instructions in `docs/PRIVACY_POLICY_HOSTING.md`).
- ✅ Wipe All Local Data covers LAN history, heatmap sessions, security
  events, trusted profiles, assessments, score history, and override
  stores (settings_page.dart:846-859).
- ✅ Background monitoring (Android `MonitoringService` foreground
  service + iOS `BGAppRefreshTask`), opt-in via Settings.
- ✅ Speed Doctor (root-cause coach), Evil Twin classifier,
  Device Trust UI, Onboarding network-type picker, PDF password
  obfuscation, Gateway baseline drift, Mesh placement service,
  Home Health Report builder, CVE database freshness card.
