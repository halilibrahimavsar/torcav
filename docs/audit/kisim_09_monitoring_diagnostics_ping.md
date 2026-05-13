# Kısım 9 — Monitoring, Diagnostics, Ping Stabilizer

> Kapsam: `lib/features/monitoring/` (28), `lib/features/diagnostics/` (18), `lib/features/ping_stabilizer/` (27) = **73 dosya**
> + Native: `android/app/src/main/kotlin/dev/halilibrahim/torcav/PingStabilizerVpnService.kt`
>
> **Compliance kritik:** VpnService + foreground service + packet pass-through.

---

## 🔴 B9.1 KRİTİK — VPN prominent disclosure (✅ DÜZELTİLDİ)

### Tespit
Switch toggle `cubit.startStabilizer()` → `StartStabilizationUseCase` → `_repository.requestVpnPermission()` → Android sistem dialogu.
**Önceden:** UI'da kullanıcıya açıklama yok; Switch ON anında system dialogu çıkıyor.

### Play Store VPN Policy şartları
- *"Apps using VpnService must declare the use case in Play Console permission declaration form"*
- *"User must be explicitly informed about what data is intercepted before VpnService is requested"*
- *"VpnService cannot be used to intercept/collect data without prominent disclosure"*

### Mevcut kodun durumu
- **Manifest doğru ✅:** `foregroundServiceType="specialUse"` + `PROPERTY_SPECIAL_USE_FGS_SUBTYPE="local_ping_stabilizer_tunnel"`
- **Native doğru ✅:** `local-only (no remote relay)` — DNS interception + UDP/53 redirect; diğer paketler değiştirilmeden geçer
- **App-içi disclosure ❌ EKSİKTİ:** Sistem dialogu jenerik, app-spesifik açıklama yoktu

### Uygulanan düzeltme
**`stabilizer_toggle_card.dart` Switch handler güncellendi:**
```dart
final accepted = await showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (ctx) => ProminentDisclosureDialog(
    icon: Icons.shield_moon_rounded,
    title: l10n.pingStabilizerConsentTitle,        // "Activate Ping Stabilizer"
    description: l10n.pingStabilizerConsentDesc,   // "A local on-device VPN tunnel..."
    privacyPoints: [
      l10n.pingStabilizerConsentRouting,           // "Traffic stays on device, no remote server"
      l10n.pingStabilizerConsentDns,               // "Only DNS queries redirected, other packets passthrough"
      l10n.pingStabilizerConsentControl,           // "Stop anytime from screen or notification"
    ],
    actionLabel: l10n.pingStabilizerConsentAction, // "Start stabilizer"
    ...
  ),
);
if (accepted == true) cubit.startStabilizer();
```

**6 yeni ARB key x 4 dil = 24 metin** eklendi (EN/TR/DE/KU).
**Kısım 14 not'u:** Play Console submit'inde VPN Permission Declaration Form doldurulmalı — kullanım amacı "Network-related functionality" / "Local-only DNS routing for stable latency".

---

## Compliance Pozitifleri (✅)

| Konu | Durum |
|---|---|
| VpnService **local-only**, dış relay yok | ✅ Native koddan doğrulandı |
| Foreground service tipi `specialUse` | ✅ Manifest |
| `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` | ✅ `local_ping_stabilizer_tunnel` |
| App-içi prominent disclosure | ✅ **B9.1 DÜZELTİLDİ** |
| `POST_NOTIFICATIONS` runtime istek | ✅ ping_stabilizer_cubit:150-160 (Permission.notification.request) |
| `Permission.notification.permanentlyDenied` ele alma | ✅ `openAppSettings()` linki |
| 0 debugPrint / print | ✅ Tüm 73 dosya |
| 0 HttpClient inline | ✅ |
| 0 TLS bypass | ✅ |
| `local_ping_stabilizer_tunnel` enum nedeni manifest yorumda | ✅ "we are not a generic VPN client" |
| Method channel hata yönetimi | ✅ `PlatformException` + `MissingPluginException` defensive |

---

## Diğer Bulgular

### B9.2 — `monitoring_repository_impl` + `topology_repository_impl` 4 hardcoded Failure mesajı (O)
**Kanıt:**
```
monitoring_repository_impl.dart:53 'Network not found'
topology_repository_impl.dart:117 'Host Unreachable'
topology_repository_impl.dart:163 'Hostname not found'
topology_repository_impl.dart:187 'Could not determine OS'
```
**Tespit:** Failure mesajları, presentation'da `Text(failure.message)` ile gösteriliyor olabilir.
**Aksiyon:** `docs/internal/failure_refactor_backlog.md`'ye eklendi (Kısım 7+8c'den biriken Failure code pattern).

### B9.3 — `diagnosis_explainer.dart` 3-4 İngilizce paragraph (O)
**Kanıt:**
```
diagnosis_explainer.dart:194 '"Adaptive QoS") in your router admin page.'
diagnosis_explainer.dart:295-297 (DNS açıklaması, 3 satır)
diagnosis_explainer.dart:308 'Speed Doctor checks five things...'
```
**Tespit:** Diagnostic explanation cümleleri. UI'da `evidence_card.dart` veya `primary_cause_card.dart` ile gösteriliyor olabilir. Kontrol: `_explainer.explain(...)` çıktısı UI'da nasıl tüketiliyor.
**Aksiyon:** Backlog'a eklendi — diagnosis_explainer için Kısım 8a'daki evil_twin_explainer kontrolüne benzer halüsinasyon riski var (UI zaten l10n switch yapıyor olabilir).

### B9.4 — `ping_stabilizer` 2 hardcoded Failure mesajı (D)
**Kanıt:**
```
ping_stabilizer_repository_impl.dart:51 'Native VPN service refused to start.'
start_stabilization_usecase.dart:24 'VPN permission denied.'
```
**Tespit:** Failure mesajları. ping_stabilizer_cubit `failure.message` üzerinden state'e koyup UI'a gösteriyor olabilir.
**Aksiyon:** Backlog'a — Wi-Fi Failure refactor (B7.2) pattern'ine ekle.

### B9.5 — Hardcoded marka/teknik isimler — false positive (D)
**Kanıt:**
```
dns_candidate.dart:20,21 'Cloudflare', 'Google'
stabilization_profile.dart:46-101 'Valorant', 'CS2 / Source', 'PUBG Mobile', 'Mobile Legends'
channel_history_chart.dart:673 'CH $ch'
spectrum_overlap_chart.dart:556 'CH ${network.channel} · ${network.frequency} MHz'
```
**Tespit:** Marka adları (Cloudflare, oyun isimleri) + teknik label'lar ('CH 1') — **lokalize edilmez**.
**Aksiyon:** False positive, müdahale yok.

---

## Kanıt Tablosu

| İddia | Konum | Sonuç |
|---|---|---|
| B9.1 disclosure eksikti | `stabilizer_toggle_card.dart:86 (önceden)` | onChanged direkt `cubit.startStabilizer()` |
| B9.1 düzeltildi | `stabilizer_toggle_card.dart:86-110 (sonra)` | showDialog<bool> + ProminentDisclosureDialog |
| Native VPN local-only | `PingStabilizerVpnService.kt:38-48` doc | "No remote server is required... on-device" |
| Manifest specialUse | `AndroidManifest.xml` | `foregroundServiceType="specialUse"` |
| POST_NOTIFICATIONS akışı | `ping_stabilizer_cubit.dart:149-160` | Permission.notification check + request + permanentlyDenied banner |
| Method channel defensive | `ping_stabilizer_channel.dart` | Her metodun `on PlatformException`/`MissingPluginException` |
| 0 sızıntı | grep tüm 3 modül | 0 debugPrint, 0 HttpClient, 0 TLS bypass |

---

## Kısım 9 Bulgu Özeti

| Bulgu | Şiddet | Durum |
|---|---|---|
| B9.1 VPN prominent disclosure | **K** | ✅ Düzeltildi (Switch handler + 6 ARB key x 4 dil) |
| B9.2 monitoring Failure mesajları | O | Backlog'a (B7.4 pattern) |
| B9.3 diagnosis_explainer İng. cümleler | O | Backlog'a — halüsinasyon riski (8a evil_twin pattern) |
| B9.4 ping_stabilizer 2 Failure | D | Backlog'a |
| B9.5 marka/teknik label'lar | D | False positive |
| ✅ Compliance pozitifleri | — | 10 |

**Kısım 9 düzeltme: 1 kritik (B9.1) uygulandı, 3 backlog'a (sürüm sonrası refactor).**

flutter analyze: temiz

---

## Play Store Submit Notu (Kısım 14'e)

1. **VPN Permission Declaration Form** (Play Console submit aşamasında):
   - Use case: "Network-related functionality" (kategori)
   - Specific: "Local-only on-device latency / jitter measurement + DNS routing for gaming/streaming"
   - **Önemli:** "Does the app collect/transmit user data over VPN?" → **NO** (cevabı)
   - Yorum: "Tunnel is fully local; no remote server. Only DNS UDP/53 packets are intercepted and redirected to user-selected resolver."

2. **Foreground service `specialUse` justification**:
   - Manifest yorumunda zaten var ("local_ping_stabilizer_tunnel")
   - Play Console'da subtype açıklaması istenirse: "Real-time latency / jitter telemetry while game/streaming is active"
