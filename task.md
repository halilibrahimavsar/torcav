# Tasks

- [x] **Phase 0: Pre-requisite Refactoring**
  - [x] Identify and replace empty `catch (_) {}` blocks in `arp_data_source.dart`, `mdns_data_source.dart`, and `upnp_data_source.dart` with `Left(Failure)`.
  - [x] Refactor `SecurityRepositoryImpl` to use Functional Error Handling (`Either`).

- [x] **Phase 1: Active Port Scanning**
  - [x] Define `Port` and `ServiceFingerprint` models.
  - [x] Implement `PortScanDataSource` using Dart Sockets.
  - [x] Implement `PortScanRepositoryImpl`.
  - [x] Create `PortScanUseCase`.
  - [x] Integrate `PortScanUseCase` into `NetworkScanBloc`.
  - [x] Update `HostDeviceCard` UI to display open ports with neon styling.
  - [x] Add "Port Scan" toggle in `NetworkScanPage` settings.

- [/] **Phase 3: Security Hardening & Deep Scan**
  - [x] Integrate `isDeepScan` flag into `SecurityRepository` and `AnalyzeNetworkSecurityUseCase`.
  - [x] Implement LAN device discovery in `SecurityRepositoryImpl.analyzeNetworks`.
  - [x] Add "Deep Scan (Experimental)" toggle in `SecurityCenterPage`.
  - [x] Implement `SecurityDeepScanToggled` event in `SecurityBloc`.
  - [x] Update `SecurityAnalyzer` to handle `isDeepScan` and add specific findings.
  - [ ] **Implement Quick Port Scan on Gateway** during Deep Scan in `SecurityRepositoryImpl`.
  - [ ] **Fix Exhaustive Switch Cases** for ARP/DNS threats in:
    - [ ] `lib/features/security/presentation/pages/security_center_page.dart` (`_EventCard`)
    - [ ] `lib/core/services/notification_service.dart` (`_getTitleForEvent`)
    - [ ] `lib/features/dashboard/presentation/pages/notification_sheet.dart` (`_getTypeIcon`, `_getTypeLabel`)
  - [x] Localize experimental scan toggle and findings in `app_en.arb`.

- [ ] **Phase 4: Advanced Risk Profiling**
  - [ ] Implement `ExposureScore` utility for weighted risk calculation.
  - [ ] Add VPN Leak detection use case.
  - [ ] Implement Public Wi-Fi unencrypted traffic warning.

- [ ] **Phase 5: UI/UX Hardening**
  - [ ] Design and implement the "Operation Hub" central dashboard.
  - [ ] Add micro-animations to `SecurityStatusRadar`.
  - [ ] Apply `AppTheme` glow effects to critical security findings.

