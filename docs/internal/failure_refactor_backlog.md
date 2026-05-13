# Failure / Reason Code Refactor — Sürüm Sonrası Backlog

> Kısım 7 + 8a + 8c'de tespit edilen domain → presentation arası
> hardcoded İngilizce metin pipeline'larının düzeltilmesi için detaylı plan.
> Play Store **sürüm engelleyici değil** — UX kalitesi. Sürüm sonrası ayrı PR.

## Birikmiş Refactor Görevleri

### 1. HostTrustAssessment + HostTrustReason (B7.3)
**Dosyalar:**
- `lib/features/network_scan/domain/services/host_trust_classifier.dart`
- `lib/features/network_scan/domain/entities/host_trust_assessment.dart`
- `lib/features/network_scan/presentation/widgets/host_trust_badge.dart`

**Sorun:** UI'da `assessment.headline`, `reason.summary`, `reason.remediation` doğrudan Text() içinde — İngilizce hardcoded.

**Pattern:**
```dart
// HostTrustReason
class HostTrustReason {
  final HostTrustReasonCode code;
  final Map<String, String> params;  // dinamik values (örn. score)
  final HostTrustReason? remediationCode;
}

enum HostTrustReasonCode {
  exposureScoreCritical,           // "score: $score/100"
  exposureScoreHigh,
  suspiciousDeviceVendor,
  ...
}

// Presentation extension
extension HostTrustReasonX on HostTrustReason {
  String localizedSummary(BuildContext context) {
    switch (code) {
      case HostTrustReasonCode.exposureScoreCritical:
        return context.l10n.hostTrustReasonExposureCritical(params['score']);
      ...
    }
  }
}
```

**ARB key sayısı:** ~12 (4-5 reason × 2-3 metin)

**host_trust_classifier kaynaklı `headline`:** Compose from highest-priority reason or use enum `HostTrustHeadlineCode`.

---

### 2. network_scan_bloc Failure mesajları (B7.4)
**Dosya:** `lib/features/network_scan/presentation/bloc/network_scan_bloc.dart` (~145, 163, 173)

**Mevcut:**
```dart
emit(NetworkScanFailure('Legal acknowledgement required for LAN discovery.'));
emit(NetworkScanFailure('Scan target exceeds safety limits...'));
emit(NetworkScanFailure('Deep scanning is disabled when Strict Safety Mode...'));
```

**Pattern:**
```dart
enum NetworkScanFailureCode {
  legalAckRequired,
  scanTargetTooBroad,
  deepScanDisabledInStrict,
}

class NetworkScanFailureState {
  final NetworkScanFailureCode code;
}

// Presentation:
extension NetworkScanFailureCodeX on NetworkScanFailureCode {
  String localized(BuildContext context) {
    switch (this) {
      case NetworkScanFailureCode.legalAckRequired:
        return context.l10n.scanFailureLegalAckRequired;
      ...
    }
  }
}
```

**ARB key sayısı:** 3

---

### 3. Wi-Fi Failure mesajları (B7.2 + B1.6)
**Dosyalar:**
- `lib/features/wifi_scan/data/datasources/android_wifi_data_source.dart`
- `lib/features/wifi_scan/data/datasources/linux_wifi_data_source.dart`
- `lib/core/errors/failures.dart`

**Pattern:** Core Failure base'ine `code` opsiyonel parametre:
```dart
abstract class Failure {
  final String message;
  final FailureCode? code;
  final Map<String, dynamic>? params;
}

enum FailureCode {
  // Wi-Fi
  wifiLocationPermissionRequired,
  wifiLocationServiceDisabled,
  wifiScanRetrieveFailed,
  wifiNoNetworksFound,
  wifiAndroidOnly,
  wifiLinuxNoBackend,
  // ... future
}
```

Presentation `failure.code`'a switch → l10n.

**ARB key sayısı:** ~6

---

### 4. ✅ EvilTwinExplanation (B8a.3) — TAMAMLANDI (8c v1'de yapıldı)
UI'da `assessment` üzerinden l10n switch zaten yapılıyordu; `EvilTwinExplanation`'ın 7/8 field'ı dead code idi. Sadeleştirildi (sadece `confidenceLabel`).

---

## Toplam Scope (Sürüm Sonrası)

| Görev | Dosya değiştirme | ARB key (EN+TR) | DE/KU (untranslated) | Tahmini süre |
|---|---|---|---|---|
| HostTrust | 3 | ~24 | listede | 1.5 saat |
| network_scan_bloc | 1 + ARB | 6 | listede | 0.5 saat |
| Wi-Fi Failure code | 3 + ARB | 12 | listede | 1 saat |
| **Toplam** | **7** | **~42** | 30 metin | **~3 saat** |

## Yöntemsel Notlar

- Pattern referansı: `lib/features/security/presentation/extensions/vulnerability_extensions.dart` — `ruleId` switch → l10n.
- Domain layer entity'sine **`code` ekle, eski String field'ları korunaklı tut** (backward compatibility) → her iki kaynak da çalışır → sonra String field'ı sil.
- TR çevirilerini ben (geliştirici) yaparım; DE/KU `untranslated_keys_list.md`'ye eklenir.
- Her refactor sonrası `flutter analyze` + smoke test.

## Play Store Compliance Etkisi

- ❌ Sürüm engelleyici değil — kullanıcı seçtiği dilde hata mesajı/etiket görmez, İngilizce alır.
- ⚠️ UX kalitesi: Türk/Alman pazarda profesyonel görünüm açısından önemli.
- ✅ Hiçbir veri akışı veya gizlilik etkisi yok — sadece görüntü.
