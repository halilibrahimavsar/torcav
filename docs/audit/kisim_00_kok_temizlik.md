# Kısım 0 — Kök Temizlik Denetimi (v2 — doğrulanmış)

> Amaç: Repo kökündeki geliştirme aşamasından kalan artıklar, `.gitignore` boşlukları. Play Store sürüm öncesi repo hijyeni.
>
> **v2 notu:** v1 raporundaki 3 bulgu doğrulamada yanlış çıktı (B0.3 __pycache__, B0.10 .flutter-plugins). Düzeltildi.

## Şiddet Skalası
- **K**ritik — sürüm/güvenlik etkili
- **Y**üksek — kafa karışıklığı/şişme, kaldırılmalı
- **O**rta — düzenleme/taşıma önerilir
- **D**üşük — kozmetik

---

## Doğrulanmış Bulgular

### B0.1 — `scratch/` izleniyor (Y) ✅ doğrulandı
**Kanıt (`git ls-files scratch/`):**
```
scratch/check_arb.py            2.1 KB
scratch/classes.jar             192 KB
scratch/core_classes.jar        910 KB
scratch/fix_all_metadata.py     1.8 KB
scratch/fix_metadata.py         1.5 KB
scratch/sync_all_keys.py        2.0 KB
scratch/sync_arb.py             1.2 KB
```
Toplam ~1.1 MB, ikisi Java jar.
**Aksiyon:** `git rm -r scratch/` + `.gitignore`'a `scratch/` ekle. Script'lerden hâlâ kullanılan varsa `scripts/`'e taşı (sonradan ihtiyaç olursa).

### B0.2 — Kökte Python l10n araçları (O) ✅ doğrulandı
**Kanıt:** `find_strings.py` (16.5 KB), `update_arb_final.py` (5.1 KB) — repo kökünde, izleniyor.
**Tespit:** `scripts/` zaten var (`generate_oui_db.dart`, `gen_oui.py`).
**Aksiyon:** `git mv find_strings.py update_arb_final.py scripts/`. Kısım 3'te (Localization) kullanılıyor mu doğrulanacak — kullanılmıyorsa silinecek.

### B0.3 — `__pycache__/` diskte mevcut, git'te değil (D) ⚠️ DÜZELTME (v1 yanlıştı)
**Kanıt:** `git ls-files | grep __pycache__` → **NONE TRACKED**. Diskte mevcut: `__pycache__/find_strings.cpython-312.pyc`, `scripts/__pycache__/gen_oui.cpython-312.pyc`. `.gitignore`'da `*.pyc` var, yani pyc dosyaları zaten yok sayılıyor.
**Tespit:** Git problemi YOK. Sadece kozmetik: dizinlerin kendileri diskte boşa yer kaplıyor.
**Aksiyon:** `.gitignore`'a güvenlik için `__pycache__/` satırı eklensin (gelecekte yanlışlıkla `git add -A` ile dizinin eklenmemesini garantiler). Lokal silme: `rm -rf __pycache__ scripts/__pycache__` (opsiyonel).

### B0.4 — Geçmiş analiz çıktıları izleniyor (Y) ✅ doğrulandı
**Kanıt (`git ls-files`):**
```
analyze_output.txt        23.7 KB    Nis 28
strings_found.txt         51 KB      May 9
l10n_report.txt           2 B        May 12 (boş)
hardcoded_strings.json    60.7 KB    May 11
```
**Aksiyon:**
- `analyze_output.txt`, `strings_found.txt`, `l10n_report.txt` → `git rm` (hemen).
- `hardcoded_strings.json` → Kısım 3'te referans olarak kullanılacak; Kısım 3 bitince silinecek.
- `.gitignore`'a kalıcı çözüm: `analyze_output.txt`, `*_report.txt`, `strings_found.txt`, `hardcoded_strings.json` (veya `*.audit.json`).

### B0.5 — `coverage/lcov.info` izleniyor (Y) ✅ doğrulandı
**Kanıt:** `git ls-files coverage/` → `coverage/lcov.info` (195 KB, Şub 26 — 3 ay eski).
**Aksiyon:** `git rm coverage/lcov.info` + `.gitignore`'a `coverage/` ekle.

### B0.6 — Dahili dökümanlar kökte (O) ✅ doğrulandı
**Kanıt:** `ROADMAP_AUDIT.md` (29 KB), `lib_feature_backlog.md` (20.5 KB), `TODO.md` (5.1 KB) — üçü de izleniyor.
**Aksiyon:** `docs/internal/` altına `git mv`. README.md'de "dahili notlar" referansı (opsiyonel). Kullanıcı kararı: repoda mı kalsın yoksa Notion'a mı? (rapor sonunda soru kaldı.)

### B0.7 — `testsprite_tests/` kullanılmıyor (O) ✅ kullanıcı onayladı
**Kanıt:** `testsprite_tests/standard_prd.json` + `testsprite_tests/tmp/prd_files/`. Kullanıcı: "şu an kullanılmıyor".
**Aksiyon:** `git rm -r testsprite_tests/`.

### B0.8 — `tools/device_classifier/` — saklanmalı (D) ✅ doğrulandı (boyut düzeltildi)
**Kanıt:**
```
device_categories.json           233 B
device_classifier.onnx           8.4 KB
device_classifier.onnx.data      119 KB
device_classifier.pt             122 KB
feature_constants.json           2.0 KB
```
**Toplam ~252 KB** (v1'deki "birkaç MB" abartıydı).
**Tespit:** Aktif `assets/models/device_classifier.onnx` kullanılıyor (`lib/features/ai/data/services/onnx_device_classifier_service.dart:263`). Eğitim ortamı için tutulmalı.
**Aksiyon:** Saklansın. `.pt` 122 KB — ihmal edilebilir, taşımaya gerek yok. `tools/device_classifier/README.md` yoksa eğitim adımları için bir tane eklenmesi düşünülebilir (Kısım 8b'de tekrar bakılacak).

### B0.9 — `packages/` boş dizin (D) ✅ doğrulandı
**Kanıt:** `find packages/` → tek bir dosya yok. Git'te boş dizin izlenmediği için sadece lokal kalıntı.
**Aksiyon:** `rmdir packages/`. (Git'i etkilemez.)

### ~~B0.10 — `.flutter-plugins` izleniyor~~ ❌ İPTAL (v1 yanlıştı)
**Doğrulama:** `git ls-files | grep flutter-plugins` → **NOT TRACKED**. `.gitignore`'da `.flutter-plugins` ve `.flutter-plugins-dependencies` doğru tanımlı, git zaten yok sayıyor. v1'deki ilk Bash çıktısında `ls -la` ile dosyaları görmem ile `git ls-files` regex'imin kapsama hatası karışmıştı. Bulgu yok.

---

## Play Store Etkisi
Hiçbiri APK'ya doğrudan etki etmez (build çıktısı `assets/`'i alır, `scratch/` ve `tools/`'u almaz), ama:
- Repo paylaşımı yapılırsa dahili notların görünmesi rekabet/itibar riski.
- Bu temizlik history'yi etkilemez — `scratch/*.jar` git history'de kalmaya devam eder. Tam temizlik için `git filter-repo` (opsiyonel, sürüm öncesi sadece public açılırsa).

---

## Önerilen Aksiyon Sırası (onay sonrası, tek commit olarak önerilir)

1. **`.gitignore`** güncellemesi — sonuna eklenecekler:
   ```
   scratch/
   __pycache__/
   coverage/
   analyze_output.txt
   strings_found.txt
   l10n_report.txt
   hardcoded_strings.json
   ```
2. **`git rm`** — izlemekten kaldır:
   - `git rm -r scratch/ testsprite_tests/`
   - `git rm coverage/lcov.info`
   - `git rm analyze_output.txt strings_found.txt l10n_report.txt`
   - **`hardcoded_strings.json` Kısım 3 bitene kadar bekletilir**
3. **`git mv`** — taşımalar:
   - `git mv find_strings.py update_arb_final.py scripts/`
   - `mkdir -p docs/internal && git mv ROADMAP_AUDIT.md TODO.md lib_feature_backlog.md docs/internal/`
4. **Lokal temizlik (git'i etkilemez):**
   - `rmdir packages/`
   - `rm -rf __pycache__ scripts/__pycache__` (opsiyonel)

**Tahmini etki:**
- Kök dosya sayısı: 20+ → ~10
- Git ağırlığı: ~1.3 MB azalma (working tree; history aynı kalır)
- Bulgu sayısı: **8 doğrulanmış** (v1: 10, 2'si iptal/düzeltme)

---

## Açık Sorular (kullanıcı onayı bekliyor)

1. `tools/device_classifier/output/device_classifier.pt` (PyTorch checkpoint, 122 KB) repoda kalsın mı? **Önerim: kalsın, küçük dosya.**
2. Dahili dökümanlar (`ROADMAP_AUDIT.md`, `TODO.md`, `lib_feature_backlog.md`) → `docs/internal/`'a mı taşınsın, yoksa Notion/external'a mı çıkarılsın? **Önerim: `docs/internal/`, sonra Notion'a taşıma ayrı bir karar.**
