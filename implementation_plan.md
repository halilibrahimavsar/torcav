# Torcav Security & Network Feature Expansion Plan

## 1. Active Port Scanning (Phase 1 - In Progress)
Integrate an active TCP Connect / SYN Port Scanner into the Network Scan module.
- **Progress:** Core data source, repository, and use cases are implemented.
- **Remaining Task:** Update UI components (`HostDeviceCard`, `NetworkScanPage`) to display open ports with high-fidelity, neon-themed iconography.
- **Refinement:** Ensure scan timeouts are optimized for mobile environments to avoid battery drain.

## 2. Router Vulnerability Database (Phase 2)
Implement a local database cross-referencing MAC OUIs / BSSIDs / Fingerprints against known vulnerable routers (CVEs, Default credentials, WPS Pixie Dust susceptibility).
- **Data Layer:** Create `VulnerabilityDataSource` that ships with a local JSON dictionary of vendor-specific vulnerability patterns.
- **Domain Layer:** `CheckRouterVulnerabilityUseCase` to quantify risk level (Critical, Elevated, Normal).
- **Security Logic:** Enhance `SecurityAnalyzer` to incorporate database findings into the overall security score.

## 3. Deep Security Analysis (Phase 3 - NEW)
### A. ARP Spoofing Detection
- Monitor for conflicting MAC-to-IP mappings during network discovery.
- Flag changes in Gateway MAC address as potential MITM attacks.
### B. DNS Hijacking Check
- Attempt resolution of high-profile domains (e.g., google.com, apple.com) through system DNS and compare against known valid ranges.
- Detect "Dark DNS" or suspicious resolvers.

## 4. Advanced Risk Profiling (Phase 4 - NEW)
### A. Exposure Score 2.0
- Calculate a weighted risk score per host based on: Open Ports + Vendor Reputation + Security Drift.
- Categorize devices (e.g., IoT, Mobile, Server) for better recommendation engines.
### B. VPN & Public Wi-Fi Shield
- Automated DNS Leak Test when a VPN is detected.
- Real-time warning if unencrypted HTTP traffic is detected on public hotspots.

## 5. UI/UX Hardening (Phase 5 - Improvement)
- **Security Dashboard:** A central "Operation Hub" view for all security findings.
- **Interactive Radar:** Enhanced visual feedback in the `SecurityStatusRadar` with micro-animations for discovered threats.
- **Neon Aesthetic:** Implementation of `AppTheme` additions for critical security alerts (Glow effects, specific HSL-based hazard colors).

## Verification Plan
- **Unit Testing:** Coverage for `VulnerabilityDataSource` and `SecurityAnalyzer` logic.
- **Integration Testing:** Mocking network scenarios (Evil Twin SSID, Port exposure) to verify BLoC state transitions.
- **Manual Verification:** Running on a local network to ensure port scan and OUI detection work as expected.
