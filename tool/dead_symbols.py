#!/usr/bin/env python3
"""Semantik ölü-kod dedektörü — Dart Analysis Server sürücüsü.

`dart language-server --protocol analyzer` sürecini başlatır:
  1. Tüm `lib/` dosyalarının OUTLINE'ını alır → her method/getter/field'ın
     adı + tam offset'i (tip çözümlemeli, semantik).
  2. Her public üye için `search.findElementReferences` çalıştırır — bu, IDE'nin
     "Find Usages" özelliğinin aynısıdır; `x.dispose()` çağrısının hangi sınıfa
     gittiğini bilir (regex bunu yapamaz).

Salt-okunur. Çıktı: stdout'a JSON. `tool/analyze_deps.py` çağırır; tek başına da
çalışır:  python3 tool/dead_symbols.py [--pretty]

Sınır: %100 değil — string/reflection çağrıları yakalanmaz (Flutter'da pratikte
yok). `@override` ve framework callback'leri yanlış-pozitif olmasın diye elenir.
"""
from __future__ import annotations
import json
import os
import sys
import time
import threading
import subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
TEST = os.path.join(ROOT, "test")

# Framework / dil tarafından çağrılan, kodda explicit referansı olmayan üyeler.
FRAMEWORK_NAMES = {
    "build", "initState", "dispose", "didChangeDependencies", "didUpdateWidget",
    "createState", "createElement", "reassemble", "deactivate", "activate",
    "paint", "shouldRepaint", "hitTest", "shouldRebuildSemantics", "addListener",
    "wantKeepAlive", "updateRenderObject", "createRenderObject", "debugFillProperties",
    "didChangeAppLifecycleState", "didChangeMetrics", "didChangePlatformBrightness",
    "toString", "hashCode", "noSuchMethod", "main", "call",
    "fromJson", "toJson", "copyWith", "props",  # codegen / equatable
}

# OUTLINE'dan referans sorgulanacak üye türleri (sınıf/enum vb. analyze_deps
# tarafından zaten kapsanıyor; burada blind-spot olan üyelere odaklan).
MEMBER_KINDS = {"METHOD", "GETTER", "SETTER", "FIELD", "FUNCTION",
                "TOP_LEVEL_VARIABLE"}


class AnalysisServer:
    """Analysis server ile konuşur — stdout'u arka plan thread'i sürekli boşaltır
    (senkron okuma pipe-buffer deadlock'una yol açabiliyordu)."""

    def __init__(self):
        # bufsize=0 (unbuffered, binary): raw pipe okuması veri gelir gelmez
        # döner — text-mode buffer'lı okumanın deadlock'unu önler.
        self.proc = subprocess.Popen(
            ["dart", "language-server", "--protocol", "analyzer",
             "--client-id", "torcav-deadcode"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, bufsize=0,
        )
        self._id = 0
        self._lock = threading.Lock()
        self._responses = {}
        self._search_results = {}
        self._search_done = set()
        self._analyzing = None
        self._outlines = {}           # file -> outline tree
        self._dead = False
        t = threading.Thread(target=self._reader, daemon=True)
        t.start()

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
        # Başarılı yanıtlarda "result" alanı boşsa hiç gönderilmiyor —
        # yanıtı "id var, event yok" diye tanı.
        if "id" in msg and "event" not in msg:
            self._responses[msg["id"]] = msg
        elif msg.get("event") == "server.status":
            a = msg.get("params", {}).get("analysis")
            if a is not None and "isAnalyzing" in a:
                self._analyzing = a["isAnalyzing"]
        elif msg.get("event") == "analysis.outline":
            p = msg["params"]
            self._outlines[p["file"]] = p["outline"]
        elif msg.get("event") == "search.results":
            p = msg["params"]
            self._search_results.setdefault(p["id"], []).extend(p["results"])
            if p.get("isLast"):
                self._search_done.add(p["id"])

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
                raise RuntimeError("analysis server beklenmedik şekilde kapandı")
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

    def start(self, root):
        self.request("server.setSubscriptions", {"subscriptions": ["STATUS"]})
        self.request("analysis.setAnalysisRoots",
                     {"included": [root],
                      "excluded": [os.path.join(root, "build")]})

    def outlines(self, files):
        """OUTLINE'a abone ol; tüm dosyaların ağacı gelene dek bekle.

        OUTLINE notification'ları ancak dosya çözümlendikten sonra gelir, yani
        bu bekleme aynı zamanda analizin bitmesini de garanti eder."""
        self.request("analysis.setSubscriptions",
                     {"subscriptions": {"OUTLINE": files}})
        want = set(files)
        self._wait(lambda: want.issubset(self._outlines.keys()), timeout=420)
        # Analizin tam oturması için (search index hazır olsun) kısa bekleme.
        try:
            self._wait(lambda: self._analyzing is False, timeout=30)
        except TimeoutError:
            pass
        with self._lock:
            return {f: self._outlines[f] for f in files}

    def references(self, file, offset, timeout=60):
        res = self.request(
            "search.findElementReferences",
            {"file": file, "offset": offset, "includePotential": False}, timeout)
        sid = res.get("id")
        if sid is None:
            return []
        self._wait(lambda: sid in self._search_done, timeout)
        with self._lock:
            return self._search_results.pop(sid, [])

    def shutdown(self):
        for fn in (lambda: self.request("server.shutdown", {}, 10),
                   self.proc.terminate):
            try:
                fn()
            except Exception:
                pass


_TYPE_KINDS = ("CLASS", "ENUM", "MIXIN", "EXTENSION")


def walk_outline(node, file, out, enclosing="", inside_member=False):
    """Outline ağacını gez; ilgili üye bildirimlerini `out`'a ekle.

    `inside_member`: bir method/getter gövdesinin İÇİNDEYİZ demektir — oradaki
    yerel fonksiyonlar (local function/closure) atlanır. Analysis server'ın
    `findElementReferences`'ı yerel elemanları güvenilir indekslemiyor; onları
    ölü sanıp yanlış pozitif üretmemek için kapsam dışı bırakılır."""
    el = node.get("element", {})
    kind = el.get("kind", "")
    name = el.get("name") or ""
    loc = el.get("location")
    if (kind in MEMBER_KINDS and name and not name.startswith("_")
            and loc and not inside_member):
        out.append({
            "name": name, "kind": kind, "file": file,
            "offset": loc["offset"], "line": loc.get("startLine", 0),
            "enclosing": enclosing,
        })
    child_enc = name if kind in _TYPE_KINDS else enclosing
    # Bir üyenin (method/getter/field/fonksiyon) gövdesine indiğimizde
    # alt düğümler yereldir.
    child_inside = inside_member or kind in MEMBER_KINDS or kind == "CONSTRUCTOR"
    for c in node.get("children", []):
        walk_outline(c, file, out, child_enc, child_inside)


def has_skip_annotation(file, offset):
    """Bildirim öncesi kısa pencerede @override / framework annotation'ı var mı?"""
    try:
        with open(file, encoding="utf-8") as fh:
            src = fh.read()
    except (OSError, UnicodeDecodeError):
        return False
    window = src[max(0, offset - 240):offset]
    return any(a in window for a in
               ("@override", "@protected", "@visibleForTesting",
                "@mustCallSuper", "@pragma"))


def main():
    pretty = "--pretty" in sys.argv
    log = lambda m: print(m, file=sys.stderr, flush=True)

    lib_files = []
    for d, _, fs in os.walk(LIB):
        for f in fs:
            if f.endswith(".dart"):
                lib_files.append(os.path.join(d, f))
    lib_files.sort()

    log("analysis server başlatılıyor...")
    srv = AnalysisServer()
    try:
        srv.start(ROOT)
        log(f"proje çözümleniyor, {len(lib_files)} dosyanın OUTLINE'ı alınıyor...")
        outs = srv.outlines(lib_files)
        log(f"OUTLINE tamam ({len(outs)} dosya).")

        candidates = []
        for f, tree in outs.items():
            walk_outline(tree, f, candidates)
        # Skip listesindeki adları ele.
        candidates = [c for c in candidates if c["name"] not in FRAMEWORK_NAMES]

        log(f"{len(candidates)} public üye referans için sorgulanıyor "
            f"(IDE 'Find Usages')...")
        dead, test_only, internal = [], [], []
        for i, c in enumerate(candidates):
            if i and i % 250 == 0:
                log(f"  {i}/{len(candidates)}")
            try:
                refs = srv.references(c["file"], c["offset"])
            except (TimeoutError, RuntimeError):
                continue
            ext = set()
            for ref in refs:
                rl = ref["location"]
                if rl["file"] == c["file"] and rl["offset"] == c["offset"]:
                    continue  # bildirimin kendisi
                ext.add(rl["file"])
            entry = {k: c[k] for k in ("name", "kind", "enclosing", "line")}
            entry["file"] = os.path.relpath(c["file"], ROOT)
            non_test = {f for f in ext if not f.startswith(TEST + os.sep)}
            if not ext:
                if has_skip_annotation(c["file"], c["offset"]):
                    continue
                dead.append(entry)
            elif not non_test:
                test_only.append(entry)
            elif non_test == {c["file"]}:
                internal.append(entry)

        key = lambda x: (x["file"], x["line"])
        out = {
            "scanned": len(candidates),
            "dead": sorted(dead, key=key),
            "test_only": sorted(test_only, key=key),
            "internal": sorted(internal, key=key),
        }
        log(f"bitti: ölü={len(dead)} test-only={len(test_only)} "
            f"internal={len(internal)}")
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
