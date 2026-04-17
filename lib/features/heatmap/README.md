# Heatmap Feature

AR (Augmented Reality) kamera görünümü + hareket sensörleri ile fiziksel alan üzerinde Wi-Fi sinyal gücü haritası çıkarır.

## Bu Feature Ne İşe Yarıyor?

`heatmap` feature, kullanıcının telefonunu ağdaki **Wi-Fi sinyal gücünü fiziksel bir harita üzerinde görselleştirmek** için kullanmasını sağlar. Kullanıcı evinde/ofisinde yürürken telefonun kamerası + IMU (Inertial Measurement Unit) ile pozisyonu tahmin eder, bağlı ağa ait RSSI'yi kaydeder ve renk-kodlu bir "sıcaklık" haritası üretir.

Amaç: "evin A odasında internet çekmiyor, neden?" sorusunu objektif, ölçümlenebilir ve görselleştirilebilir bir cevaba dönüştürmek.

## Yaptıkları Neler?

### Domain katmanı

1. **HeatmapSession & HeatmapPoint** (entities): oturumun kendisi, her noktanın `(x, y, rssi, timestamp, heading)` bilgisini taşıyan küçük kayıtlar.
2. **SignalTracker**: cihazın bağlı olduğu SSID/BSSID'sine ait RSSI'yi belirli bir oranda örnekler, yuvarlanır ortalama ve standart sapma üretir.
3. **PositionTracker**: telefonun ivmeölçer + pusula verisinden "adım tespiti" ve heading (yön) çıkarır — GPS yok, her şey relatif.
4. **HeatmapManager** (orchestrator): `SignalTracker` + `PositionTracker` + `BarometerDataSource` (kat değişimi yakalamak için) + `HeatmapRepository`'yi koordine eder. Yeni oturum başlatma, noktalara iliştirme, oturum sonlandırma.
5. **SurveyGuidanceService**: kullanıcıya "şu an yavaş yürü", "sarsma", "daha az dens bölgeye git" gibi canlı talimatlar (gate'ler: `MEASUREMENT_LOCK`, `SPARSE_REGION`, `READY`).
6. **SignalTier**: RSSI → renk bantları (örn. `>-50 dBm = güçlü`, `<-80 dBm = zayıf`).

### Data katmanı

- **ar_camera_pose_datasource**: kameranın cihaz üzerindeki göreli konumunu (x,y,z) yakalar — platform kanalı üzerinden native AR (ARCore/ARKit iskeleti).
- **position_datasource**: IMU (ivmeölçer + `flutter_compass`) üzerinden pedometer tarzı adım sayımı.
- **barometer_datasource**: basınç sensöründen kat değişimini yakalar.
- **heatmap_local_data_source**: SQLite (sqflite) ile oturumları yerel olarak saklar.

### Presentation

- **heatmap_page.dart** (504 satır): ana sayfa, AR camera view + overlay.
- **heatmap_canvas.dart** (1131 satır): CustomPainter ile 2D heatmap çizim motoru — Gaussian blur, interpolation, renk rampası.
- **ar_hud_overlay.dart** (454 satır): AR HUD — reticle, measurement lock banner, sparse-region ok, live-signal tag, SSID chip, mini-map.
- **survey_pilot_card.dart**, **survey_conclusion_overlay.dart**: kullanıcıya tarama öncesi rehber, bitiminde özet.
- **session_picker_sheet.dart**: eski oturumları listeleme ve yükleme.

## Hangi Özellik Eksik?

- **Gerçek AR dokunuşu sınırlı**: `ar_scene_view.dart` 24 satırdan ibaret; ARCore/ARKit düzlem takibi (plane tracking), oclusion, mesh reconstruction yok — "AR" daha çok *kamera feed + 2D overlay* seviyesinde.
- **SLAM / loop-closure yok**: aynı odaya geri dönüldüğünde drift (ölçüm hatası) düzelmez; uzun oturumlarda x,y koordinatları bozulur.
- **Kat planı (floor plan) desteği çıkarılmış**: git log'a göre floor plan ve wall detection refactor ile silinmiş (`a8cb0c9`, `7b8f177`) — kullanıcı kendi kat planını yükleyemiyor, duvarların sinyal üzerindeki etkisi modellenmiyor.
- **Çok bağlantı desteği yok**: sadece cihazın bağlı olduğu ağ ölçülüyor; çevredeki tüm AP'leri aynı anda harita üzerinde kıyaslama yok.
- **Tahmin (predictive) mod yok**: AP ekleme/kaldırma senaryolarının simülasyonu (what-if) yok.
- **Noktalar arası interpolasyon basit**: `heatmap_canvas` Gaussian blend ile çalışıyor; IDW / kriging gibi daha güçlü yöntemlere yer yok.
- **Dışa aktarma**: oturumu PDF/PNG/KMZ olarak dışa aktarma akışı burada değil, Reports feature'a bağımlı — entegrasyon dokümante edilmeli.
- **Çoklu kat birleştirme**: barometer ile kat farkı algılanıyor ama her kat için ayrı session manuel; otomatik "3. katın heatmap'i" oluşturmuyor.
- **Kalibrasyon**: telefon IMU'su her cihazda farklı; başlangıçta kullanıcıdan referans adım uzunluğu alınmıyor.
- **Otomatik kayıt (auto-sampling) güvenlik şartları**: kamera frame kalitesi veya gyro sarsıntı limiti çok gevşek; kötü veri toplanabilir.

## Etik / Legal Olarak Neler Eklenebilir?

- **Kamera izni açıklaması**: heatmap AR modu kamerayı açıyor; kullanıcıya "görüntü kaydedilmiyor, yalnızca konum tahminine yarıyor" notu ve mümkünse kamera preview'ın blurlanmış/siyah versiyonu ayarlanabilmeli.
- **3. kişi gizliliği**: kamerayla ev içini tararken başka insan veya komşu pencereleri görünebilir — **frame'in saklanmadığı**, sadece pose tahmin edildiği teknik olarak kanıtlanmalı (no-op frame processing testleri, denetlenebilir).
- **Komşu ağ sinyalleri**: Dashboard'ta "komşu ağların heatmap'i" gibi özellikler eklenirse, bu komşunun ağı üzerinde çalışma sayılabilir ve **Türk Ceza Kanunu 243** (bilişim sistemine girme) ve AB NIS2 kapsamında sorun yaratabilir — yalnızca kullanıcının kendi bağlı olduğu BSSID ile sınırlı tutulmalı (zaten öyle, ama README'de vurgulanmalı).
- **Konum verisi**: barometer + ivmeölçer birlikte "indoor positioning" sayılır ve GDPR'a göre konum verisi kabul edilebilir; bu nedenle oturum verileri `local-only`, cloud sync yoksa "export etme" akışında kullanıcı açıkça uyarılmalı.
- **AR kaydın görsel gizliliği**: oturum sonunda arka plan kamera görüntüsü ile birlikte ekran görüntüsü oluşturuluyorsa, silmek için açık buton (`"kamera arka planı olmadan paylaş"`) eklenmeli.
- **Sinyal ölçüm lisansı**: bazı ülkelerde (ABD FCC deneme modu vb.) kablosuz "site survey" ticari amaçlıysa sertifikasyon gerektirir; uygulama "educational / personal use" olarak konumlandırılmalı.
- **Doğruluk iddiası**: RSSI → kapsama haritası olarak sunulurken kullanıcıya "gerçek sinyal ≠ gösterilen ortalama, bu bir tahmindir" notu eklenmeli (yanlış kararlar alınmasın).

## Hangi Sorunları Çözüyor?

- **"Evde sinyal çekmiyor"un nesnelleştirilmesi**: öznel şikayet yerine objektif RSSI haritası.
- **AP yerleştirme kararı**: yeni bir Wi-Fi mesh düğümünü nereye koyacağına veri destekli karar verme.
- **Ölü bölge tespiti**: dead-spot'ları haritada görsel olarak işaret ederek kullanıcıya hedefli aksiyon.
- **Site survey demokratizasyonu**: profesyonel site survey cihazları (Ekahau, NetAlly) pahalı; bu feature cep telefonunda hafif bir eşdeğer sunar.
- **Dokümantasyon**: kiracı/misafirlere "evin 3. katında A odası sinyal zayıf" anlatmak yerine rapor paylaşma imkanı.
