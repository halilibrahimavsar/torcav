# App Shell Feature

Uygulamanın iskeleti — ilk açılış (onboarding), ana navigasyon (bottom nav + PageView), yan menü (drawer), operasyonlar ve profil hub'ları.

## Bu Feature Ne İşe Yarıyor?

`app_shell` feature, Torcav'ın **ana kabuğudur**. Kullanıcı uygulamayı ilk açtığında karşılaştığı her şey bu feature altındadır: onboarding ekranları, alt gezinme çubuğu, drawer, tab'lar arası geçişler ve alt-ekranlara yönlendirme. Diğer tüm feature'lar (Dashboard, WiFi Scan, Security vb.) bu kabuktan başlatılır.

Özetle: **navigasyonun ve kullanıcı yolculuğunun tek kaynağı**.

## Yaptıkları Neler?

1. **Onboarding akışı** (`onboarding_page.dart`):
   - 4 sayfalı sunum: Welcome → Permissions → Tour → Done.
   - `SharedPreferences` üzerinde `onboarding_complete` bayrağı bırakır; ikinci açılışta atlanır.
   - İzin isteklerini kullanıcıya "neden istediğimizi" açıklayarak sunar (location, wifi scan, camera vb.).
2. **Ana kabuk** (`app_shell_page.dart`):
   - 3 sekmeli neon bottom bar: `Dashboard` │ `Discovery` │ `Operations`.
   - Discovery sekmesi içinde alt-tab olarak **WiFi** ve **LAN** sayfaları.
   - `PageView` + `NeverScrollableScrollPhysics` → sekmeler swipe ile değil yalnızca alttaki neon shuttle ile değişir (tutarlı deneyim).
   - Animasyonlu "shuttle" (hareketli seçili indikatörü) + glow efektleri.
3. **Operations Hub** (`operations_hub_page.dart`):
   - Secondary feature'ları kartlar halinde barındırır: Performance (Speed Test), Defense (Security Center), Topology, Heatmap, Vulnerability Lab, Reports, Settings.
   - Grid layout + `StaggeredEntry` animasyonları.
4. **Profile Hub** (`profile_hub_page.dart`):
   - Kullanıcının SSID / IP / Gateway bilgilerini `network_info_plus` üzerinden gösterir.
   - En son tarama oturumunu (`ScanSessionStore.latest`) özet olarak listeler.
   - Tema seçimi, dil seçimi gibi hızlı aksiyonlar.
5. **Cyber Drawer** (`cyber_drawer.dart`):
   - Sol yan menü; profil kısayolu, sistem durumu kartı, feature menüleri.
   - `CyberGridBackground` + neon ayraçlar ile görsel kimliği taşır.
6. **Merkezi rota tablosu**: `_navigateTo(String destination)` — string route isimleri (`dashboard`, `wifi`, `lan`, `operations`, `monitor/topology`, `security`, `reports`, `settings`, `profile`) tek bir switch üzerinde toplanmış.

## Hangi Özellik Eksik?

- **Deep-link / URI route desteği yok**: `core/router` klasörü boş. `go_router` veya Flutter Navigator 2.0 ile URL tabanlı navigasyon yok; bildirim ya da pano paylaşımından direkt bir ekrana açılma yapılamıyor.
- **State restoration yok**: uygulama arka plandan dönünce seçili sekme/tab kaybolabiliyor (`RestorationMixin` kullanılmıyor).
- **Accessibility (a11y)** zayıf: neon ikonların `Semantics` etiketi yok, `TalkBack/VoiceOver` için ek dokümantasyon gerekiyor; kontrast oranları (WCAG AA) doğrulanmamış.
- **Onboarding gözden geçirilebilir değil**: bitirdikten sonra Settings'ten yeniden onboarding'i açma seçeneği yok; güncelleme sonrası "yeni özellik" turu gösterilemiyor.
- **Tab reordering / customization yok**: kullanıcı favori feature'ını ana sekmeye alamıyor.
- **Drawer ile bottom bar arasında çift menü**: aynı ekranların iki giriş noktası var; bir bilgi mimarisi sadeleştirmesi gerekli.
- **Tam bir empty-state yok**: ilk açılışta hiç tarama yoksa Dashboard/Discovery içinde "Başlamak için..." çağrısı daha belirgin olmalı.
- **Error boundary yok**: alt sayfalardan biri exception atarsa tüm kabuk çökebilir; `ErrorWidget.builder` + global `FlutterError.onError` bağlantısı yok.

## Etik / Legal Olarak Neler Eklenebilir?

- **Permissions rationale ekranı zorunlu olmalı**: onboarding'in `_PermissionsPage` kısmı, Android 13+ ve iOS için her iznin *neden* istendiğini, *reddedilirse* hangi özelliğin kısıtlanacağını açıkça göstermelidir (PlayStore/AppStore politikaları için kritik).
- **Kullanım Şartları & Gizlilik Sözleşmesi onayı**: onboarding sonunda kullanıcının açıkça onay vermesi gereken ve metnin kendisine link veren adım — yasal olarak KVKK/GDPR açık rıza oluşturur.
- **"Yalnızca kendi ağında kullan" onayı**: uygulama taramaya başlamadan önce kullanıcıdan `"Bu ağı taramaya yetkim var"` checkbox'ı almalı (bilhassa Turkish Cyber Crime Law 5651 ve TCK 243/244 açısından kendini koruyucu bir kayıt).
- **Tema/dil/telemetri kontrolleri onboarding'de**: kullanıcı ilk açılışta analitik/telemetri'yi opt-in/opt-out edebilmeli (varsayılan opt-out).
- **Accessibility beyanı**: EAA (European Accessibility Act, 2025 yürürlük) kapsamında erişilebilirlik bilgisi sayfası — drawer'a küçük bir "Accessibility" linki.
- **Çocuk güvenliği**: uygulama COPPA/13 yaş altı kullanıcılar için tasarlanmadığını onboarding'de belirtmeli.
- **Değişiklik günlüğü / "what's new"**: güncelleme sonrası drawer'dan açılabilir; yasal notları (politika değişikliği) kullanıcının görmesini zorunlu kılar.

## Hangi Sorunları Çözüyor?

- **Feature dağınıklığı**: 11 feature'ı tek tutarlı kabukta toplayarak kullanıcının kaybolmasını engelliyor.
- **İlk kullanım sürtünmesi**: izin ve beklenti yönetimi onboarding ile baştan çözülüyor; ilk taramadan önce user mental model oluşuyor.
- **Navigasyon tutarlılığı**: string-route tablosu ile drawer, dashboard kartları ve bottom-bar aynı hedeflere gidiyor — yeni feature eklemek sadece route'u `_navigateTo` switch'ine eklemekle sınırlı.
- **Marka kimliği**: neon/cyber görsel dili (shuttle, glow, staggered entry) tüm alt feature'lara tutarlı olarak taşınıyor.
- **Hızlı erişim**: Operations Hub, ikincil ama kritik feature'ları (Vulnerability Lab, Heatmap, Reports) üç tıktan birine indiriyor.
