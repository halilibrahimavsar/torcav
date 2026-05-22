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
        dead = semantic["dead"]
        l10n = [x for x in dead if "app_localizations" in x["file"]]
        code = [x for x in dead if "app_localizations" not in x["file"]]
        w(f"- Bildirim (düğüm): **{semantic['nodes']}**  ·  "
          f"canlı: **{semantic['live']}**")
        w(f"- **Kullanılmayan üye** (semantik, geçişli): **{len(code)}**")
        w(f"- Kullanılmayan l10n anahtarı (üye): **{len(l10n)}**")
        w(f"- Kullanılmayan enum sabiti: **{len(semantic['enum_dead'])}**")
        w(f"- Sadece testten kullanılan üye: **{len(semantic['test_only'])}**")
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
      "noktalarından (`main`, framework callback'leri, DI) erişilemeyen her "
      "şey **mark-and-sweep** ile ölü ilan edilir — geçişli olarak eksiksiz.")
    w("`getTypeHierarchy` ile override aileleri uzlaştırılır (interface üyesi "
      "canlıysa override'ları da canlı).")
    w("**Tek sınır:** string/reflection ile çağrı yakalanmaz — Flutter "
      "`dart:mirrors` kullanmaz, pratik etki ≈ %0. Yine de silmeden önce "
      "tabloları gözden geçirin.")
    w("`l10n` getter'ları `app_localizations.dart` ÜRETİLEN dosyadadır — "
      "anahtarı `.arb` kaynaklarından silip `flutter gen-l10n` çalıştırın.\n")
    return "\n".join(L) + "\n"


def _write_members(w, root, semantic):
    dead = semantic["dead"]
    l10n = sorted({x["name"] for x in dead if "app_localizations" in x["file"]})
    code = [x for x in dead if "app_localizations" not in x["file"]]

    w("## 🔴 Kullanılmayan Üyeler — Semantik (mark-and-sweep)\n")
    w("Gerçek giriş noktalarından erişilemeyen method/getter/field/sınıf'lar. "
      "`reason` = neden ölü.\n")
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

    w("## 🌐 Kullanılmayan l10n Anahtarları\n")
    if not l10n:
        w("_Yok._\n")
    else:
        w(f"{len(l10n)} anahtar. `.arb` kaynaklarından silinmeli:\n")
        w(", ".join(f"`{n}`" for n in l10n) + "\n")

    w("## 🔢 Kullanılmayan Enum Sabitleri\n")
    w("_switch exhaustiveness'i etkileyebilir — dikkatle._\n")
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

    w("## 🟡 Sadece Testten Kullanılan Üyeler\n")
    w("Üretimde kullanılmıyor; silinmez, incelenir.\n")
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
        code = [x for x in semantic["dead"]
                if "app_localizations" not in x["file"]]
        print(f"kullanılmayan üye    : {len(code)}")
        print(f"kullanılmayan l10n   : {len(semantic['dead']) - len(code)}")
        print(f"kullanılmayan enum   : {len(semantic['enum_dead'])}")
        print(f"test-only üye        : {len(semantic['test_only'])}")
    print(f"rapor                : {os.path.relpath(out_path, root)}")


if __name__ == "__main__":
    sys.exit(main())
