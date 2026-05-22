#!/usr/bin/env python3
"""Bağımlılık ağacı & ölü kod analizörü — herhangi bir Dart/Flutter projesi.

İki katman:
  • Dosya seviyesi: `lib/main.dart`'tan transitive import/export/part grafiği —
    hiç import edilmeyen "orphan" dosyaları bulur (hızlı, statik-kesin).
  • Üye seviyesi: `tool/dead_symbols.py`'yi çalıştırır — analysis server tabanlı
    mark-and-sweep ile kullanılmayan method/getter/field/sınıf/enum'ları
    geçişli olarak bulur (IDE doğruluğunda).

Salt-okunur. Çıktı: `dependency_analysis_report.md`.

Kullanım:
  python3 tool/analyze_deps.py [--project YOL] [--fast] [--cached]
    --fast    : üye-seviyesi semantik analizi atla (sadece dosya grafiği).
    --cached  : önceki semantik sonucu (dead_symbols.cache.json) yeniden kullan.
"""
from __future__ import annotations
import os
import re
import sys
import json
import subprocess
from collections import deque, defaultdict

DIRECTIVE_RE = re.compile(r"""^\s*(?:import|export|part)\s+['"]([^'"]+)['"]""",
                          re.M)


def find_project_root(start):
    d = os.path.abspath(start)
    while True:
        if os.path.exists(os.path.join(d, "pubspec.yaml")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            raise SystemExit("pubspec.yaml bulunamadı — --project ile belirtin.")
        d = parent


def package_name(root):
    """pubspec.yaml'ın `name:` alanı."""
    try:
        with open(os.path.join(root, "pubspec.yaml"), encoding="utf-8") as fh:
            for line in fh:
                m = re.match(r"\s*name:\s*([A-Za-z_][\w]*)", line)
                if m:
                    return m.group(1)
    except OSError:
        pass
    raise SystemExit("pubspec.yaml içinde `name:` bulunamadı.")


def all_dart(base):
    return [os.path.join(d, f)
            for d, _, fs in os.walk(base)
            for f in fs if f.endswith(".dart")]


def directives(path):
    try:
        with open(path, encoding="utf-8") as fh:
            return DIRECTIVE_RE.findall(fh.read())
    except (OSError, UnicodeDecodeError):
        return []


def reachable(roots, lib, pkg_prefix):
    """roots'tan import/export/part ile erişilebilir lib/ dosyaları."""
    seen, q = set(), deque()
    for r in roots:
        r = os.path.normpath(r)
        if os.path.exists(r):
            seen.add(r)
            q.append(r)
    while q:
        cur = q.popleft()
        for uri in directives(cur):
            if uri.startswith("dart:"):
                continue
            if uri.startswith(pkg_prefix):
                tgt = os.path.join(lib, uri[len(pkg_prefix):])
            elif uri.startswith("package:"):
                continue
            else:
                tgt = os.path.join(os.path.dirname(cur), uri)
            tgt = os.path.normpath(tgt)
            if tgt.endswith(".dart") and os.path.exists(tgt) and tgt not in seen:
                seen.add(tgt)
                q.append(tgt)
    return seen


def run_semantic(root, cache):
    """dead_symbols.py'yi çalıştır (stderr ilerlemesi kullanıcıya akar)."""
    if "--fast" in sys.argv:
        return None
    if "--cached" in sys.argv and os.path.exists(cache):
        with open(cache, encoding="utf-8") as fh:
            return json.load(fh)
    script = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          "dead_symbols.py")
    if not os.path.exists(script):
        return None
    try:
        r = subprocess.run([sys.executable, script, "--project", root],
                           stdout=subprocess.PIPE, text=True, timeout=1800)
        if r.returncode != 0 or not r.stdout.strip():
            print("uyarı: semantik analiz başarısız, atlanıyor.", file=sys.stderr)
            return None
        data = json.loads(r.stdout)
        with open(cache, "w", encoding="utf-8") as fh:
            json.dump(data, fh)
        return data
    except (subprocess.TimeoutExpired, json.JSONDecodeError, OSError) as e:
        print(f"uyarı: semantik analiz atlandı ({e}).", file=sys.stderr)
        return None


def feature_of(relpath):
    parts = relpath.split(os.sep)
    if len(parts) >= 2 and parts[0] == "lib":
        if parts[1] == "features" and len(parts) >= 3:
            return f"features/{parts[2]}"
        return parts[1]
    return relpath


# --- Rapor -----------------------------------------------------------------

def build_report(root, lib_files, prod, orphans, test_only_files, semantic):
    L = []
    w = L.append
    rel = lambda p: os.path.relpath(p, root)
    w("# Bağımlılık Ağacı & Ölü Kod Raporu\n")
    w(f"Proje: `{root}`  ·  Üretildi: `python3 tool/analyze_deps.py`\n")

    w("## Özet\n")
    w(f"- `lib/` Dart dosyası: **{len(lib_files)}**")
    w(f"- `main.dart` import ağacından erişilebilir: **{len(prod)}** "
      f"(%{100*len(prod)//max(1,len(lib_files))})")
    w(f"- **Orphan dosya** (hiç import edilmiyor): **{len(orphans)}**")
    if semantic:
        kept = semantic.get("kept_uncertain", [])
        w(f"- Bildirim (düğüm): **{semantic['nodes']}**  ·  "
          f"canlı: **{semantic['live']}**")
        w(f"- **🟢 Güvenli silme adayı** (her metinsel geçişi statik "
          f"açıklandı): **{len(semantic['dead'])}**")
        w(f"- 🟡 Korundu — belirsiz (dynamic/string/constructor/"
          f"benzersiz-değil): **{len(kept)}**")
        w(f"- 🔢 Kullanılmayan enum sabiti (elle incele): "
          f"**{len(semantic['enum_dead'])}**")
        w(f"- Sadece testlerce kullanılan üye: **{len(semantic['test_only'])}**")
    else:
        w("- _Semantik üye analizi çalıştırılmadı (`--fast`)._")
    w("")

    # Feature dağılımı
    w("## Feature Bazında Erişilebilirlik\n")
    tot, rch = defaultdict(int), defaultdict(int)
    for f in lib_files:
        ft = feature_of(rel(f))
        tot[ft] += 1
        if f in prod:
            rch[ft] += 1
    w("| Alan | Erişilebilir / Toplam |")
    w("|------|----------------------|")
    for ft in sorted(tot):
        flag = "" if tot[ft] == rch[ft] else "  ⚠️"
        w(f"| `{ft}` | {rch[ft]} / {tot[ft]}{flag} |")
    w("")

    w("## 🔴 Orphan Dosyalar (silme adayı)\n")
    if not orphans:
        w("_Yok — her dosya `main.dart` ağacına bağlı._\n")
    else:
        w("Ne üretim ne de test ağacından import ediliyor.\n")
        for f in sorted(orphans):
            w(f"- [ ] `{rel(f)}`")
        w("")
        if test_only_files:
            w("Yalnızca `test/` import ediyor (korunur):\n")
            for f in sorted(test_only_files):
                w(f"- `{rel(f)}`")
            w("")

    if semantic:
        _write_members(w, root, semantic)

    w("## Yöntem & Kısıtlar\n")
    w("**Dosya seviyesi:** `import`/`export`/`part` grafiği — statik kesin.")
    w("**Üye seviyesi:** Dart Analysis Server (OUTLINE + NAVIGATION) ile tüm "
      "bildirimler düğüm, kullanımlar kenar yapılır; gerçek giriş "
      "noktalarından erişilemeyen her şey **mark-and-sweep** ile ölü işaretlenir. "
      "`getTypeHierarchy` ile override aileleri uzlaştırılır.")
    w("**Güvenlik filtresi:** `dynamic` erişim / string / reflection statik "
      "analizle çözülemez. Bu yüzden bir adın kod tabanındaki HER metinsel "
      "geçişi çözülmüş bir referansla açıklanamıyorsa o üye **silme adayı "
      "OLMAZ** (→ Korundu). Hata yönü güvenli: fazladan saklanır, kullanılan "
      "kod asla silinmez.")
    w("**Sınır:** yaklaşım conservative'dir — yanlış-pozitif ≈ 0, ama bazı "
      "gerçek ölü kod \"Korundu\"da kalır (eksiklik). Amaç güvenli silme.")
    w("Üretilen dosyalar (`*.g.dart`, `app_localizations*`) silme dışıdır.\n")
    return "\n".join(L) + "\n"


def _is_generated(path):
    return (path.endswith((".g.dart", ".freezed.dart", ".config.dart"))
            or "app_localizations" in path)


def _write_members(w, root, semantic):
    dead = semantic["dead"]
    generated = [x for x in dead if _is_generated(x["file"])]
    code = [x for x in dead if not _is_generated(x["file"])]

    w("## 🟢 Güvenli Silme Adayları\n")
    w("Mark-and-sweep ile erişilemeyen VE adının kod tabanındaki her metinsel "
      "geçişi statik bir referansla açıklanan üyeler. `dynamic`/string/"
      "reflection ile erişim ihtimali ELENMİŞTİR — bu liste güvenli kabul "
      "edilir. Yine de silmeden önce her satır incelenmeli.\n")
    if not code:
        w("_Yok._\n")
    else:
        by_file = defaultdict(list)
        for x in code:
            by_file[x["file"]].append(x)
        big = {f: v for f, v in by_file.items() if len(v) >= 3}
        small = {f: v for f, v in by_file.items() if len(v) < 3}
        for f in sorted(big, key=lambda f: -len(big[f])):
            w(f"### `{f}` — {len(big[f])} öğe\n")
            w("| Tür | Üye | Satır | Neden |")
            w("|-----|-----|-------|-------|")
            for x in sorted(big[f], key=lambda x: x["line"]):
                full = (x["enclosing"] + "." + x["name"]).lstrip(".")
                w(f"| {x['kind']} | `{full}` | {x['line']} | {x['reason']} |")
            w("")
        if small:
            n = sum(len(v) for v in small.values())
            w(f"### Diğer — {n} öğe ({len(small)} dosya)\n")
            w("| Tür | Üye | Dosya:Satır | Neden |")
            w("|-----|-----|-------------|-------|")
            rows = [x for v in small.values() for x in v]
            for x in sorted(rows, key=lambda x: (x["file"], x["line"])):
                full = (x["enclosing"] + "." + x["name"]).lstrip(".")
                w(f"| {x['kind']} | `{full}` | `{x['file']}`:{x['line']} "
                  f"| {x['reason']} |")
            w("")
    if generated:
        w(f"_Not: {len(generated)} aday ÜRETİLEN dosyalarda "
          f"(`*.g.dart`, `app_localizations*`, `*.config.dart`) — bunlar "
          f"elle silinmez, kaynaktan yeniden üretilir; listeden çıkarıldı._\n")

    kept = semantic.get("kept_uncertain", [])
    w("## 🟡 Korundu — Belirsiz (silme adayı DEĞİL)\n")
    w("Mark-and-sweep ölü dedi ama güvenlik filtresi eledi. Gerçekten ölü "
      "olabilirler ama statik olarak kanıtlanamıyor — otomatik silinmez.\n")
    if not kept:
        w("_Yok._\n")
    else:
        buckets = defaultdict(int)
        for x in kept:
            r = x["reason"]
            k = ("constructor" if "constructor" in r
                 else "ad benzersiz değil" if "benzersiz" in r
                 else "açıklanamayan metinsel geçiş (dynamic/string)")
            buckets[k] += 1
        w("| Eleme nedeni | Adet |")
        w("|--------------|------|")
        for k, n in sorted(buckets.items(), key=lambda kv: -kv[1]):
            w(f"| {k} | {n} |")
        w(f"\nToplam **{len(kept)}**. Tam liste `dead_symbols.cache.json` "
          f"→ `kept_uncertain`.\n")

    w("## 🔢 Kullanılmayan Enum Sabitleri (elle incele)\n")
    w("`.values` / `fromJson` / kalıcı veri ile runtime'da erişilebilir — "
      "statik sayım bunu göremez. Otomatik silinmez.\n")
    enum_dead = semantic["enum_dead"]
    if not enum_dead:
        w("_Yok._\n")
    else:
        w("| Sabit | Enum | Dosya:Satır |")
        w("|-------|------|-------------|")
        for x in sorted(enum_dead, key=lambda x: (x["file"], x["line"])):
            w(f"| `{x['name']}` | `{x['enclosing']}` | "
              f"`{x['file']}`:{x['line']} |")
        w("")

    w("## 🧪 Sadece Testlerce Kullanılan Üyeler\n")
    w("Üretimde kullanılmıyor; silinmez (testler bozulur), incelenir.\n")
    test_only = semantic["test_only"]
    if not test_only:
        w("_Yok._\n")
    else:
        w("| Tür | Üye | Dosya:Satır |")
        w("|-----|-----|-------------|")
        for x in sorted(test_only, key=lambda x: (x["file"], x["line"])):
            full = (x["enclosing"] + "." + x["name"]).lstrip(".")
            w(f"| {x['kind']} | `{full}` | `{x['file']}`:{x['line']} |")
        w("")


def main():
    root = None
    if "--project" in sys.argv:
        root = os.path.abspath(sys.argv[sys.argv.index("--project") + 1])
    root = find_project_root(root or os.getcwd())
    pkg = package_name(root)
    lib = os.path.join(root, "lib")
    test = os.path.join(root, "test")
    pkg_prefix = f"package:{pkg}/"

    lib_files = {os.path.normpath(p) for p in all_dart(lib)}
    test_files = [os.path.normpath(p) for p in all_dart(test)] \
        if os.path.isdir(test) else []
    entry = os.path.join(lib, "main.dart")

    prod = reachable([entry], lib, pkg_prefix) & lib_files
    test_reach = reachable(test_files, lib, pkg_prefix) & lib_files
    unreached = lib_files - prod
    orphans = sorted(unreached - test_reach)
    test_only_files = sorted(unreached & test_reach)

    print("semantik analiz (dead_symbols.py)...", file=sys.stderr)
    cache = os.path.join(root, "dead_symbols.cache.json")
    semantic = run_semantic(root, cache)

    report = build_report(root, lib_files, prod, orphans,
                          test_only_files, semantic)
    out_path = os.path.join(root, "dependency_analysis_report.md")
    with open(out_path, "w", encoding="utf-8") as fh:
        fh.write(report)

    print(f"paket               : {pkg}")
    print(f"lib dosyası          : {len(lib_files)}")
    print(f"erişilebilir         : {len(prod)}")
    print(f"orphan dosya         : {len(orphans)}")
    if semantic:
        print(f"güvenli silme adayı  : {len(semantic['dead'])}")
        print(f"korundu (belirsiz)   : {len(semantic.get('kept_uncertain', []))}")
        print(f"enum sabiti (incele) : {len(semantic['enum_dead'])}")
        print(f"test-only üye        : {len(semantic['test_only'])}")
    print(f"rapor                : {os.path.relpath(out_path, root)}")


if __name__ == "__main__":
    sys.exit(main())
