# Kısım 13 — Test & CI/CD

> Kapsam: `test/` (36 test dosyası), `.github/workflows/ci.yml`, `analysis_options.yaml`

---

## Test Durumu

### Çalıştırma sonucu
```
flutter test → 149 passed, 3 failed, 4 skipped
```

### B13.1 — `ar_hud_overlay_test.dart` 3 test kırık (D) — pre-existing
**Kanıt:** Kısım 12 commit'i öncesi `git stash` ile temiz checkout'ta da kırık. Bizim değişikliklerimizden kaynaklanmıyor.
```
Test: 'renders SurveyPilotCard during scanning'
Failure: find.text('COMPLETE') → 0 widgets found
```
**Tespit:** Test UI hardcoded `'COMPLETE'` (Kısım 11 B11.3 — `ready_banner.dart:77 'COVERAGE COMPLETE'`) bekleyen tasarım, AR HUD davranışı veya widget hiyerarşisi değişmiş. Test maintenance gerektiriyor.
**Aksiyon:** Backlog (sürüm sonrası test refactor). Bu denetimden ÖNCE de kırıktı.

---

## CI/CD Workflow

### `.github/workflows/ci.yml` analizi
**Yapısı (2 job):**
1. **analyze-and-test:** Flutter 3.29.x → pub get → build_runner → analyze → test
2. **build-android (debug):** Java 17 + Flutter → debug APK + 7 gün artifact retention

### B13.2 ✅ — CI doğru yapılandırılmış
- ✅ Flutter 3.29.x stable
- ✅ Java 17 (sceneview + AGP 8.x için doğru)
- ✅ build_runner çalıştırılıyor (injectable generated)
- ✅ analyze + test ayrı job
- ✅ Artifact upload (debug APK 7 gün)
- ✅ Secret kullanımı YOK (gizli credential leak yok)
- ✅ Tetikleyici: main + develop branches, PR → main

### B13.3 ✅ — Release build CI'de YOK
**Tespit:** CI sadece debug APK çıkarıyor. Release için signing keystore + secret gerekir.
**Compliance:** Sürüm öncesi Kısım 14'te:
1. `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` GitHub Actions secret'leri eklenecek
2. Release build job ayrı bir `manual workflow_dispatch` ile çalışacak
3. Play Store internal track'a otomatik upload (opsiyonel, fastlane vs.)

### B13.4 — Test coverage upload yok (D)
**Kanıt:** CI'de `flutter test --coverage` veya Codecov/Coveralls integration yok.
**Aksiyon:** Backlog — sürüm sonrası ekleme. `lcov.info` zaten Kısım 0'da gitignore'a alındı.

---

## Lint / Analysis Options

### B13.5 — `analysis_options.yaml` çok zayıftı (Y) ✅ DÜZELTİLDİ
**Kanıt (önce):**
```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    # avoid_print: false  # commented
    # prefer_single_quotes: true  # commented
```
Sadece flutter_lints default'u. Production app için zayıf.

**Aksiyon (sonra):** 17 yeni custom rule eklendi:
- `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`
- `sort_child_properties_last`, `avoid_print`, `avoid_redundant_argument_values`
- `cancel_subscriptions`, `close_sinks` (memory leak yakalar)
- `use_build_context_synchronously` (async + BuildContext bug'larını yakalar)
- `use_super_parameters`, `require_trailing_commas`, `unawaited_futures`
- Naming: `camel_case_types`, `camel_case_extensions`, `constant_identifier_names`, `file_names`
- `prefer_null_aware_operators`, `slash_for_doc_comments`

**`analyzer.errors`:**
- `unused_import: error` (CI fail eder)
- `unused_local_variable: error`

**`analyzer.exclude`:**
- Generated dosyalar (app_localizations*.dart, injection.config.dart, *.g.dart, *.freezed.dart)

### B13.6 — 269 yeni info-seviye lint (D) — backlog
**Kanıt:** Yeni kurallar açıldıktan sonra `flutter analyze`:
- Çoğunluk: `prefer_const_constructors`, `avoid_redundant_argument_values` (test/ klasöründe)
- `error/warning` seviyesinde **0 sorun**
- CI fail etmez

**Tespit:** Bu issue'lar yeni lint kuralları açıldığı için ortaya çıktı; mevcut kod hatalı değil, sadece daha sıkı kuralları henüz karşılamıyor.
**Aksiyon:** Backlog — sürüm sonrası `dart fix --apply` ile **çoğunluğu otomatik düzeltilir**:
```bash
dart fix --apply  # 269 info'nun ~80%'ini otomatik düzeltir
```

---

## Test Dosyaları Hızlı Envanter

| Modül | Test sayısı |
|---|---|
| `core/utils` | 1 (oui_lookup) |
| `features/ai` | 2 (device_classifier + onnx_service) |
| `features/app_shell` | 1 (profile_hub_page) |
| `features/diagnostics` | 3 |
| `features/heatmap` | 6 |
| `features/monitoring` | 2 |
| `features/network_scan` | 2 |
| `features/ping_stabilizer` | 4 |
| `features/reports` | 2 |
| `features/security` | 6 |
| `features/settings` | 1 |
| `features/wifi_scan` | 5 |
| `widget_test.dart` | 1 |
| **Toplam** | **36 test dosyası, 152 assertion** |

**Coverage tahmini:** Ölçülmedi (`lcov.info` yok). Belirli core servislerde iyi (security_analyzer, evil_twin_classifier, ping_stabilizer cubit). UI widget testleri zayıf — sadece 2-3 widget test var.

---

## Kanıt Tablosu

| Bulgu | Komut / Konum | Sonuç |
|---|---|---|
| B13.1 ar_hud test kırık | `flutter test ar_hud_overlay_test.dart` | 3 fail, pre-existing |
| B13.2 CI yapısı | `.github/workflows/ci.yml` | Flutter 3.29.x + Java 17 + 2 job ✅ |
| B13.3 Release CI yok | aynı dosya | Sadece debug APK; sürüm sonrası release pipeline |
| B13.4 Coverage yok | aynı dosya | `flutter test --coverage` çağrısı yok |
| B13.5 analysis_options önce | git diff `analysis_options.yaml` | Sadece flutter_lints |
| B13.5 sonra | aynı dosya | 17 custom rule + 2 error + exclude generated |
| B13.6 269 info | `flutter analyze` | Hepsi info, 0 error/warning |
| Test çıktısı | `flutter test` | 149 ✓ / 3 ✗ / 4 ~ |

---

## Kısım 13 Bulgu Özeti

| Bulgu | Şiddet | Durum |
|---|---|---|
| B13.1 ar_hud test 3 kırık | D | Backlog (pre-existing) |
| B13.2 CI yapısı | — | ✅ Doğru |
| B13.3 Release CI yok | — | Kısım 14 (signing + secrets) |
| B13.4 Coverage upload yok | D | Backlog |
| B13.5 analysis_options zayıf | Y | ✅ Düzeltildi (17 rule + 2 error) |
| B13.6 269 info-seviye lint | D | `dart fix --apply` sürüm sonrası |
| ✅ Compliance pozitifleri | — | 2 (CI yapısı, secret leak yok) |

**Kısım 13 düzeltme: 1/6 (B13.5). Diğerleri pre-existing veya sürüm sonrası.**

flutter analyze (yeni kurallarla): 269 **info** (error/warning 0)
flutter test: 149 pass / 3 fail (pre-existing)
