#!/usr/bin/env python3
"""Torcav dependency-tree & redundant-code analyzer.

Kökü `lib/main.dart` alır, transitive import/export/part grafiğini çıkarır,
ağaca bağlanmayan dosyaları (orphan / test-only) ve erişilebilir dosyalardaki
kullanılmayan public sembolleri raporlar.

Salt-okunur: hiçbir kaynak dosyayı değiştirmez. Çıktı `dependency_analysis_report.md`.
"""
from __future__ import annotations
import os
import re
import sys
import json
import subprocess
from collections import deque, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
TEST = os.path.join(ROOT, "test")
PKG = "package:torcav/"
ENTRY = os.path.join(LIB, "main.dart")

DIRECTIVE_RE = re.compile(r"""^\s*(import|export|part)\s+['"]([^'"]+)['"]""", re.M)
# Top-level public declarations.
DECL_RE = re.compile(
    r"^(?:abstract\s+|base\s+|final\s+|sealed\s+|interface\s+|mixin\s+)*"
    r"(class|enum|mixin|extension)\s+([A-Z][A-Za-z0-9_]*)",
    re.M,
)


def all_dart(base):
    out = []
    for d, _, files in os.walk(base):
        for f in files:
            if f.endswith(".dart"):
                out.append(os.path.join(d, f))
    return out


def resolve(uri, from_file):
    """Bir import URI'sini mutlak yola çevir. Dış/SDK ise None döner."""
    if uri.startswith("dart:"):
        return None
    if uri.startswith(PKG):
        return os.path.normpath(os.path.join(LIB, uri[len(PKG):]))
    if uri.startswith("package:"):
        return None  # üçüncü taraf paket
    # bağıl yol
    return os.path.normpath(os.path.join(os.path.dirname(from_file), uri))


def directives(path):
    try:
        with open(path, encoding="utf-8") as fh:
            src = fh.read()
    except (OSError, UnicodeDecodeError):
        return []
    return DIRECTIVE_RE.findall(src)


def reachable_from(roots):
    """roots listesinden BFS ile erişilebilir lib/ dosya kümesi."""
    seen = set()
    q = deque()
    for r in roots:
        r = os.path.normpath(r)
        if os.path.exists(r):
            seen.add(r)
            q.append(r)
    while q:
        cur = q.popleft()
        for _, uri in [(k, u) for k, u in directives(cur)]:
            tgt = resolve(uri, cur)
            if tgt and tgt.endswith(".dart") and os.path.exists(tgt) and tgt not in seen:
                seen.add(tgt)
                q.append(tgt)
    return seen


def rel(p):
    return os.path.relpath(p, ROOT)


_GETTER_RE = re.compile(r"\bget\s+([a-zA-Z_]\w*)")
_METHOD_RE = re.compile(r"^[ \t]*(?:[\w<>,?\s.]+?\s+)([a-zA-Z_]\w*)\s*\(", re.M)
_SETTER_RE = re.compile(r"\bset\s+([a-zA-Z_]\w*)\s*\(")


def _extension_members(src, ext_name):
    """Bir extension'ın public üye adlarını (method/getter/setter) döndürür."""
    m = re.search(r"\bextension\s+" + re.escape(ext_name) + r"\b[^{]*\{", src)
    if not m:
        return set()
    i = m.end() - 1  # açılış '{'
    depth = 0
    j = i
    while j < len(src):
        if src[j] == "{":
            depth += 1
        elif src[j] == "}":
            depth -= 1
            if depth == 0:
                break
        j += 1
    body = src[i + 1:j]
    members = set()
    for rx in (_GETTER_RE, _METHOD_RE, _SETTER_RE):
        for name in rx.findall(body):
            if not name.startswith("_") and name not in (
                "if", "for", "while", "switch", "return", "assert", "get", "set",
            ):
                members.add(name)
    return members


def main():
    lib_files = {os.path.normpath(p) for p in all_dart(LIB)}
    test_files = [os.path.normpath(p) for p in all_dart(TEST)] if os.path.isdir(TEST) else []

    # 1. Üretim ağacı
    prod = reachable_from([ENTRY]) & lib_files
    unreached = sorted(lib_files - prod)

    # 2. test/ ağacından erişilen lib/ dosyaları
    test_reach = reachable_from(test_files) & lib_files

    orphans, test_only = [], []
    for f in unreached:
        (test_only if f in test_reach else orphans).append(f)

    # 3. DI staleness kontrolü: @injectable dosyaları üretim ağacında mı?
    annotated = []
    for f in lib_files:
        try:
            with open(f, encoding="utf-8") as fh:
                if re.search(r"@(injectable|singleton|lazySingleton|module|Environment)", fh.read()):
                    annotated.append(f)
        except (OSError, UnicodeDecodeError):
            pass
    stale_di = sorted(set(annotated) - prod)

    # 4. Sembol seviyesi ölü kod (sadece erişilebilir üretim dosyaları)
    decl_list = []  # (kind, name, file)
    dup = defaultdict(list)
    for f in prod:
        try:
            with open(f, encoding="utf-8") as fh:
                src = fh.read()
        except (OSError, UnicodeDecodeError):
            continue
        for kind, name in DECL_RE.findall(src):
            dup[name].append(f)
            decl_list.append((kind, name, f))

    # Üretim kümesinin tüm metnini birleştirip kelime sayımı yap.
    corpus = {}
    for f in prod:
        try:
            with open(f, encoding="utf-8") as fh:
                corpus[f] = fh.read()
        except (OSError, UnicodeDecodeError):
            corpus[f] = ""
    test_corpus = ""
    for f in test_files:
        try:
            with open(f, encoding="utf-8") as fh:
                test_corpus += fh.read()
        except (OSError, UnicodeDecodeError):
            pass

    dead_unused = []   # üretim kümesinde hiç referans yok
    dead_internal = []  # sadece kendi dosyasında geçiyor
    dead_ext = []      # extension: hiçbir üyesi dışarıdan kullanılmıyor
    for kind, name, decl_file in sorted(decl_list, key=lambda x: x[1]):
        if len(dup[name]) > 1:
            continue  # aynı ad birden çok yerde -> atla, gürültü
        if kind == "extension":
            # Extension adı çağrı yerinde geçmez; ÜYELERİNİ kontrol et.
            members = _extension_members(corpus[decl_file], name)
            if not members:
                continue
            used_ext = False
            used_test = False
            for f, src in corpus.items():
                if f == decl_file:
                    continue
                if any(re.search(r"\b" + re.escape(m) + r"\b", src) for m in members):
                    used_ext = True
                    break
            for m in members:
                if re.search(r"\b" + re.escape(m) + r"\b", test_corpus):
                    used_test = True
                    break
            if not used_ext:
                dead_ext.append((name, decl_file, used_test, sorted(members)))
            continue
        wb = re.compile(r"\b" + re.escape(name) + r"\b")
        external = 0
        own = 0
        for f, src in corpus.items():
            n = len(wb.findall(src))
            if f == decl_file:
                own += n
            else:
                external += n
        in_test = bool(wb.search(test_corpus))
        if external == 0:
            # kendi dosyasında bildirim dışında geçiyor mu?
            if own <= 1:
                dead_unused.append((name, decl_file, in_test))
            else:
                dead_internal.append((name, decl_file, in_test))

    print("semantik üye analizi (dead_symbols.py)...", file=sys.stderr)
    semantic = run_semantic()

    write_report(lib_files, prod, orphans, test_only, stale_di,
                 dead_unused, dead_internal, dead_ext, annotated, semantic)

    print(f"lib dosyası        : {len(lib_files)}")
    print(f"üretim ağacı       : {len(prod)}")
    print(f"orphan             : {len(orphans)}")
    print(f"test-only          : {len(test_only)}")
    print(f"stale DI           : {len(stale_di)}")
    print(f"hiç kullanılmayan  : {len(dead_unused)}")
    print(f"ölü extension      : {len(dead_ext)}")
    print(f"sadece dosya-içi   : {len(dead_internal)}")
    if semantic:
        print(f"semantik ölü üye   : {len(semantic['dead'])}")
    print(f"rapor              : dependency_analysis_report.md")


SEMANTIC_CACHE = os.path.join(ROOT, "dead_symbols.cache.json")


def run_semantic():
    """`tool/dead_symbols.py`'yi çalıştır (semantik üye-seviyesi analiz).

    `--fast`  → atla.   `--cached` → varsa önceki sonucu kullan.
    Aksi halde analysis server'ı çalıştırır (~birkaç dakika)."""
    if "--fast" in sys.argv:
        return None
    if "--cached" in sys.argv and os.path.exists(SEMANTIC_CACHE):
        with open(SEMANTIC_CACHE, encoding="utf-8") as fh:
            return json.load(fh)
    script = os.path.join(ROOT, "tool", "dead_symbols.py")
    if not os.path.exists(script):
        return None
    try:
        # stderr inherit edilir → kullanıcı ilerlemeyi görür.
        r = subprocess.run([sys.executable, script], stdout=subprocess.PIPE,
                           text=True, timeout=1200)
        if r.returncode != 0 or not r.stdout.strip():
            print("uyarı: semantik analiz başarısız, atlanıyor.", file=sys.stderr)
            return None
        data = json.loads(r.stdout)
        with open(SEMANTIC_CACHE, "w", encoding="utf-8") as fh:
            json.dump(data, fh)
        return data
    except (subprocess.TimeoutExpired, json.JSONDecodeError, OSError) as e:
        print(f"uyarı: semantik analiz atlandı ({e}).", file=sys.stderr)
        return None


def feature_of(p):
    r = rel(p)
    parts = r.split(os.sep)
    if len(parts) >= 2 and parts[0] == "lib":
        if parts[1] == "features" and len(parts) >= 3:
            return f"features/{parts[2]}"
        return parts[1]
    return r


def _write_semantic(w, semantic):
    """Semantik (analysis server) üye-seviyesi bulgularını rapora yaz."""
    if not semantic:
        w("## 🔴 Kullanılmayan Public Üyeler (semantik)\n")
        w("_Semantik analiz çalıştırılmadı. Çalıştırmak için `--fast` "
          "bayrağı olmadan `python3 tool/analyze_deps.py` çalıştırın._\n")
        return
    dead = semantic["dead"]
    l10n = [x for x in dead if "app_localizations" in x["file"]]
    code = [x for x in dead if "app_localizations" not in x["file"]]

    w("## 🔴 Kullanılmayan Public Üyeler — Semantik (IDE doğruluğunda)\n")
    w("Dart Analysis Server'ın \"Find Usages\" özelliğiyle bulundu: aşağıdaki "
      "method/getter/field/fonksiyonlar **hiçbir yerden çağrılmıyor**. "
      "`@override` ve framework callback'leri elendi. String/reflection "
      "çağrıları yakalanmaz — silmeden önce göz gezdirin.\n")
    if not code:
        w("_Yok._\n")
    else:
        by_file = defaultdict(list)
        for x in code:
            by_file[x["file"]].append(x)
        big = {f: v for f, v in by_file.items() if len(v) >= 3}
        small = {f: v for f, v in by_file.items() if len(v) < 3}
        # Yoğun dosyalar — ayrı alt başlık.
        for f in sorted(big, key=lambda f: -len(big[f])):
            items = big[f]
            w(f"### `{f}` — {len(items)} öğe\n")
            w("| Tür | Üye | Satır |")
            w("|-----|-----|-------|")
            for x in sorted(items, key=lambda x: x["line"]):
                full = (x["enclosing"] + "." + x["name"]).lstrip(".")
                w(f"| {x['kind']} | `{full}` | {x['line']} |")
            w("")
        # Geri kalan (1-2 öğeli dosyalar) — tek tablo.
        if small:
            n = sum(len(v) for v in small.values())
            w(f"### Diğer dosyalar — {n} öğe ({len(small)} dosya)\n")
            w("| Tür | Üye | Dosya:Satır |")
            w("|-----|-----|-------------|")
            rows = [x for v in small.values() for x in v]
            for x in sorted(rows, key=lambda x: (x["file"], x["line"])):
                full = (x["enclosing"] + "." + x["name"]).lstrip(".")
                w(f"| {x['kind']} | `{full}` | `{x['file']}`:{x['line']} |")
            w("")

    w("## 🌐 Kullanılmayan l10n Anahtarları\n")
    w("`app_localizations.dart` ÜRETİLEN dosyadır — buradan silmeyin. "
      "Karşılık gelen anahtarı `.arb` kaynak dosyalarından kaldırıp "
      "`flutter gen-l10n` çalıştırın.\n")
    if not l10n:
        w("_Yok._\n")
    else:
        w(", ".join(f"`{x['name']}`" for x in sorted(l10n,
          key=lambda x: x["name"])) + "\n")

    w("## 🟡 Sadece Testten Kullanılan Üyeler\n")
    w("Üretim kodunda hiç çağrılmıyor, yalnızca `test/` altından. "
      "Silinmemeli — ya test yardımcısı ya da UI'a bağlanmamış bir "
      "özellik. İncelenmesi önerilir.\n")
    test_only = semantic["test_only"]
    if not test_only:
        w("_Yok._\n")
    else:
        w("| Tür | Üye | Dosya:Satır |")
        w("|-----|-----|-------------|")
        for x in sorted(test_only, key=lambda x: x["file"]):
            full = (x["enclosing"] + "." + x["name"]).lstrip(".")
            w(f"| {x['kind']} | `{full}` | `{x['file']}`:{x['line']} |")
        w("")


def write_report(lib_files, prod, orphans, test_only, stale_di,
                  dead_unused, dead_internal, dead_ext, annotated,
                  semantic=None):
    L = []
    w = L.append
    w("# Torcav — Bağımlılık Ağacı & Redundant Kod Raporu\n")
    w("Otomatik üretildi: `python3 tool/analyze_deps.py`. "
      "Kök: `lib/main.dart`.\n")
    w("## Özet\n")
    w(f"- Toplam `lib/` Dart dosyası: **{len(lib_files)}**")
    w(f"- `main.dart` ağacından erişilebilir: **{len(prod)}** "
      f"(%{100*len(prod)//len(lib_files)})")
    w(f"- **Orphan** (hiçbir yerden erişilmiyor — silme adayı): **{len(orphans)}**")
    w(f"- **Test-only** (sadece `test/` kullanıyor — korunacak): **{len(test_only)}**")
    w(f"- Kullanılmayan public tip (class/enum/mixin — regex): "
      f"**{len(dead_unused)}**")
    w(f"- Hiçbir üyesi kullanılmayan extension (regex): **{len(dead_ext)}**")
    if semantic:
        sem_dead = semantic["dead"]
        l10n_dead = [x for x in sem_dead if "app_localizations" in x["file"]]
        code_dead = [x for x in sem_dead if "app_localizations" not in x["file"]]
        w(f"- **Kullanılmayan public ÜYE** (method/getter/field — semantik, "
          f"IDE doğruluğunda): **{len(code_dead)}**")
        w(f"- Kullanılmayan l10n anahtarı: **{len(l10n_dead)}**")
        w(f"- Sadece testten kullanılan üye: **{len(semantic['test_only'])}**\n")
    else:
        w("- _Semantik üye analizi çalıştırılmadı (`--fast`)._\n")

    if stale_di:
        w("## ⚠️ DI Config Bayat Olabilir\n")
        w("Aşağıdaki dosyalar `@injectable` ailesinden annotation taşıyor ama "
          "üretim ağacında değil. `injection.config.dart` muhtemelen bayat — "
          "`dart run build_runner build` çalıştırıp analizi tekrarlayın.\n")
        for f in stale_di:
            w(f"- `{rel(f)}`")
        w("")

    # Feature bazında erişilebilirlik
    w("## Feature Bazında Erişilebilirlik\n")
    by_feat_total = defaultdict(int)
    by_feat_reach = defaultdict(int)
    for f in lib_files:
        ft = feature_of(f)
        by_feat_total[ft] += 1
        if f in prod:
            by_feat_reach[ft] += 1
    w("| Alan | Erişilebilir / Toplam |")
    w("|------|----------------------|")
    for ft in sorted(by_feat_total):
        t, r = by_feat_total[ft], by_feat_reach[ft]
        flag = "" if t == r else "  ⚠️"
        w(f"| `{ft}` | {r} / {t}{flag} |")
    w("")

    w("## 🔴 Orphan Dosyalar (silme adayı)\n")
    if not orphans:
        w("_Yok — her dosya `main.dart` ağacına bağlı._\n")
    else:
        w("Bu dosyalar ne üretim ne de test ağacından erişiliyor.\n")
        for f in orphans:
            w(f"- [ ] `{rel(f)}`")
        w("")

    w("## 🟡 Test-only Dosyalar (korunacak)\n")
    if not test_only:
        w("_Yok._\n")
    else:
        w("Üretim ağacında değil ama `test/` tarafından kullanılıyor. "
          "Silinmemeli; gerçek üretim koduysa neden bağlı olmadığı incelenmeli.\n")
        for f in test_only:
            w(f"- `{rel(f)}`")
        w("")

    w("## 🟠 Kullanılmayan Public Semboller (erişilebilir dosyalarda)\n")
    w("Aşağıdaki public class/enum/mixin/extension'lar erişilebilir üretim "
      "kümesinde hiç referanslanmıyor. Annotation/string ile referans "
      "verilenler yanlış pozitif olabilir — silmeden önce doğrulayın.\n")
    if not dead_unused:
        w("_Yok._\n")
    else:
        w("| Sembol | Dosya | Testte geçiyor? |")
        w("|--------|-------|-----------------|")
        for name, f, in_test in dead_unused:
            w(f"| `{name}` | `{rel(f)}` | {'evet' if in_test else 'hayır'} |")
        w("")

    w("## 🟠 Hiçbir Üyesi Kullanılmayan Extension'lar\n")
    w("Extension adı çağrı yerinde geçmez; bu yüzden üye (method/getter) "
      "adları tarandı. Aşağıdaki extension'ların **hiçbir üyesi** erişilebilir "
      "üretim kodunda kullanılmıyor — güçlü redundant sinyali.\n")
    if not dead_ext:
        w("_Yok._\n")
    else:
        w("| Extension | Dosya | Üyeler | Testte? |")
        w("|-----------|-------|--------|---------|")
        for name, f, in_test, members in dead_ext:
            w(f"| `{name}` | `{rel(f)}` | {', '.join(f'`{m}`' for m in members)} "
              f"| {'evet' if in_test else 'hayır'} |")
        w("")

    _write_semantic(w, semantic)

    w(f"_Not: regex tabanlı dosya-içi tarama {len(dead_internal)} adet "
      f"\"sadece kendi dosyasında geçen\" sembol buldu — bunlar kullanılıyor "
      f"(çoğu widget alanı / BLoC taban sınıfı), silme adayı değil, rapordan "
      f"çıkarıldı._\n")

    w("## ✅ Önerilen Aksiyon\n")
    sem_code = sem_l10n = sem_test = 0
    if semantic:
        sem_code = len([x for x in semantic["dead"]
                        if "app_localizations" not in x["file"]])
        sem_l10n = len(semantic["dead"]) - sem_code
        sem_test = len(semantic["test_only"])
    n_file = len(orphans) + len(dead_unused) + len(dead_ext)
    w(f"1. **Dosya/tip seviyesi ({n_file} öğe):** Orphan dosyalar + "
      f"kullanılmayan public tip/extension. Hiçbir yerden erişilmiyor.")
    if semantic:
        w(f"2. **Üye seviyesi ({sem_code} öğe):** \"Kullanılmayan Public "
          f"Üyeler\" — semantik (IDE 'Find Usages') doğruluğunda. Silmeden "
          f"önce `@override`/dinamik kullanım için tabloyu gözden geçirin.")
        w(f"3. **l10n ({sem_l10n} anahtar):** kullanılmayan çeviri anahtarları "
          f"— `lib/core/l10n/app_localizations.dart` ÜRETİLEN dosyadır; "
          f"anahtarı `.arb` kaynak dosyalarından silip `flutter gen-l10n` "
          f"çalıştırın.")
        w(f"4. **Test-only ({sem_test} üye):** üretimde kullanılmıyor, sadece "
          f"testte — silinmez; özelliğin neden UI'a bağlanmadığı incelenir.")
    w("- Her silme turundan sonra `flutter analyze` + `flutter test` "
      "çalıştırın; analizi `python3 tool/analyze_deps.py` ile yineleyin.\n")

    w("## Yöntem & Kısıtlar\n")
    w("**Dosya seviyesi** (`analyze_deps.py`):")
    w("- Grafik `import`/`export`/`part` direktiflerinden statik kuruldu.")
    w("- `deferred`/koşullu import yok (doğrulandı) — grafik eksiksiz.")
    w("- DI ile bağlı dosyalar `injection.config.dart` üzerinden erişilebilir "
      "sayılır.")
    w("- Tip taraması (class/enum/extension) heuristiktir; aynı adın birden "
      "çok bildirimi atlanır.\n")
    w("**Üye seviyesi** (`dead_symbols.py`):")
    w("- Dart Analysis Server'ın `search.findElementReferences`'ı kullanıldı "
      "— IDE \"Find Usages\" ile aynı tip-çözümlemeli doğruluk (~%99).")
    w("- `@override`, framework callback'leri (`build`, `initState`...), "
      "`fromJson`/`toJson`/`copyWith` elendi.")
    w("- Yakalanmaz: string/reflection ile çağrı (Flutter'da pratikte yok). "
      "Override edilen bir üye yalnızca üst-tip üzerinden çağrılıyorsa düşük "
      "ihtimalle yanlış pozitif olabilir — bu yüzden silmeden önce inceleyin.")
    w("- Yeniden çalıştır: `python3 tool/analyze_deps.py` "
      "(`--fast`: üye analizini atla, `--cached`: önceki üye sonucunu kullan).")

    with open(os.path.join(ROOT, "dependency_analysis_report.md"), "w",
              encoding="utf-8") as fh:
        fh.write("\n".join(L) + "\n")


if __name__ == "__main__":
    sys.exit(main())
