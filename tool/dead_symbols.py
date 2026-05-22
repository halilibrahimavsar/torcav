#!/usr/bin/env python3
"""Kesin (mark-and-sweep) ölü kod dedektörü — Dart Analysis Server sürücüsü.

Herhangi bir Dart/Flutter projesinde çalışır.

Yöntem:
  1. OUTLINE → projedeki HER bildirim (sınıf, method, getter, field,
     constructor, top-level + yerel fonksiyon, enum sabiti; public + private)
     bir düğüm olur.
  2. NAVIGATION → her dosyadaki her tanımlayıcının çözümlendiği hedef; bundan
     "X bildirimi Y bildirimini kullanıyor" kenarları kurulur. Tip-çözümlemeli
     (IDE'nin go-to-definition'ı ile aynı), 360 dosya bildirimiyle tüm graf.
  3. Mark-and-sweep: gerçek giriş noktalarından (`main`, framework callback'leri,
     DI) erişilemeyen her düğüm ölüdür — geçişli olarak eksiksiz.
  4. `getTypeHierarchy` ile override aileleri uzlaştırılır: bir interface üyesi
     canlıysa onu override eden tüm üyeler de canlı.

Kullanım:
  python3 tool/dead_symbols.py [--project YOL] [--pretty]
`--project` verilmezse çalışma dizininden yukarı `pubspec.yaml` aranır.

Sınır: string/reflection ile çağrı yakalanmaz (Flutter `dart:mirrors` kullanmaz
→ pratik etki ≈ %0).
"""
from __future__ import annotations
import json
import os
import sys
import time
import threading
import subprocess
from collections import defaultdict, deque

# Framework / dil runtime'ı tarafından çağrılan, kodda explicit çağrısı olmayan
# üyeler — kök sayılır. getTypeHierarchy çoğunu zaten yakalar; bu hızlı yoldur.
FRAMEWORK_NAMES = {
    "build", "initState", "dispose", "didChangeDependencies", "didUpdateWidget",
    "createState", "createElement", "reassemble", "deactivate", "activate",
    "paint", "shouldRepaint", "hitTest", "shouldRebuildSemantics", "addListener",
    "wantKeepAlive", "updateRenderObject", "createRenderObject",
    "debugFillProperties", "didChangeAppLifecycleState", "didChangeMetrics",
    "didChangePlatformBrightness", "didChangeLocales", "didHaveMemoryPressure",
    "toString", "hashCode", "noSuchMethod", "call", "main",
    "fromJson", "toJson",
}
DI_ANNOTATIONS = ("@injectable", "@singleton", "@lazySingleton", "@module",
                  "@LazySingleton", "@Singleton", "@Injectable", "@Environment")

DECL_KINDS = {"CLASS", "ENUM", "MIXIN", "EXTENSION", "ENUM_CONSTANT", "METHOD",
              "GETTER", "SETTER", "FIELD", "CONSTRUCTOR", "FUNCTION",
              "TOP_LEVEL_VARIABLE", "CLASS_TYPE_ALIAS", "FUNCTION_TYPE_ALIAS",
              "TYPE_ALIAS"}
TYPE_KINDS = {"CLASS", "ENUM", "MIXIN", "EXTENSION"}
OVERRIDABLE = {"METHOD", "GETTER", "SETTER", "FIELD"}


def find_project_root(start):
    d = os.path.abspath(start)
    while True:
        if os.path.exists(os.path.join(d, "pubspec.yaml")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            raise SystemExit("pubspec.yaml bulunamadı — --project ile belirtin.")
        d = parent


class AnalysisServer:
    """Analysis server ile konuşur; stdout'u arka plan thread'i boşaltır."""

    def __init__(self):
        self.proc = subprocess.Popen(
            ["dart", "language-server", "--protocol", "analyzer",
             "--client-id", "deadcode-analyzer"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, bufsize=0,
        )
        self._id = 0
        self._lock = threading.Lock()
        self._responses = {}
        self._analyzing = None
        self._outlines = {}
        self._navs = {}
        self._dead = False
        threading.Thread(target=self._reader, daemon=True).start()

    def _reader(self):
        buf = b""
        while True:
            try:
                chunk = self.proc.stdout.read(65536)
            except (OSError, ValueError):
                chunk = b""
            if not chunk:
                break
            buf += chunk
            while b"\n" in buf:
                raw, buf = buf.split(b"\n", 1)
                raw = raw.strip()
                if not raw:
                    continue
                try:
                    msg = json.loads(raw.decode("utf-8"))
                except (json.JSONDecodeError, UnicodeDecodeError):
                    continue
                with self._lock:
                    self._dispatch(msg)
        self._dead = True

    def _dispatch(self, msg):
        if "id" in msg and "event" not in msg:
            self._responses[msg["id"]] = msg
        elif msg.get("event") == "server.status":
            a = msg.get("params", {}).get("analysis")
            if a is not None and "isAnalyzing" in a:
                self._analyzing = a["isAnalyzing"]
        elif msg.get("event") == "analysis.outline":
            p = msg["params"]
            self._outlines[p["file"]] = p["outline"]
        elif msg.get("event") == "analysis.navigation":
            p = msg["params"]
            self._navs[p["file"]] = p

    def _send(self, method, params):
        self._id += 1
        rid = str(self._id)
        payload = json.dumps(
            {"id": rid, "method": method, "params": params}) + "\n"
        self.proc.stdin.write(payload.encode("utf-8"))
        self.proc.stdin.flush()
        return rid

    def _wait(self, predicate, timeout):
        deadline = time.time() + timeout
        while True:
            with self._lock:
                if predicate():
                    return
            if self._dead:
                raise RuntimeError("analysis server kapandı")
            if time.time() > deadline:
                raise TimeoutError("analysis server yanıt vermedi")
            time.sleep(0.02)

    def request(self, method, params, timeout=120):
        rid = self._send(method, params)
        self._wait(lambda: rid in self._responses, timeout)
        with self._lock:
            msg = self._responses.pop(rid)
        if "error" in msg:
            raise RuntimeError(f"{method}: {msg['error']}")
        return msg.get("result", {})

    def collect(self, lib_files, test_files):
        """OUTLINE (lib) + NAVIGATION (lib+test) abone ol, hepsini topla."""
        nav_files = lib_files + test_files
        self.request("server.setSubscriptions", {"subscriptions": ["STATUS"]})
        self.request("analysis.setSubscriptions",
                     {"subscriptions": {"OUTLINE": lib_files,
                                        "NAVIGATION": nav_files}})
        want_o, want_n = set(lib_files), set(nav_files)
        self._wait(lambda: want_o.issubset(self._outlines.keys())
                   and want_n.issubset(self._navs.keys()), timeout=600)
        with self._lock:
            return ({f: self._outlines[f] for f in lib_files},
                    {f: self._navs[f] for f in nav_files})

    def type_hierarchy(self, file, offset, timeout=60):
        res = self.request("search.getTypeHierarchy",
                           {"file": file, "offset": offset}, timeout)
        return res.get("hierarchyItems", []) or []

    def shutdown(self):
        for fn in (lambda: self.request("server.shutdown", {}, 10),
                   self.proc.terminate):
            try:
                fn()
            except Exception:
                pass


def walk_outline(node, file, nodes, enclosing=""):
    """Outline ağacını gez — her bildirimi (yerel fonksiyonlar dahil) `nodes`'a
    span'iyle ekle."""
    el = node.get("element", {})
    kind = el.get("kind", "")
    name = el.get("name") or ""
    loc = el.get("location")
    if loc and name and kind in DECL_KINDS:
        start = node.get("offset", 0)
        nodes[(file, loc["offset"])] = {
            "name": name, "kind": kind, "file": file,
            "offset": loc["offset"], "line": loc.get("startLine", 0),
            "enclosing": enclosing,
            "span": (start, start + node.get("length", 0)),
        }
    child_enc = name if kind in TYPE_KINDS else enclosing
    for c in node.get("children", []):
        walk_outline(c, file, nodes, child_enc)


def read_window(file, offset, back=260):
    try:
        with open(file, encoding="utf-8") as fh:
            src = fh.read()
    except (OSError, UnicodeDecodeError):
        return ""
    return src[max(0, offset - back):offset]


def main():
    pretty = "--pretty" in sys.argv
    log = lambda m: print(m, file=sys.stderr, flush=True)

    root = None
    if "--project" in sys.argv:
        root = os.path.abspath(sys.argv[sys.argv.index("--project") + 1])
    root = find_project_root(root or os.getcwd())
    lib = os.path.join(root, "lib")
    test = os.path.join(root, "test")

    lib_files = sorted(os.path.join(d, f)
                       for d, _, fs in os.walk(lib)
                       for f in fs if f.endswith(".dart"))
    test_files = sorted(os.path.join(d, f)
                        for d, _, fs in os.walk(test)
                        for f in fs if f.endswith(".dart")) \
        if os.path.isdir(test) else []
    if not lib_files:
        raise SystemExit(f"lib/ içinde .dart dosyası yok: {lib}")

    log(f"proje: {root}")
    log("analysis server başlatılıyor...")
    srv = AnalysisServer()
    try:
        srv.request("analysis.setAnalysisRoots",
                    {"included": [root],
                     "excluded": [os.path.join(root, "build")]})
        log(f"{len(lib_files)} lib + {len(test_files)} test dosyası "
            f"çözümleniyor (OUTLINE + NAVIGATION)...")
        outs, navs = srv.collect(lib_files, test_files)

        # 1. Bildirim envanteri.
        nodes = {}
        for f, tree in outs.items():
            walk_outline(tree, f, nodes)
        log(f"{len(nodes)} bildirim.")

        # Dosya başına bildirim span indeksi (kaynak atfı için).
        by_file = defaultdict(list)
        for nid, m in nodes.items():
            by_file[m["file"]].append((m["span"][0], m["span"][1], nid))
        for v in by_file.values():
            v.sort(key=lambda x: x[1] - x[0])   # en dar span önce

        def innermost(file, offset):
            """offset'i içeren en dar bildirim (= referansın kaynağı)."""
            for s, e, nid in by_file.get(file, ()):
                if s <= offset < e:
                    return nid
            return None

        # 2. NAVIGATION'dan kenar grafiği.
        edges = defaultdict(set)       # source_id -> {target_id}
        rev = defaultdict(set)         # target_id -> {source_id}
        test_ref = set()
        SENT = ("<root>", 0)

        # Kapsama (containment) kenarları: bir üye canlıysa onu içeren tip de
        # canlıdır. (Sınıf yalnızca instantiate ediliyorsa NAVIGATION
        # constructor'a işaret eder; sınıf düğümü ayrı kalır — bu kenar onu
        # diriltir.) Tersi DEĞİL: tip canlı diye üyeleri canlı olmaz.
        type_node = {(m["file"], m["name"]): nid
                     for nid, m in nodes.items() if m["kind"] in TYPE_KINDS}
        for nid, m in nodes.items():
            if m["kind"] not in TYPE_KINDS and m["enclosing"]:
                owner = type_node.get((m["file"], m["enclosing"]))
                if owner is not None and owner != nid:
                    edges[nid].add(owner)   # yalnızca sweep için; rev'e değil
                    # (rev gerçek referansları tutar — "neden ölü" için)

        log("referans grafiği kuruluyor (NAVIGATION)...")
        for f, nav in navs.items():
            nfiles = nav.get("files", [])
            targets = nav.get("targets", [])
            is_test = f.startswith(test + os.sep)
            for reg in nav.get("regions", []):
                src = None if is_test else innermost(f, reg["offset"])
                for ti in reg.get("targets", []):
                    if ti >= len(targets):
                        continue
                    t = targets[ti]
                    fi = t.get("fileIndex", -1)
                    if not (0 <= fi < len(nfiles)):
                        continue
                    tid = (nfiles[fi], t.get("offset", -1))
                    if tid not in nodes:
                        continue
                    if is_test:
                        test_ref.add(tid)
                    elif src is not None and src != tid:
                        edges[src].add(tid)
                        rev[tid].add(src)
                    elif src is None:
                        edges[SENT].add(tid)   # dosya düzeyi (import vs.)

        # 3. Kök kümesi.
        main_dart = os.path.join(lib, "main.dart")
        roots = set(edges[SENT])
        di_classes = set()
        for nid, meta in nodes.items():
            name, kind = meta["name"], meta["kind"]
            win = read_window(meta["file"], meta["offset"])
            if name == "main" and meta["file"] == main_dart:
                roots.add(nid)
            elif name in FRAMEWORK_NAMES:
                roots.add(nid)
            elif "@pragma" in win and "vm:entry-point" in win:
                roots.add(nid)
            if kind == "CLASS" and any(a in win for a in DI_ANNOTATIONS):
                di_classes.add(name)
                roots.add(nid)
        for nid, meta in nodes.items():
            if meta["kind"] == "CONSTRUCTOR" and meta["enclosing"] in di_classes:
                roots.add(nid)

        # 4. Mark-and-sweep.
        def sweep(seed):
            live = set(seed)
            q = deque(seed)
            while q:
                for tgt in edges.get(q.popleft(), ()):
                    if tgt not in live:
                        live.add(tgt)
                        q.append(tgt)
            return live

        live = sweep(roots)

        # 5. Override uzlaştırma — yalnızca ölü üyeler için getTypeHierarchy.
        log("override ilişkileri uzlaştırılıyor (getTypeHierarchy)...")
        th_cache = {}
        rounds = 0
        while True:
            rounds += 1
            revived = set()
            dead_members = [n for n in nodes if n not in live
                            and nodes[n]["kind"] in OVERRIDABLE]
            for nid in dead_members:
                if nid not in th_cache:
                    meta = nodes[nid]
                    try:
                        items = srv.type_hierarchy(meta["file"], meta["offset"])
                    except (TimeoutError, RuntimeError):
                        items = []
                    fam, external = [], False
                    for it in items:
                        me = it.get("memberElement")
                        if not me or "location" not in me:
                            continue
                        ml = me["location"]
                        key = (ml["file"], ml["offset"])
                        if ml["file"].startswith(lib + os.sep):
                            fam.append(key)
                        else:
                            external = True
                    th_cache[nid] = (fam, external)
                fam, external = th_cache[nid]
                if external or any(k in live for k in fam):
                    revived.update(k for k in fam if k in nodes)
            revived -= live
            if not revived or rounds > 10:
                break
            live = sweep(live | revived)

        # 6. Sınıflandırma + çıktı.
        dead, test_only, enum_dead = [], [], []
        for nid, meta in nodes.items():
            if nid in live:
                continue
            entry = {k: meta[k] for k in ("name", "kind", "enclosing", "line")}
            entry["file"] = os.path.relpath(meta["file"], root)
            srcs = rev.get(nid, set())
            if nid in test_ref:
                entry["reason"] = "yalnızca testten referanslı"
                test_only.append(entry)
                continue
            if not srcs:
                entry["reason"] = "hiç referans yok"
            else:
                ex = nodes[next(iter(srcs))]["name"]
                entry["reason"] = f"yalnızca ölü kod tarafından kullanılıyor (ör. {ex})"
            (enum_dead if meta["kind"] == "ENUM_CONSTANT" else dead).append(entry)

        key = lambda x: (x["file"], x["line"])
        out = {
            "project": root,
            "nodes": len(nodes),
            "live": len(live),
            "dead": sorted(dead, key=key),
            "enum_dead": sorted(enum_dead, key=key),
            "test_only": sorted(test_only, key=key),
        }
        log(f"bitti: düğüm={len(nodes)} canlı={len(live)} ölü={len(dead)} "
            f"enum-ölü={len(enum_dead)} test-only={len(test_only)}")
        print(json.dumps(out, indent=2 if pretty else None, ensure_ascii=False))
        return 0
    finally:
        srv.shutdown()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        import traceback
        traceback.print_exc()
        sys.stderr.flush()
        sys.exit(1)
