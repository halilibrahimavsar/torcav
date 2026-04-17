# Settings Feature

Uygulama seçenekleri: tema, dil, tarama davranışı, güvenlik/safety modu, deep-scan toggle.

## Bu Feature Ne İşe Yarıyor?

`settings` feature, kullanıcının **Torcav'ın çalışma davranışını** değiştirmesini sağlar. Görünüm tercihleri (tema, dil) ile teknik tercihler (scan interval, scan pass sayısı, WiFi backend, gizli SSID dahil etme, strict safety mode, otomatik tarama, deep scan) tek yerde toplanır ve `SharedPreferences` üzerinde persist edilir.

## Yaptıkları Neler?

### Domain

- **AppSettings** entity:
  - `scanIntervalSeconds` (varsayılan 30)
  - `defaultScanPasses` (varsayılan 3)
  - `defaultBackendPreference`: `WifiBackendPreference` enum (auto / native / plugin)
  - `includeHiddenSsids`: gizli ağlar listelensin mi
  - `strictSafetyMode`: pasif-only mod; deep scan ve active probing kapalı kalır
  - `autoScanEnabled`: ekran açılınca otomatik tarama
  - `isDeepScanEnabled`: banner grab + exposure analizi için agresif mod
- **AppSettingsStore**:
  - `SharedPreferences` üzerinde JSON olarak tutar.
  - `StreamController<AppSettings>.broadcast()` ile değişiklikleri yayımlar — Bloc'lar dinler.

### Presentation

- **SettingsPage** (638 satır): Appearance (dil, tema), Scanning Behavior (interval, passes, backend), Safety & Privacy (strict mode, deep scan, hidden SSIDs), About bölümleri.
- Tema değişimi `ThemeCubit` (core) üzerinden — light/dark + renk varyantları.
- Dil değişimi `LocaleCubit` (core) üzerinden — `intl` ve `AppLocalizations` delegate'leri.

## Hangi Özellik Eksik?

- **Import / Export ayarları**: kullanıcı ayarlarını JSON olarak dışa aktaramıyor veya başka cihaza taşıyamıyor.
- **Per-network settings**: "ev" ağında deep scan aç, "kafe" ağında kapat gibi koşullu ayar yok.
- **Schedule-based**: "gece 02:00'da tarama yapma" gibi zaman kısıtı yok.
- **Battery/data saver**: mobil veri üzerindeyken hangi feature'ların kısıtlanacağını kullanıcı seçemiyor.
- **Accessibility**: yazı boyutu çarpanı, yüksek kontrast, motion-reduction bayrakları yok (ama Flutter `MediaQuery.textScaler` ile implicit çalışıyor olabilir).
- **Data retention**: "tarama geçmişini N gün tut", "raporları M gün tut" ayarı yok; Reports/Performance/Heatmap geçmişi sınırsız birikiyor olabilir.
- **Wipe all data**: tüm yerel veriyi silme tek tıklık buton yok (GDPR "right to erasure" için kritik).
- **Telemetry consent toggle**: analytics opt-in/out yok (zaten analytics bağımlılığı yok, ancak gelecek için açık uç).
- **Notification channel ayarları**: hangi security event kategorisi bildirim göndersin seçimi yok.
- **Backup ayarları**: Android AutoBackup / iOS iCloud'a dahil / hariç tutma kontrolü yok; hassas veriler default dışı kalmalı.
- **Debug panel**: core/logging pane'ine giriş yok — beta testçiler için faydalı olur.

## Etik / Legal Olarak Neler Eklenebilir?

- **Strict Safety Mode'un default ON olması**: `strictSafetyMode = true` zaten default, iyi; ancak deep scan açılırken *ek bir onay diyaloğu* gelmeli ("agresif tarama yalnızca yetkili olduğun ağda yapılmalıdır, devam et?") + kullanıcı IP onayı.
- **KVKK / GDPR uyumu hub'ı**: Settings içinde ayrı bir "Gizlilik" bölümü olmalı:
  - Rıza çekme (withdraw consent),
  - Tüm yerel veriyi silme,
  - Veri türlerine göre export,
  - Saklanan ağların listesi + tek tek silme.
- **Yasal feragat sayfası**: "Bu uygulama yalnızca yetkili ağlar için kullanılmalıdır. Kullanıcı, uygulamayı 3. taraf ağlarda kullanarak yürürlükteki yasaları ihlal etmemekle yükümlüdür" metni Settings > About içinde link olarak bulunmalı.
- **Kullanıcı türü seçimi**: Home / Small Business / Educational — her biri farklı default ve uyarı düzeyi getirir (ör. business → "site survey yetkilendirme belgesi yüklendi mi?" sorusu).
- **Yaş doğrulama**: 13 yaş altı kullanıcı olmadığı beyanı (COPPA).
- **Telemetri opt-in metni**: gelecekte crash reporting eklenirse default OFF ve metin şart.
- **Değişiklik günlüğü / ToS versiyonu**: Settings > About içinde güncel Terms of Service versiyonu gösterilmeli; değiştiğinde yeniden onay istenmeli.
- **Dil değiştirme notu**: hukuki feragatlerin çevirisi noter tasdikli olmayabilir; kullanıcı uyarılmalı (özellikle Türkiye için KVKK metin standardı).

## Hangi Sorunları Çözüyor?

- **Tek dokunuş güvenlik**: `strictSafetyMode` ile kullanıcı "hiçbir şey aktif olmasın" durumuna ayarlayabiliyor.
- **Power user esnekliği**: scan interval / pass sayısı / backend seçme, ileri kullanıcının uygulamayı özelleştirmesini sağlıyor.
- **Merkezi uyumluluk noktası**: gelecekte KVKK/GDPR uyum kontrolü, retention gibi politikalar eklenirken yeri hazır.
- **Dil erişilebilirliği**: TR/EN (ve uzun vadede diğerleri) — uygulamanın global kullanıcı kitlesine açılmasını sağlıyor.
- **Tema seçimi**: kullanıcı konforu + OLED ekran enerji tasarrufu.
