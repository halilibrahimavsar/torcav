# Torcav — Privacy Policy

**Effective date:** 2026-05-08
**Version:** 1.0
**Applies to:** Torcav mobile application (Android, iOS) and any related distributions.

---

## Quick summary

- Torcav is a Wi-Fi and LAN security analysis app for **networks you own or are authorised to scan**.
- **Almost everything stays on your device.** No accounts, no cloud sync, no analytics, no advertising SDKs.
- A few features make outbound connections to **public technical endpoints** (Cloudflare for speed test, Google for captive-portal detection, public DNS resolvers for benchmark). Those endpoints see your IP only — no Torcav telemetry is attached.
- You can wipe every byte of local data from **Settings → Privacy → Wipe All Local Data** at any time.

If you stop reading here, you've got the gist. The sections below are the formal version.

---

## 1. Who is the data controller?

**Torcav is operated by an individual developer**, not a registered company:

- **Name:** Halil İbrahim Avşar
- **Contact email:** `halirlnj@gmail.com`
- **Project home:** [GitHub repository](https://github.com/halirlnj/torcav) (replace with actual URL)
- **Jurisdiction:** Turkey

Because the controller is an individual rather than a legal entity, liability sits with the named person above. There is no company providing a "limited liability" shield. You can reach out to the email above for any privacy-related request, including data subject rights under KVKK and GDPR.

---

## 2. What data does Torcav collect?

Torcav collects only what each feature directly requires. Every category below stays **on your device** unless explicitly marked otherwise.

### 2.1 Wi-Fi metadata
- **What:** SSID (network name), BSSID (router MAC), RSSI (signal strength), channel, channel width, security type (WPA2/WPA3/Open), WPS / PMF flags, vendor (derived from MAC OUI), Wi-Fi standard (Wi-Fi 4/5/6/7).
- **Why:** Channel rating, evil-twin detection, dual-band sibling detection, security scoring.
- **Source:** Android `WifiManager.scanResults`, iOS `NEHotspotHelper` (limited).
- **Retention:** Configurable. Default 30 days. Range: 7-365 days. Toggle: Settings → Privacy → Scan history retention.

### 2.2 LAN device inventory
- **What:** IP address, MAC address, hostname, NetBIOS name, vendor, open ports + service banners, AI-classified device type (when AI is enabled).
- **Why:** Device discovery, exposure scoring, host trust assessment.
- **Source:** ARP table, mDNS / Bonjour, SSDP, TCP connect probes (deep scan only).
- **Retention:** Same as Wi-Fi (default 30 days, configurable).
- **Note:** **This data may include third parties' devices** if they are connected to the same network. Always anonymise reports before sharing them externally (the anonymisation toggle in Reports is **on by default**).

### 2.3 Speed test results
- **What:** Latency, jitter, download/upload throughput, loaded latency, bufferbloat grade.
- **Why:** Performance monitoring, Speed Doctor root-cause analysis.
- **Source:** Cloudflare's public speed-test endpoint (`speed.cloudflare.com`).
- **External exposure:** Cloudflare sees your IP and downloads/uploads ~300-500 MB during the test. **No Torcav-specific identifier is attached.**
- **Retention:** Configurable. Default 30 days.

### 2.4 Security events
- **What:** Detected anomalies — evil twin candidates, captive portal redirects, DNS hijack symptoms, ARP spoofing patterns, gateway baseline drift.
- **Why:** Notification, security score history.
- **Retention:** Configurable. Default 30 days.

### 2.5 Heatmap RSSI measurements
- **What:** Sequence of (RSSI, position) pairs captured while you walk around with the heatmap survey active. Position is a metric coordinate **relative to the survey origin**, not GPS.
- **Why:** Wi-Fi coverage map, dead-zone detection, mesh placement suggestion.
- **Source:** Wi-Fi connected-signal RSSI + device IMU/barometer for relative position.
- **External exposure:** None. **GPS is not used.**
- **Retention:** Sessions persist until you delete them or run "Wipe All Local Data".

### 2.6 User preferences
- **What:** Theme, language, scan interval, default network context (home/public/guest), retention sliders, deep-scan toggle, AI toggle.
- **Why:** App configuration.
- **Retention:** Persists until app uninstall or wipe.

### 2.7 Permissions used
| Permission | Why we ask for it | Required? |
|---|---|---|
| `ACCESS_FINE_LOCATION` (Android) | Android requires location permission to enable Wi-Fi scanning. We do not read GPS coordinates. | Yes |
| `CAMERA` (Android, iOS) | AR-based heatmap visualisation only. Frames are processed on-device, never uploaded. | Optional |
| `INTERNET`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE` (Android) | Network probes, scan triggering. | Yes |
| `POST_NOTIFICATIONS` (Android 13+) | Alerts you about new devices, encryption changes, gateway drift — only when background monitoring is enabled. | Optional |

Heatmap surveys read the accelerometer, gyroscope and compass to estimate
how far you have walked between measurements. On Android those sensors need
no permission, and we do not use the activity-recognition API, so no motion
permission is requested.

We do **not** request: `ACTIVITY_RECOGNITION`, `BODY_SENSORS`, `RECORD_AUDIO`, `READ/WRITE_EXTERNAL_STORAGE`, `READ_PHONE_STATE`, `SEND_SMS`, `RECEIVE_SMS`, `CALL_PHONE`. If a third-party plugin tries to inject any of those into our manifest, we explicitly remove them.

---

## 3. Where does data go?

### 3.1 Local-only by default
The app stores everything in a **local SQLite database (encrypted at rest with a per-install key in Android Keystore / iOS Keychain)** plus Hive boxes for preferences. Nothing leaves your device automatically.

### 3.2 External technical endpoints (limited and unavoidable)

These are required for specific features and never carry user identifiers, account tokens, or telemetry:

| Endpoint | What is sent | What they see | Why we use it |
|---|---|---|---|
| `speed.cloudflare.com` | Bytes for throughput measurement | Your IP + bandwidth profile | Speed test — there is no on-device alternative |
| `connectivitycheck.gstatic.com/generate_204` | Plain HTTP HEAD request | Your IP | Captive-portal detection (Google's standard mechanism, used by Android itself) |
| `1.1.1.1`, `8.8.8.8`, `9.9.9.9`, `208.67.222.222`, `94.140.14.14` | DNS A/AAAA queries for `google.com` and `cloudflare.com` | Your IP + the queried domain | DNS resolver benchmark + leak detection |
| `whoami.akamai.net`, `debug.opendns.com` | DNS query | Your IP | Resolver identification (figures out which DNS your network actually uses) |
| `sigok.vertebrate.adns.network`, `sigfail.vertebrate.adns.network` | DNS query | Your IP | DNSSEC validation test (returns one signed-good and one signed-bad name) |
| a randomly generated `*.com` name | DNS query | Your IP + a name that cannot exist | NXDOMAIN hijack test — if a name that cannot exist still resolves, something is rewriting your DNS |
| `api.pwnedpasswords.com` | The **first 5 characters** of the SHA-1 of a password you type | Your IP + those 5 characters | Breach check. The password never leaves the device: the hash is computed locally, only the prefix is sent, and the match is resolved on-device against the returned list. We also request padded responses so the number of matches cannot be inferred from the response size |

**None of these endpoints receive a user ID, BSSID, MAC, or any Torcav-internal identifier.** The query payloads are public probe content.

#### Links you open yourself

These are **not** connections Torcav makes. Tapping them hands the address to
your browser, which then connects as it would to any other site:

| Address | Opened when |
|---|---|
| `halirlnj.github.io/torcav-privacy` | You tap the link to this policy in Settings |
| `tplinkwifi.net`, `routerlogin.net`, `router.asus.com`, `miwifi.com`, `tendawifi.com`, `mwlogin.net`, `linksyssmartwifi.com`, or your gateway's IP | You tap "open router admin page" in the hardening guide. These are your own router's address; the first seven are vendor shortcuts that resolve to it |

### 3.3 What we do not do
- We do not run analytics SDKs (Firebase, Mixpanel, Amplitude, etc.). The `com.google.gms.google-services` plugin was explicitly removed.
- We do not embed advertising IDs.
- We do not transmit usage telemetry.
- We do not call home on app start.
- We do not sync your data to any cloud account.

If you flip on the Reports → Share PDF flow, the file goes wherever **you** choose to send it (email, messaging app, file manager). That is your action; we don't see the destination.

---

## 4. Retention and deletion

### 4.1 Per-feature retention
Each data category has a configurable retention window in **Settings → Privacy → Data retention**:

- Scan history: 7-365 days (default 30)
- Speed test results: 7-365 days (default 30)
- Security events: 7-365 days (default 30)
- Heatmap sessions: until manually deleted
- LAN scan history: until manually deleted

The app prunes records older than the configured window automatically on the next launch.

### 4.2 Wiping everything
**Settings → Privacy → Wipe All Local Data** removes:
- All scan snapshots
- Known networks + trusted profiles
- Assessment sessions
- Security events
- Heatmap sessions and points
- LAN scan history
- Speed test history
- Channel rating history
- Score history
- Device label overrides, favourites, network context overrides, router hardening progress, pinned networks

This is a single-tap, irreversible action. After it completes, the app behaves as a fresh install (your settings — theme, language — are not affected; uninstall to clear those).

### 4.3 Uninstall
Uninstalling the app removes the entire local database, Hive boxes, and any encryption keys held in the platform keystore. There is no remote copy to recover.

---

## 5. Your rights

### 5.1 Under KVKK (Turkey)
Under articles 11 of Law No. 6698 (KVKK) you have the right to:
- Request information about whether your data is processed
- Request access to your data
- Request correction of inaccurate data
- Request deletion or destruction of your data
- Object to automated decision-making
- Be compensated for damages from unlawful processing

For Torcav, the in-app **Wipe All Local Data** action satisfies the deletion right immediately. For other requests, contact `halirlnj@gmail.com` and we will respond within 30 days as required by KVKK.

The controller (Halil İbrahim Avşar) qualifies for the **VERBİS registration exemption** under KVKK Article 16 (individual + small scale), so no public registry filing is required, but every other obligation under KVKK applies in full.

### 5.2 Under GDPR (EU/EEA)
Articles 15-22 of GDPR grant you parallel rights: access, rectification, erasure, portability, objection. The Reports feature (Settings → Privacy → Export Local Data) provides a JSON dump of every category as a portability mechanism.

Under Article 30, the controller qualifies for the small-scale record-keeping exemption (<250 employees, processing not a high risk) — but Privacy Policy obligations remain.

### 5.3 Lodging a complaint
- **Turkey:** Veri Koruma Kurulu (Personal Data Protection Authority) — `kvkk.gov.tr`
- **EU/EEA:** Your local data protection authority. List: `edpb.europa.eu/about-edpb/about-edpb/members_en`

---

## 6. Children

Torcav is not designed for users under 13. We do not knowingly collect data from children. Heatmap scans, security analysis, and the legal acknowledgements during onboarding presume a user old enough to take responsibility for the network being scanned. If you become aware that a child has used the app to scan a network without authorisation, contact us and we will assist.

---

## 7. Third-party libraries

Torcav uses open-source Flutter and Dart packages. The most data-relevant ones:

- `network_info_plus` — read connected SSID/BSSID/gateway IP from the OS
- `flutter_secure_storage` — store the database encryption key in the platform keychain
- `permission_handler` — request runtime permissions
- `onnxruntime` — on-device device-type classifier (no model uploads)
- `printing`, `pdf` — generate the PDF reports
- `url_launcher` — open external links you tap

None of these phone home with Torcav data.

---

## 8. Authorised use

Torcav is intended for networks **you own or are explicitly authorised to scan**. Active LAN discovery, port scanning, and DNS probes are technical operations that — on networks you do not own — may violate:

- **Turkey:** Türk Ceza Kanunu Articles 243 (unauthorised system access) and 244 (system disruption)
- **EU:** Directive 2013/40/EU on attacks against information systems
- **US:** Computer Fraud and Abuse Act (18 U.S.C. § 1030)

You are solely responsible for ensuring you have authorisation. The legal acknowledgement during onboarding is a record of this consent and persists locally; we do not transmit it.

---

## 9. Changes to this policy

If we materially change how data is handled, we will:
1. Update this document and increment the version number
2. Show an in-app notice on the next launch
3. Update the GitHub-hosted copy at the same time

You are bound by the version that was effective at the time you used the app. Old versions remain in the GitHub repository's git history.

---

## 10. Contact

- **Email:** `halirlnj@gmail.com`
- **GitHub issues (preferred for non-sensitive questions):** [project repository] — open an issue with the `privacy` label
- **Response time:** Within 30 days for formal data-subject requests, sooner for general questions

---

*Last updated: 2026-05-08*
