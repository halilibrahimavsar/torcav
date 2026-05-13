# Google Play Data Safety Form — Torcav

> **Last updated:** 2026-05-13 (Kısım 14 final denetim sonrası)
> **App version baseline:** `pubspec.yaml 1.0.0+1`
> **Code state:** Denetim sonrası, tüm Kısım 0-13 düzeltmeleri uygulandı.

This document is the **canonical source** for filling Play Console's Data Safety form. Every claim below is verified against the codebase.

---

## Headline (Play Store)

> **Torcav does not share any data with third parties.**
> **All data is processed and stored only on the device.**
> **Users can wipe every byte from Settings → Privacy → Wipe All Local Data.**

---

## 1. Data Collection Inventory

### 1.1 Location data
| Field | Value |
|---|---|
| Type | **Precise location** (`ACCESS_FINE_LOCATION`) |
| Required? | Optional (declined → Wi-Fi scan unavailable on Android <13) |
| Modern path | `NEARBY_WIFI_DEVICES + neverForLocation` (Android 13+, added in Kısım 12) |
| Purpose | App functionality — discovering nearby Wi-Fi networks (Android OS requirement) |
| Shared with 3rd parties? | **NO** |
| Stored on device? | **NO** (used transiently during scan; GPS coordinates are not stored or transmitted) |
| User can request deletion | N/A (not stored) |
| Encryption in transit | N/A (never leaves device) |

### 1.2 Device or other IDs
| Field | Value |
|---|---|
| Type | BSSID (router MAC), MAC addresses of LAN hosts, hostnames |
| Purpose | App functionality — network analysis, topology mapping, device classification |
| Shared with 3rd parties? | **NO** |
| Stored on device? | **YES** — SQLCipher database (Hive AES-256 for prefs/MAC lists) |
| User can request deletion | **YES** — Settings → Privacy → Wipe All Local Data |
| Encryption at rest | **YES** — SQLCipher 2.3.6 (DB) + HiveAesCipher (preferences) |

### 1.3 App activity
| Field | Value |
|---|---|
| Type | In-app interactions, scan history, favorites, score history |
| Purpose | Analytics (local only — no telemetry), personalization (pinned networks) |
| Shared with 3rd parties? | **NO** |
| Stored on device? | **YES** — encrypted SQLite + Hive |
| User can request deletion | **YES** — Wipe All Data + automatic retention pruning (7-365 days, default 30) |
| Encryption at rest | **YES** |

### 1.4 Health & fitness (motion data)
| Field | Value |
|---|---|
| Type | Activity recognition (step counter), motion sensors (IMU/accelerometer), barometer |
| Purpose | App functionality — indoor signal heatmap surveys (position tracking) |
| Shared with 3rd parties? | **NO** |
| Stored on device? | **YES** — heatmap session points in encrypted Hive |
| User can request deletion | **YES** |
| Encryption at rest | **YES** |
| Special note | `BODY_SENSORS` permission explicitly removed (`tools:node="remove"`) to stay out of Health policy scope |

### 1.5 Photos and videos (camera)
| Field | Value |
|---|---|
| Type | Camera frames (live, in-memory only) |
| Purpose | App functionality — AR pose tracking for indoor heatmap surveys |
| Shared with 3rd parties? | **NO** |
| **Stored on device?** | **NO** — frames are processed in real time and discarded; no photos/videos saved |
| Encryption | N/A (not persisted) |

### 1.6 Web browsing / messages / personal info / financial info / contacts
**NOT COLLECTED.** Declare *"No data of this type"* in the Play Console form.

---

## 2. Security Practices Declaration

### Data is encrypted in transit
- **Outbound endpoints:**
  - `connectivitycheck.gstatic.com/generate_204` (HTTP/204, captive portal probe — kasıtlı HTTP for redirect detection)
  - `1.1.1.1/cdn-cgi/trace` (HTTPS, DoH/DoT detection)
  - Speed test endpoints (HTTPS, Cloudflare)
  - DNS resolver benchmarks (UDP/53, no TLS — measuring resolver latency)
- **No TLS bypass anywhere:** `grep "badCertificateCallback" lib/` → 0 results (verified Kısım 2 + 8a)
- **Answer:** **YES, encrypted in transit** (HTTP probe is for the captive portal *check itself*, not user data)

### Data is encrypted at rest
- **SQLCipher 2.3.6** wraps the main app database (DB encryption key in `flutter_secure_storage`)
- **HiveAesCipher** wraps the Hive preferences box (256-bit AES key in secure_storage — added Kısım 5)
- **`flutter_secure_storage 10.0.0`**: Android AES-GCM + RSA-OAEP, iOS Keychain `first_unlock`
- **Answer:** **YES, encrypted at rest**

### Users can request data deletion
- Settings → Privacy → **Wipe All Local Data**
- Multi-store deletion: SQLCipher DB drop, Hive box clear, secure_storage deleteAll
- **Answer:** **YES, users can request deletion**

### Users can request their data
- Settings → Privacy → **Export Local Data**
- 12 categories: Wi-Fi history, speed tests, security events, trusted networks, channel ratings, heatmap sessions, LAN scans, device labels, pinned networks, score history, network context overrides, router hardening
- 3 formats: JSON, CSV, HTML (with `anonymize` toggle masking SSID/BSSID/MAC)
- **Answer:** **YES, data export available** (GDPR right to data portability)

### Independent security review
- **Not commercial pen-test.** This audit (`docs/audit/kisim_00..14`) is the internal compliance review.
- **Answer:** Decline this checkbox unless a third-party audit is commissioned.

### Committed to follow Google Play Families Policy
- **Not targeting children.** Set "13+" or higher in target audience.

---

## 3. Permission Justifications

| Permission | Reason | UX |
|---|---|---|
| `NEARBY_WIFI_DEVICES` (neverForLocation) | Wi-Fi scan on Android 13+ without prompting for location | Prominent disclosure in `wifi_scan_page` |
| `ACCESS_FINE_LOCATION` | Wi-Fi scan on Android <13 (Android OS requirement to read scan results) | Prominent disclosure in `wifi_scan_page` |
| `ACCESS_COARSE_LOCATION` | Companion to FINE for compatibility | (granted as a pair) |
| `ACCESS_WIFI_STATE` | Read current Wi-Fi connection state | Implicit (no runtime prompt) |
| `CHANGE_WIFI_STATE` | Trigger Wi-Fi scan | Implicit |
| `INTERNET` | Speed test, DoH/DoT detection, OUI database sync | Implicit |
| `CAMERA` | AR pose tracking for indoor heatmap surveys | Prominent disclosure in `new_session_dialog` |
| `ACTIVITY_RECOGNITION` | Step counter for heatmap survey movement tracking | Prominent disclosure in `new_session_dialog` |
| `FOREGROUND_SERVICE` | Background monitoring + VPN tunnel | Implicit |
| `FOREGROUND_SERVICE_DATA_SYNC` | Background Wi-Fi state polling (`MonitoringService`) | Opt-in: Settings → Privacy → Background monitoring |
| `FOREGROUND_SERVICE_SPECIAL_USE` | Ping stabilizer VPN tunnel (specialUse + `local_ping_stabilizer_tunnel` subtype) | Prominent disclosure in `stabilizer_toggle_card` |
| `POST_NOTIFICATIONS` | Security alerts + stabilizer status | Onboarding `_NotificationsPage` (Kısım 6) + ping_stabilizer flow |
| `BIND_VPN_SERVICE` | Ping stabilizer local-only VPN tunnel | Prominent disclosure + Android system dialog |

### Permission Declaration Forms (Play Console)
1. **VPN service:**
   - Use case: "Network-related functionality"
   - Specifics: "Local-only on-device latency/jitter measurement + DNS routing"
   - "Does the app transmit user data over the VPN?" → **NO**
   - Confirm: tunnel is fully local, no remote relay
2. **Foreground service `specialUse`:**
   - Subtype: `local_ping_stabilizer_tunnel`
   - Justification: "Real-time latency/jitter telemetry while game/streaming is active"

### Explicitly REMOVED permissions (`tools:node="remove"`)
The following permissions are injected by plugins but **explicitly removed** to minimize the attack surface and avoid policy scrutiny:
```
BODY_SENSORS, HIGH_SAMPLING_RATE_SENSORS,
READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE,
RECORD_AUDIO, READ_PHONE_STATE,
CALL_PHONE, SEND_SMS, RECEIVE_SMS,
FOREGROUND_SERVICE_MEDIA_PROJECTION
```

---

## 4. Network Outbound Inventory

Torcav makes **only the following outbound network calls**, all to public technical endpoints:

| Endpoint | Protocol | Purpose | User data sent? |
|---|---|---|---|
| `connectivitycheck.gstatic.com/generate_204` | HTTP/204 | Captive portal probe | No |
| `1.1.1.1/cdn-cgi/trace` | HTTPS | DoH/DoT detection | No |
| Speed test target (Cloudflare) | HTTPS | Bandwidth measurement | No |
| Public DNS resolvers (UDP/53) | UDP | Latency benchmark | No (DNS query for fixed test domain) |

**No analytics, no crash reporting, no ad SDK.** Verified by:
- `grep "firebase|cloud_firestore|analytics|crashlytics|sentry" pubspec.yaml` → 0 results (after Kısım 12 cleanup)
- `grep "HttpClient(" lib/` → only the 4 endpoints listed above

---

## 5. Target Audience

- **Minimum age:** 13+ (recommend higher due to "Network Tools" nature)
- **Not aimed at children.**
- **Country availability:** Global (KVKK and GDPR compliant)

---

## 6. AI / ML Disclosure (Generative AI Policy)

Torcav uses an on-device ONNX classifier (`device_classifier.onnx`) to label LAN hosts (router/tablet/IoT). This is **NOT generative AI** — it's a discriminative classifier with 15 fixed categories. No prompts, no LLM, no third-party AI service.

**Answer for "Use of AI/ML":**
- "Does the app use generative AI?" → **NO**
- "Does the app send user data to AI/ML services?" → **NO** (all inference local)

---

## 7. Submit Checklist

Before clicking "Submit" in Play Console:

- [ ] **Release keystore generated** and configured in `build.gradle.kts` (B12.7 / Kısım 14 todo)
- [ ] **Release AAB built:** `flutter build appbundle --release`
- [ ] **App version bumped** in pubspec.yaml (currently `1.0.0+1`)
- [ ] **Privacy Policy URL accessible:** `https://halirlnj.github.io/torcav-privacy/` (Kısım 11 verified)
- [ ] **Content rating questionnaire** completed
- [ ] **Data Safety form** filled per this document
- [ ] **VPN Permission Declaration Form** filled (Section 3 above)
- [ ] **Target API level** = 35 (Kısım 12 verified)
- [ ] **Screenshots + feature graphic** uploaded
- [ ] **In-app onboarding tested** — `OnboardingPage` zorunlu (Kısım 6 verified)
- [ ] **Wipe All Local Data** tested end-to-end on a real device
- [ ] **VPN disclosure flow** tested (Switch ON → ProminentDisclosureDialog → system dialog → start)
