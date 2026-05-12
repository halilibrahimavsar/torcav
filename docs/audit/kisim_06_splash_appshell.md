# Kısım 6 — Splash & App Shell

> Kapsam: `lib/features/splash/` (2 dosya), `lib/features/app_shell/` (5 dosya + README)

## Boyutlar
| Dosya | Satır |
|---|---|
| `splash_page.dart` | 424 |
| `starfield_background.dart` | 132 |
| `onboarding_page.dart` | **670** (5 sayfalık akış) |
| `app_shell_page.dart` | 467 |
| `operations_hub_page.dart` | 256 |
| `profile_hub_page.dart` | 367 |
| `cyber_drawer.dart` | 341 |

---

## Bulgular

### B6.1 — `OnboardingPage` ilk açılışta tetiklenmiyor (K) — **Play Store ihlali**
**Kanıt:**
```
grep -rn "OnboardingPage" lib/
  lib/features/settings/presentation/pages/settings_page.dart:777  ← sadece settings'ten
  lib/features/app_shell/presentation/pages/onboarding_page.dart   ← tanım yeri

grep -rn "onboarding_complete" lib/
  lib/features/settings/.../settings_page.dart:775  ← false set ederek tekrar açma
  lib/features/app_shell/.../onboarding_page.dart:42  ← true set ederek bitirme
```
**Tespit:**
- `SplashPage._runInitSequence` doğrudan `AppShellPage`'e `pushReplacement` yapıyor.
- **`onboarding_complete` Hive flag'i hiç okunmuyor.**
- Yeni kullanıcı ilk açılışta:
  - **Terms of Service kabul ETMEDEN** uygulamayı kullanıyor
  - **Privacy Policy onayı ALMADAN** veri toplama başlıyor
  - **Yaş onayı** (`onboardingConfirmAge`) atlanıyor
  - **"Yetkili kullanıcıyım"** onayı (`onboardingConfirmPermission`) atlanıyor — Play Store *Network Tools* policy ŞARTI
  - Network context tercihi (home/public/guest) alınmıyor

**Play Store etkisi:** **Sürüm engelleyici.**
- *Network Tools policy*: "App must ... obtain explicit user permission and acknowledgement that they are authorized to access the target network"
- *Privacy*: ToS / Privacy Policy kabul ekranı zorunlu (özellikle veri toplayan apps için)

**Aksiyon:** SplashPage'de routing kararı:
```dart
final hasOnboarded = getIt<HiveStorageService>().get<bool>('onboarding_complete') ?? false;
Navigator.of(context).pushReplacement(
  PageRouteBuilder(pageBuilder: (_, __, ___) =>
    hasOnboarded ? const AppShellPage() : const OnboardingPage(), ...),
);
```

### B6.2 — Onboarding'de izinler runtime'da istenmiyor (Y) — sadece bilgi metni
**Kanıt:** `onboarding_page.dart` 215-227, `_PermissionsPage`:
```dart
class _PermissionsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return _OnboardingSlide(
      icon: Icons.location_on_rounded,
      title: context.l10n.onboardingLocationTitle,
      body: context.l10n.onboardingLocationBody,
      color: ...);
  }
}
```
**Tespit:** Sayfa kullanıcıya "Wi-Fi taraması için konum izni gerekli" diyor, ama hiçbir buton/aksiyon yok. `permission_handler` import edilmemiş. Kullanıcı "Next" deyip geçiyor; izin daha sonra Wi-Fi scan ekranında istenecek.
**Compliance:** Play Store policy "izin istenmeden önce neden gerekli olduğunu açıkla" — ardından **aynı oturumda izin iste** uyumlu yorum. Mevcut akış: bilgi → bambaşka ekrana git → orada izin iste. Kullanıcı bağlamı kaybediyor.
**Aksiyon:** _PermissionsPage'e "Grant location permission" butonu eklenebilir, ama bu çok büyük UX değişikliği. **Kısım 7 (Wi-Fi scan)** içinde detay verilecek; onboarding sırasında ek prominent disclosure dialog kullanımı düşünülebilir.

### B6.3 — POST_NOTIFICATIONS prominent disclosure + istek YOK (Y) — Kısım 5'ten taşınan TODO
**Kanıt:** Onboarding'in `_PermissionsPage`'i sadece konumdan bahsediyor. Bildirim izninden hiç bahsetmiyor. `NotificationService.requestAndroidNotificationPermission()` Kısım 5'te eklendi ama çağrılmıyor.
**Compliance:** Android 13+ POST_NOTIFICATIONS runtime izni manifest'te tanımlı ama hiç istenmedi → ilk security event'te bildirim sessizce kaybolur.
**Aksiyon:** Onboarding'de yeni bir sayfa (`_NotificationsPage`) veya `_PermissionsPage` içine ek bölüm:
- Title: "Security Alerts" (l10n)
- Body: "Konum güvenlik olaylarını bildirim olarak almak için..." (l10n)
- Butonu: "Bildirimleri etkinleştir" → ProminentDisclosureDialog → `NotificationService.requestAndroidNotificationPermission()`

### B6.4 — Splash'ta `dbHealedNotice` flag check YOK (Y) — Kısım 5'ten taşınan TODO
**Kanıt:** `splash_page.dart` `_runInitSequence` heal flag kontrolü içermiyor. Kısım 5'te `AppDatabase.healedFlagKey` Hive'a yazılıyor ama hiç okunmuyor.
**Aksiyon:** Splash → AppShell geçişinden önce:
```dart
final hive = getIt<HiveStorageService>();
final healedAt = hive.get<String>(AppDatabase.healedFlagKey);
if (healedAt != null) {
  await hive.delete(AppDatabase.healedFlagKey);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.dbHealedNotice), duration: const Duration(seconds: 6)),
    );
  }
}
```
**Not:** SnackBar göstermek için AppShell'in oluşmasını bekleyebiliriz. Daha basit yol: heal notice'i AppShell `initState`'inde gösterelim.

### B6.5 — Splash'ta 8 hardcoded statik label (D)
**Kanıt:** `find_strings.py lib/features/splash/`:
```
splash_page.dart:182 'BUILD'
splash_page.dart:190 'PLATFORM'
splash_page.dart:218 'VAULT'
splash_page.dart:224 'SESSION'
splash_page.dart:233 'RETENTION'
splash_page.dart:249 'LAST SCAN'
splash_page.dart:259 'VAULT STATUS'
splash_page.dart:260 'AES-256-GCM'
```
**Tespit:** Bunların 7'si statik gösterge etiketi (telemetry görünümü için), 1'i ('AES-256-GCM') teknik standart. Splash 800ms gösteriliyor — UX açısından lokalize edilse de iyi olur ama düşük öncelik.
**Aksiyon:** Sürüm sonrasına ertele (Play Store engelleyici değil). Çevirisi bile gereksiz olabilir — TR/DE/KU'de "VAULT" çevrilmek istenir mi tartışılır.

### B6.6 — `_buildVersion = 'v1.0.4'` hardcoded (O) — sürüm uyumsuzluk riski
**Kanıt:** `splash_page.dart:39`:
```dart
static const String _buildVersion = 'v1.0.4';
```
**Tespit:** `pubspec.yaml` versiyonu ile **manuel senkronize tutuluyor**. Bir sonraki sürümde unutulursa kullanıcı yanlış versiyon görür.
**Aksiyon:** `package_info_plus` paketi ile dinamik okuma:
```dart
final info = await PackageInfo.fromPlatform();
final version = 'v${info.version}';
```
`pubspec.yaml`'a `package_info_plus: ^8.x` eklenecek. **Bu kısımda düzeltilecek.**

### B6.7 — Splash 800ms minimum görünüm süresi (D) — bilgi
**Kanıt:** `splash_page.dart:117-122`:
```dart
const minVisualMs = 800;
final elapsed = stopwatch.elapsedMilliseconds;
if (elapsed < minVisualMs) {
  await Future.delayed(Duration(milliseconds: minVisualMs - elapsed));
}
```
**Tespit:** Yorum "NOT artificial loading theatre, anti-flicker" diyor — makul. 800ms düşük; çok hızlı boot'ta beyaz flash olabilir.
**Aksiyon:** Yok. Sadece bilgi.

### B6.8 — Hub'lar ve drawer temiz (✅)
**Kanıt:**
- `grep "debugPrint\|TODO\|FIXME\|XXX\|print(" lib/features/app_shell/presentation/{pages,widgets}/`: 0 sonuç
- `find_strings.py lib/features/app_shell/`: **0 hardcoded**
- Tüm metinler `context.l10n.*` kullanıyor

---

## Compliance Özeti

| Konu | Durum | Şiddet |
|---|---|---|
| Onboarding zorunlu tutuluyor mu? | ❌ HAYIR (B6.1) | **K** |
| ToS / Privacy onayı şart mı? | ❌ İlk açılışta atlanıyor | **K** |
| "Authorized user" onayı | ❌ İlk açılışta atlanıyor (Network Tools policy) | **K** |
| Yaş onayı | ❌ İlk açılışta atlanıyor | Y |
| Permission disclosure (konum) | ⚠️ Var ama runtime istek yok (B6.2) | Y |
| Permission disclosure (bildirim) | ❌ Yok (B6.3) | Y |
| Heal flag bilgilendirme | ❌ Yok (B6.4) | Y |

---

## Kanıt Tablosu

| Bulgu | Komut / Konum | Kanıt |
|---|---|---|
| B6.1 | `grep -rn "OnboardingPage" lib/` | Sadece **settings_page.dart:777** referansı; splash veya app_shell'den çağrı YOK |
| B6.1 | `grep -rn "onboarding_complete" lib/` | Sadece **save** çağrıları (settings, onboarding); **read** çağrısı yok |
| B6.2 | `grep -rn "permission_handler\|Permission\." lib/features/app_shell/` | **0 sonuç** — onboarding izin istemiyor |
| B6.2 | `pubspec.yaml` | `permission_handler: ^12.0.1` var ✅ (kullanılmıyor sadece) |
| B6.3 | onboarding_page.dart 215-227 | `_PermissionsPage` sadece konum metni |
| B6.4 | splash_page.dart 81-135 | `AppDatabase.healedFlagKey` okuma yok |
| B6.5 | `find_strings.py lib/features/splash` | 8 hardcoded statik label |
| B6.6 | splash_page.dart:39 | `_buildVersion = 'v1.0.4'` hardcoded |
| ✅ B6.8 | `find_strings.py lib/features/app_shell/` | 0 hardcoded |

---

## Uygulanan Düzeltmeler (v2)

1. ✅ **B6.1 (K) — SplashPage routing düzeltildi**
   - `_runInitSequence` sonunda `getIt<HiveStorageService>().get<bool>('onboarding_complete')` okunuyor
   - `false` ise `OnboardingPage`, `true` ise `AppShellPage`
   - **Play Store ihlali ortadan kalktı**: yeni kullanıcı ToS/Privacy/Age/Authorization onayı vermeden uygulamayı kullanamaz
2. ✅ **B6.3 (Y) — Yeni `_NotificationsPage` onboarding'e eklendi**
   - 5 → **6 sayfa** (Welcome → Permissions → **Notifications** → Tour → NetworkContext → Done)
   - `Icons.notifications_active_rounded` + başlık + body + "Bildirimleri etkinleştir" FilledButton
   - Butona basınca `getIt<NotificationService>().requestAndroidNotificationPermission()` (Kısım 5'te eklenmişti)
   - 4 yeni ARB key (4 dilde): `onboardingNotificationsTitle/Body/Enable/Skip`
3. ✅ **B6.4 (Y) — AppShellPage initState'te heal SnackBar**
   - `WidgetsBinding.addPostFrameCallback` ile heal flag okunup gösteriliyor
   - SnackBar 6 saniye, `dbHealedNotice` ARB (Kısım 5'te 4 dilde hazırdı)
4. ✅ **B6.6 (O) — `package_info_plus 8.1.0` eklendi**
   - `pubspec.yaml` dependency
   - Splash artık `PackageInfo.fromPlatform().version` okuyor; hardcoded `v1.0.4` kalktı
   - `_buildVersion` artık `'v${info.version}'` dinamik

## Ertelenenler

- **B6.2 (Y)** — Konum izni onboarding runtime istek: `_PermissionsPage` hâlâ sadece bilgi metni. `wifi_scan_page` zaten ProminentDisclosureDialog ile izin istiyor; bu Kısım 7'de derinleştirilecek.
- **B6.5 (D)** — Splash 8 hardcoded label ("VAULT", "SESSION" vb.): statik telemetry görünümü, sürüm sonrasına ertelendi.
- **B6.7 (D)** — 800ms minimum görünüm: bilgi amaçlı, değişiklik gerekmiyor.

## Eklenen / Değişen Dosyalar

- `pubspec.yaml` — `package_info_plus: ^8.1.0`
- `lib/features/splash/presentation/pages/splash_page.dart` — onboarding routing + dinamik versiyon
- `lib/features/app_shell/presentation/pages/app_shell_page.dart` — heal SnackBar (initState)
- `lib/features/app_shell/presentation/pages/onboarding_page.dart` — `_NotificationsPage` + 6 sayfa
- `lib/core/l10n/app_*.arb` — 4 yeni key (4 dilde)

**Kısım 6 bulgu sayısı: 8** — **1 K**, 3 Y, 2 O, 1 D, 1 ✅
**Düzeltme: 4/8 (kritik B6.1 dahil tümü uygulandı; 4'ü ileri kısımlara veya sürüm sonrasına ertelendi).**

flutter analyze: temiz
