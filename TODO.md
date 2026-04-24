# Torcav Project TODO List

This list summarizes the missing components, technical debt, and compliance requirements for the Torcav project, prioritized by urgency.

## [P0] Critical & Compliance (Play Store Readiness)
- [ ] **Permissions Cleanup**: Remove unused sensitive permissions from `AndroidManifest.xml` to avoid Play Store rejection.
    - [ ] Remove `BODY_SENSORS`
    - [ ] Remove `RECORD_AUDIO`
    - [ ] Remove `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`
    - [ ] Remove `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PROJECTION`
- [ ] **Release Hygiene**: Update package identity from `com.example.torcav` to a production-ready bundle ID across all platforms.
    - [ ] Update `android/app/build.gradle.kts`
    - [ ] Update `ios/Runner.xcodeproj/project.pbxproj`
    - [ ] Update `macos/Runner/Configs/AppInfo.xcconfig`
- [ ] **Privacy Surface**: Implement a functional Privacy Policy.
    - [ ] Populate `PrivacyPolicyPage` with real content.
    - [ ] Link onboarding checkboxes to the policy page.
    - [ ] Host the policy at a public URL for Play Store listing.
- [ ] **Consent UX**: Add "Prominent Disclosure" dialogs that appear *before* system permission prompts for:
    - [ ] Location (Wi-Fi Scanning)
    - [ ] Camera (Heatmap AR)
    - [ ] Activity Recognition (Indoor Mapping)
- [ ] **Data Governance**: Complete the "Wipe All Data" implementation.
    - [ ] Ensure LAN scan history is wiped.
    - [ ] Ensure heatmap sessions and points are wiped.
    - [ ] Ensure security assessment history is wiped.
- [ ] **Messaging Alignment**: Synchronize app copy with technical reality.
    - [ ] Update descriptions to acknowledge active LAN discovery (port scanning/SSDP) instead of claiming "passive-only".
- [ ] **Safety Enforcement**: Implement runtime checks for `strictSafetyMode`.
    - [ ] Disable active discovery features when strict safety is enabled.

## [P1] Technical Debt & Quality
- [ ] **Refactor Large Files**: Split massive widget trees into smaller, maintainable components (Target: <500 lines per file).
    - [ ] `lib/features/monitoring/presentation/pages/topology_page.dart` (~1300 lines)
    - [ ] `lib/features/settings/presentation/pages/settings_page.dart` (~1200 lines)
    - [ ] `lib/features/dashboard/presentation/pages/dashboard_page.dart` (~1200 lines)
    - [ ] `lib/features/network_scan/presentation/widgets/host_device_card.dart` (~1000 lines)
- [ ] **Crash Analytics**: Integrate a production-grade error reporting service (e.g., Sentry) to replace simple `debugPrint` hooks in `main.dart`.
- [ ] **Repo Hygiene**: Clean up stale analysis files from the project root.
    - [ ] Remove `analysis_results.txt`, `current_analysis.txt`, etc.

## [P2] Feature Polish
- [ ] **Dashboard Enhancements**:
    - [ ] Implement real-time data refresh for the dashboard.
    - [ ] Add "Explainable Score" tooltips to help users understand security findings.
- [ ] **Scanning Improvements**:
    - [ ] Add IPv6 support to the LAN scanner.
    - [ ] Implement rate-limiting for port scans to prevent network congestion.
- [ ] **Heatmap Optimization**:
    - [ ] Optimize sensor sampling rates to reduce battery drain during active sessions.

## [P3] Future Roadmap
- [ ] **Automation**: Implement scheduled background scans for persistent monitoring.
- [ ] **Reporting**: Add encrypted/signed PDF export for professional security reports.
- [ ] **Widgets**: Create Home Screen widgets for quick signal strength and security status monitoring.
