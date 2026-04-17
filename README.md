# Torcav

**Torcav**, kullanıcının *sahip olduğu veya tarama yetkisi bulunan* Wi-Fi ve LAN ağlarını pasif olarak analiz etmek için tasarlanmış, defansif odaklı bir Flutter mobil uygulamasıdır. Uygulama; deauth, brute-force, credential capture, monitor-mode istismarı, paket enjeksiyonu veya başka herhangi bir **aktif saldırı** vektörünü içermez. Tüm bulgular pasif gözlem (beacon listeleme, ARP tablosu okuma, TCP connect scan, DNS sorgu gözlemi) ve heuristik analiz üzerinden üretilir.

---

## 1. Proje Değerlendirme Planı

Bu proje değerlendirmesi, her feature'ı tek tek aşağıdaki sorulara cevap verecek şekilde kendi README'sinde belgeler:

1. **Bu feature ne işe yarıyor?** — Kullanıcıya sunduğu değer ve rol.
2. **Yaptıkları neler?** — Domain / data / presentation ayrımıyla somut kabiliyetler.
3. **Hangi özellik eksik?** — Gelecek iterasyonlar için tespit edilen boşluklar.
4. **Etik / legal olarak neler eklenebilir?** — KVKK, GDPR, TCK 243/244, AB NIS2, FCC/ETSI düzenlemeleri, rıza akışları, veri minimizasyonu, retention politikaları.
5. **Hangi sorunları çözüyor?** — Ölçülebilir kullanıcı faydası ve use-case'ler.

### Değerlendirme Metodolojisi

Her feature için aşağıdaki üç boyutta değerlendirme yapılmıştır:

| Boyut | Ne Kontrol Edilir |
|-------|-------------------|
| **Teknik Olgunluk** | Clean architecture uyumu, domain/data/presentation ayrımı, test edilebilirlik, DI, error handling, isolate kullanımı. |
| **Güvenlik & Gizlilik** | Pasiflik garantisi, kişisel veri (SSID, MAC, hostname, RSSI+konum) işlenme gerekçesi, yerel saklama, şifreleme, retention. |
| **Kullanıcı Deneyimi** | Onboarding, aksesibilite, empty/error state, feedback, çoklu dil. |

### Dosya Düzeni

```
lib/
├── main.dart
├── core/               # DI, l10n, theme, storage, logging, platform channels
└── features/
    ├── ai/             → [README](lib/features/ai/README.md)
    ├── app_shell/      → [README](lib/features/app_shell/README.md)
    ├── dashboard/      → [README](lib/features/dashboard/README.md)
    ├── heatmap/        → [README](lib/features/heatmap/README.md)
    ├── monitoring/     → [README](lib/features/monitoring/README.md)
    ├── network_scan/   → [README](lib/features/network_scan/README.md)
    ├── performance/    → [README](lib/features/performance/README.md)
    ├── reports/        → [README](lib/features/reports/README.md)
    ├── security/       → [README](lib/features/security/README.md)
    ├── settings/       → [README](lib/features/settings/README.md)
    └── wifi_scan/      → [README](lib/features/wifi_scan/README.md)
```

---

## 2. Feature Haritası

| # | Feature | Rol | Durum | Detay |
|---|---------|-----|-------|-------|
| 1 | **wifi_scan** | Çevredeki AP'leri tarayan ana sensör; Wi-Fi 7'ye kadar metadata çıkarır. | Olgun | [lib/features/wifi_scan/README.md](lib/features/wifi_scan/README.md) |
| 2 | **network_scan** | LAN üzerinde host keşfi (ARP, mDNS, UPnP) ve port/servis fingerprint. | Olgun | [lib/features/network_scan/README.md](lib/features/network_scan/README.md) |
| 3 | **security** | Pasif güvenlik skorlaması, WPA/DNS/ARP/captive-portal/deauth heuristikleri, drift tespiti. | Olgun | [lib/features/security/README.md](lib/features/security/README.md) |
| 4 | **ai** | On-device ONNX cihaz sınıflandırıcısı (15 kategori). | Beta | [lib/features/ai/README.md](lib/features/ai/README.md) |
| 5 | **dashboard** | Günlük özet ekran: skor, kanal önerisi, SecurityCore animasyonu, bildirim sheet'i. | Olgun | [lib/features/dashboard/README.md](lib/features/dashboard/README.md) |
| 6 | **monitoring** | Canlı RSSI grafiği, kanal spektrumu, network topology graph, ping. | Olgun | [lib/features/monitoring/README.md](lib/features/monitoring/README.md) |
| 7 | **heatmap** | AR + IMU + barometer tabanlı Wi-Fi sinyal haritası. | Beta / deneysel | [lib/features/heatmap/README.md](lib/features/heatmap/README.md) |
| 8 | **performance** | Cloudflare endpoint'li HTTP speed test (latency, jitter, loaded latency, up/down). | Olgun | [lib/features/performance/README.md](lib/features/performance/README.md) |
| 9 | **reports** | JSON / CSV / HTML / PDF export + paylaşım. | Olgun (kapsam dar) | [lib/features/reports/README.md](lib/features/reports/README.md) |
| 10 | **app_shell** | Onboarding + 3 tab + Operations/Profile hub + drawer. | Olgun | [lib/features/app_shell/README.md](lib/features/app_shell/README.md) |
| 11 | **settings** | Tema, dil, scan davranışı, safety mode, deep scan. | Olgun (privacy UI eksik) | [lib/features/settings/README.md](lib/features/settings/README.md) |

---

## 3. Genel Mimarî

- **Clean Architecture**: her feature `domain` (entity + use-case + repository) / `data` (datasource + repository impl) / `presentation` (bloc + page + widget) şeklinde ayrılmış.
- **DI**: `get_it` + `injectable` (build_runner ile kod üretimi).
- **State**: `flutter_bloc` (`Bloc`/`Cubit`).
- **Functional error handling**: `fpdart` + `dartz` (sınırlı kullanım).
- **Storage**: SQLite (`sqflite` + `sqflite_common_ffi`), SharedPreferences, `flutter_secure_storage` (v10).
- **Theming**: Neon/cyber tema, `google_fonts`, custom shader (`shaders/cyber_post.frag`), `CyberGridBackground`.
- **Localization**: `flutter_localizations` + `intl` + kendi fallback delegate'leri.
- **Machine Learning**: `onnxruntime` on-device inference.
- **Platform channels**: `core/platform/wifi_extended_channel.dart` üzerinden Android native WiFi detail'leri.

---

## 4. Genel Eksikler (Feature-üstü)

- **Test örtüsü sığ**: `test/` dizini mevcut ama kapsamlı bloc/unit test yok (`very_good_analysis` + `bloc_test` + `mocktail` dependency'leri eklenmiş, geniş ölçekli kullanım yok).
- **CI/CD**: `.github/workflows/` veya pipeline konfigürasyonu repo içinde görülmüyor.
- **Error reporting / crash analytics**: Sentry / Firebase Crashlytics entegrasyonu yok.
- **Accessibility audit**: `Semantics`, `TextScaler`, high-contrast tema gözden geçirilmemiş.
- **Background execution**: security event izleme, speed test scheduling, monitoring alert gibi arka plan senaryoları yok.
- **Deep linking / route tabanlı navigasyon**: `core/router` boş.
- **iOS parity**: Android öncelikli; iOS'ta WiFi scan, LAN discovery, barometer behavior belirgin şekilde kısıtlı — durum kullanıcıya belirtilmeli.
- **Dökümantasyon**: API seviyesinde dartdoc üretilmemiş; her feature README'si ilk doküman adımı.

---

## 5. Etik / Legal Genel Politika Önerileri

Aşağıdaki politika maddeleri feature-bazlı README'lerde ayrıntılandırılmıştır; genel olarak uygulama şunları benimsemelidir:

1. **Authorized-use first**: Uygulama ilk açıldığında ve her *potansiyel olarak müdahaleci* işlemde (deep scan, LAN discovery, port scan) kullanıcı "bu ağı taramaya yetkim var" onayı vermelidir. Bu kayıt lokal, değiştirilemez bir audit log'a düşer.
2. **Passive-only guarantee**: Kod yorumlarında, UI'da ve Terms of Use'da uygulamanın aktif saldırı yapmadığı açık ve test edilebilir biçimde beyan edilir; CI regression testi ile enforce edilir.
3. **Data minimization (KVKK/GDPR m.5)**: Varsayılan olarak rapor/export akışlarında BSSID/MAC maskeleme, SSID hash'leme açık.
4. **Local-only**: Hiçbir kullanıcı verisi uygulamadan dışarı (bulut, analytics, third-party) çıkmaz. Kullanıcı açıkça "paylaş" dediğinde, paylaşım hedefi şeffaf biçimde bildirilir.
5. **Retention policy**: Settings > Privacy altında her veri türü (tarama geçmişi, heatmap oturumu, speed test geçmişi, güvenlik olayları, rapor dosyaları) için süre ayarı ve "şimdi sil" butonu.
6. **Consent withdrawal**: Kullanıcı herhangi bir zamanda rıza çekebilir; tüm yerel veri tek tıkla temizlenir (data subject right to erasure).
7. **Right to information**: Settings > About'ta uygulamanın hangi verileri okuduğu, nereden (asset, OS API, network) aldığı ve hangi feature'ın hangi veriyi kullandığı tabloya yazılır.
8. **Disclaimer/feragat**: Güvenlik bulguları, hız ölçüm sonuçları ve heatmap çıktıları hukuki/mühendislik belgesi değildir; kullanıcının bunları 3. kişilere sunarken kendi sorumluluğunda yorumlaması gerektiği belirtilir.
9. **Bölgesel regülasyon uyumu**: Türkiye (BTK, 5651, TCK), AB (GDPR, NIS2, RED), ABD (FCC, CFAA). Kullanıcının bulunduğu yargı bölgesine göre uyarı metinleri.
10. **Üçüncü taraf verisi koruma**: Komşu AP SSID/BSSID'si, diğer kullanıcıların cihaz hostname'leri (ör. "Ayşe'nin iPhone'u") kişisel veri sayılır; default anonymization + export-öncesi onay.
11. **Minors / eğitim bağlamı**: Uygulamanın 13 yaş altı için tasarlanmadığı ve eğitim amaçlı kullanım için yetkili gözetim gerektirdiği belirtilir.

---

## 6. Hangi Sorunları Çözüyor? (Genel)

- **Görünürlük**: Ev/küçük ofis ağında "ne var, ne yapıyor?" sorusuna objektif cevap.
- **Güvenlik farkındalığı**: Teknik bilgisi olmayan kullanıcıyı WPA2/WPA3, DoT/DoH, MAC randomization, ARP spoofing gibi kavramlarla risk bağlamında tanıştırır.
- **Performans izleme**: "İnternetim yavaş" şikayetini ölçümlü delile dönüştürür.
- **Kapsama haritası**: Ev içi ölü bölgelerin tespiti ve AP konumlandırma kararı.
- **Envanter & değişim**: Yeni ortaya çıkan cihaz (rogue device) tespiti.
- **Offline çalışma**: Tüm analiz cihaz üzerinde (ONNX dahil); bulut bağımlılığı yok.
- **Eğitim değeri**: Ağ güvenliği öğrenmek isteyen öğrenciler için düşük riskli, pasif bir laboratuvar.
- **Delil üretimi**: ISS ile pazarlık, iç denetim, mahalli teknik destek için zaman damgalı rapor akışı.

---

## 7. Çalıştırma

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### İzinler

- Android: `ACCESS_FINE_LOCATION` (Wi-Fi tarama zorunluluğu), `CAMERA` (heatmap), `INTERNET`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`.
- iOS: `NSLocationWhenInUseUsageDescription`, `NSCameraUsageDescription`, `NSLocalNetworkUsageDescription`, `NSBonjourServices`.

### Asset'ler

- `assets/models/device_classifier.onnx` — AI feature
- `assets/data/` — Vulnerable router JSON, OUI snapshot (bağımlılık `unified_flutter_features` üzerinden)
- `shaders/cyber_post.frag` — post-process shader

---

## 8. Lisans ve Sorumluluk

Bu proje bir araştırma / eğitim / kişisel kullanım uygulamasıdır. Kullanıcı, Torcav'ı çalıştırdığı ağın sahibi olmak veya yazılı tarama yetkisine sahip olmakla yükümlüdür. Uygulamanın üçüncü taraflara ait ağlara karşı kullanılması yürürlükteki mevzuatı ihlal edebilir (Türk Ceza Kanunu 243/244, AB Directive 2013/40, ABD Computer Fraud and Abuse Act). Geliştirici, bu tür kullanımdan doğabilecek sonuçlardan sorumlu değildir.
