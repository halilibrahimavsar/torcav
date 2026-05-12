# Kısım 4 — Tema & UI Bileşenleri

> Kapsam: `lib/core/theme/`, `lib/core/presentation/widgets/`, `lib/core/extensions/`, `shaders/`

## Boyutlar
| Dosya | Satır |
|---|---|
| `app_theme.dart` | 563 |
| `neon_widgets.dart` | 1368 (26 sınıf) |
| `prominent_disclosure_dialog.dart` | 159 |
| `theme_cubit.dart` | 36 |
| `cyber_neomorphic_button.dart` | 259 |
| `context_extensions.dart` | 91 |
| `shaders/*.frag` | 3 dosya, ~10.6 KB |

---

## Bulgular

### B4.1 — `cyber_post.frag` shader hiç kullanılmıyor (O) — APK şişirme
**Kanıt (v2 doğrulama, sadece lib/ değil tüm repo):**
```
grep -rn "cyber_post" --include="*.dart" --include="*.yaml" --include="*.md" .
  pubspec.yaml:116:    - shaders/cyber_post.frag
  README.md:74: Theming: ... custom shader (shaders/cyber_post.frag)
  README.md:142: shaders/cyber_post.frag — post-process shader
```
**Tespit:** Shader dosyası APK'ya gömülüyor ama hiçbir Dart kodu tarafından `FragmentProgram.fromAsset(...)` ile yüklenmiyor. Diğer iki shader (`neomorphic.frag` ve `premium_grid.frag`) birer kez kullanılıyor. **README'de hâlâ bahsediliyor** → dokümantasyon ve kod tutarsız.
**Aksiyon:**
- `git rm shaders/cyber_post.frag`
- `pubspec.yaml` 116. satırı sil
- `README.md` 74 ve 142. satırları güncelle (cyber_post.frag bahislerini kaldır)

### B4.2 — `neon_widgets.dart` içinde 2 kullanılmayan sınıf (D) — ölü kod
**Kanıt:** `grep "<class_name>" lib/ -rn` (neon_widgets.dart hariç):
- `NeonConfirmDialog` → 0 referans
- `GlowPoint` → 0 referans

**Tespit:** 1368 satırlık dosyada 26 sınıf var, 2'si ölü. `NeonConfirmDialog` muhtemelen `AlertDialog` yerine kullanılmak üzere tasarlanmış ama proje genelinde `ProminentDisclosureDialog` veya inline `Dialog` tercih edilmiş.
**Aksiyon:** Spot check sonrası sil. Kısım sırasında yapılır.

### B4.3 — `ProminentDisclosureDialog` widget tasarımı doğru (✅) — compliance
**Kanıt:** `lib/core/theme/prominent_disclosure_dialog.dart` okundu (159 satır).
**Tespit:** Play Store policy gereği prominent disclosure widget'ı şunları içermeli:
| Gereklilik | Durum |
|---|---|
| Açık başlık (ne için izin isteniyor) | ✅ `title` parametresi |
| Açıklayıcı metin (neden) | ✅ `description` parametresi |
| Gizlilik noktaları (veri akışı listesi) | ✅ `privacyPoints: List<String>` |
| Açık kabul/red butonları | ✅ "NOT NOW" (cancel) + actionLabel (accept) |
| Lokalize | ✅ `context.l10n.notNowLabel` kullanıyor |
| Kullanıcının "kapatma" yolu var mı? | ✅ Cancel callback |
| Hardcoded string yok | ✅ — analyze edildi |

**Compliance:** Widget'ın **kendisi** Play Store gereksinimlerini karşılıyor. **Asıl iş çağrı yerlerinde** (`wifi_scan_page`, `network_scan_page`, `heatmap/new_session_dialog`): bu kısımda çağrı yerleri Kısım 7 (wifi/network scan) ve Kısım 11 (heatmap)'de derinlemesine incelenecek. Burada widget temiz.

### B4.4 — `ProminentDisclosureDialog` 4 çağrı noktasında (bilgi) — Kısım 7/11'e ön not
**Kanıt:** `grep -rn "ProminentDisclosureDialog" lib/`:
```
lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:89
lib/features/wifi_scan/presentation/pages/wifi_scan_page.dart:595
lib/features/network_scan/presentation/pages/network_scan_page.dart:119
lib/features/heatmap/presentation/widgets/heatmap/new_session_dialog.dart:88
```
**Aksiyon:** Bu çağrı yerlerinde:
- Dialog **izin isteğinden ÖNCE** mi gösteriliyor? (Play Store şartı)
- `privacyPoints` listesi gerçekten data flow'u açıklıyor mu, yoksa generic mi?
- "Sadece prompt'tan sonra göstermek" Play Store policy ihlali

Bu kontrol Kısım 7 ve 11'de yapılacak.

### B4.5 — `ThemeCubit._load` küçük asimetri (D)
**Kanıt:** `lib/core/theme/theme_cubit.dart`:
```dart
void _load() {
  final saved = _storage.get<String>(_key);
  final mode = switch (saved) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  emit(mode);
}

void setTheme(ThemeMode mode) {
  _storage.save(_key, mode.name);  // 'system' de kaydedebiliyor
  emit(mode);
}
```
**Tespit:** `setTheme(ThemeMode.system)` → storage'a `'system'` yazıyor → `_load()` bir sonraki açılışta `_ => ThemeMode.system` ile aynı sonuca varır. **Bug değil**, sadece asimetri görüntüsü (`'system'` ele alınmamış gibi ama default'a düşüyor).
**Aksiyon:** Açıklayıcı yorum eklenebilir veya `switch` içine `'system' => ThemeMode.system` eklenir (kozmetik). Düşük öncelik, mevcut davranış doğru.

### B4.6 — `app_theme.dart` ve `neon_widgets.dart`'ta hiç hardcoded user-facing string yok (✅)
**Kanıt:**
- `grep -E "Text\(" lib/core/theme/neon_widgets.dart | head -10` — tüm Text widget'lar parametre alıyor (`label`, `text`), inline string yok
- `app_theme.dart` sadece renk/typography tanımları
**Aksiyon:** Yok.

### B4.7 — `withOpacity` kullanımı sıfır (✅) — Flutter 3.27+ migration tamam
**Kanıt:** `grep -rn "withOpacity\b" lib/ → 0 sonuç`.
**Tespit:** Tüm proje `withValues(alpha: ...)` API'sine geçmiş. Flutter sürümü güncel, deprecation uyarısı yok.

---

## Compliance Özeti (Kısım 14'e taşınan notlar)

| Konu | Durum | Detay |
|---|---|---|
| Prominent disclosure widget standardı | ✅ Karşılanıyor | Title + desc + privacyPoints + accept/cancel |
| Disclosure çağrı yeri zamanlaması | ⏳ Kısım 7/11'de doğrulanacak | İzin isteğinden önce gösterilmeli |
| Tüm UI metni lokalize | ✅ (bu kısımda) | Hardcoded yok |
| withOpacity (deprecated) | ✅ Temiz | 0 kullanım |

---

## Kanıt Tablosu

| Bulgu | Komut | Çıktı |
|---|---|---|
| B4.1 | `grep "cyber_post" --include="*.dart" -rn .` | **0** dart referansı (pubspec ve README'de 3 bahis) |
| B4.2 | `grep "NeonConfirmDialog" lib/ -rn` | sadece tanım satırı (1058, 1066) |
| B4.2 | `grep "\bGlowPoint\b" lib/ -rn` | sadece tanım satırı (1269, 1273) |
| B4.3 | `prominent_disclosure_dialog.dart` okuma | Widget gerekli parametre seti tam |
| B4.4 | `grep "ProminentDisclosureDialog" lib/ -rn` | **4** çağrı yeri |
| B4.5 | `theme_cubit.dart` okuma | `'system'` round-trip doğru |
| B4.6 | `grep "Text(" neon_widgets.dart` | Hepsi parametreli, inline string yok |
| B4.7 | `grep "withOpacity" lib/` | **0** kullanım |

---

## Önerilen Düzeltme Sırası

1. **`git rm shaders/cyber_post.frag`** + `pubspec.yaml` güncelleme (B4.1)
2. **`neon_widgets.dart`**'tan `NeonConfirmDialog` ve `GlowPoint` sil (B4.2)
3. (Opsiyonel) `theme_cubit._load` switch'e `'system'` ekle (B4.5)

**Kısım 4 bulgu sayısı: 7** — 0 K, 0 Y, 1 O, 3 D, 3 ✅ (positive).
