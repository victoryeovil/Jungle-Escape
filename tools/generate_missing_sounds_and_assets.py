#!/usr/bin/env python3
"""Generate jump.wav, slide.wav, land.wav, map_piece.glb, sand_shoes_icon.png"""
from __future__ import annotations
import json
import math
import random
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# ─── WAV ─────────────────────────────────────────────────────────────────────

SR = 44100

def _write_wav(rel: str, samples: list):
    path = ROOT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    pcm = struct.pack(
        f"<{len(samples)}h",
        *[max(-32767, min(32767, int(s * 32767))) for s in samples],
    )
    with path.open("wb") as f:
        f.write(b"RIFF")
        f.write(struct.pack("<I", 36 + len(pcm)))
        f.write(b"WAVEfmt ")
        f.write(struct.pack("<IHHIIHH", 16, 1, 1, SR, SR * 2, 2, 16))
        f.write(b"data")
        f.write(struct.pack("<I", len(pcm)))
        f.write(pcm)
    print(f"  ok  {rel}")


def gen_jump():
    # Short ascending chirp: feet leaving the ground
    n = int(SR * 0.18)
    out = []
    for i in range(n):
        t = i / SR
        p = i / n
        freq = 260 + p * 380           # 260 → 640 Hz sweep
        env = math.exp(-p * 5.0) * (1 - math.exp(-p * 55))
        out.append(math.sin(2 * math.pi * freq * t) * env * 0.55)
    _write_wav("assets/sounds/jump.wav", out)


def gen_slide():
    # Low-pass noise swoosh: player sliding on ground
    n = int(SR * 0.30)
    rng = random.Random(7)
    out, prev = [], 0.0
    for i in range(n):
        p = i / n
        env = math.exp(-p * 5.5) * (1 - math.exp(-p * 55))
        noise = rng.uniform(-1, 1)
        filt = 0.28 * noise + 0.72 * prev  # LP filter → softer swoosh
        prev = filt
        out.append(filt * env * 0.65)
    _write_wav("assets/sounds/slide.wav", out)


def gen_land():
    # Thumpy impact: feet hitting the ground
    n = int(SR * 0.22)
    out = []
    for i in range(n):
        t = i / SR
        p = i / n
        env = math.exp(-p * 16.0) * (1 - math.exp(-p * 80))
        wave = (math.sin(2 * math.pi * 80  * t) * 0.65
              + math.sin(2 * math.pi * 160 * t) * 0.25
              + math.sin(2 * math.pi * 320 * t) * 0.10)
        out.append(wave * env * 0.75)
    _write_wav("assets/sounds/land.wav", out)


# ─── GLB (minimal self-contained writer) ─────────────────────────────────────

def _norm3(v):
    l = math.sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])
    return v if l < 1e-9 else (v[0]/l, v[1]/l, v[2]/l)


class _Prim:
    __slots__ = ("verts", "norms", "idxs", "mat")
    def __init__(self, mat):
        self.verts = []; self.norms = []; self.idxs = []; self.mat = mat


class GLBModel:
    def __init__(self, name: str):
        self.name = name
        self._prims: list[_Prim] = []
        self._mats: list[tuple] = []

    def _mat(self, rgba) -> int:
        rgba = tuple(max(0.0, min(1.0, float(c))) for c in rgba)
        if rgba not in self._mats:
            self._mats.append(rgba)
        return self._mats.index(rgba)

    def add_box(self, size, pos=(0,0,0), color=(0.5,0.5,0.5,1.0)):
        sx, sy, sz = size[0]/2, size[1]/2, size[2]/2
        faces = [
            ((0,0,1),  [(-sx,-sy, sz),(sx,-sy, sz),(sx,sy, sz),(-sx,sy, sz)]),
            ((0,0,-1), [( sx,-sy,-sz),(-sx,-sy,-sz),(-sx,sy,-sz),(sx,sy,-sz)]),
            ((1,0,0),  [( sx,-sy, sz),(sx,-sy,-sz),(sx,sy,-sz),(sx,sy, sz)]),
            ((-1,0,0), [(-sx,-sy,-sz),(-sx,-sy,sz),(-sx,sy,sz),(-sx,sy,-sz)]),
            ((0,1,0),  [(-sx,sy, sz),(sx,sy, sz),(sx,sy,-sz),(-sx,sy,-sz)]),
            ((0,-1,0), [(-sx,-sy,-sz),(sx,-sy,-sz),(sx,-sy,sz),(-sx,-sy,sz)]),
        ]
        p = _Prim(self._mat(color))
        for normal, corners in faces:
            base = len(p.verts)
            for c in corners:
                p.verts.append((c[0]+pos[0], c[1]+pos[1], c[2]+pos[2]))
                p.norms.append(normal)
            p.idxs.extend([base, base+1, base+2, base, base+2, base+3])
        self._prims.append(p)

    def add_cylinder(self, radius, height, pos=(0,0,0), color=(0.5,0.5,0.5,1.0),
                     segs=10, axis="y"):
        """axis='y' extends along Y; axis='z' extends along Z."""
        h = height / 2.0
        p = _Prim(self._mat(color))
        for i in range(segs):
            a0 = math.tau * i / segs
            a1 = math.tau * (i + 1) / segs
            c0, s0 = math.cos(a0), math.sin(a0)
            c1, s1 = math.cos(a1), math.sin(a1)

            if axis == "y":
                side = [
                    (radius*c0, -h, radius*s0),
                    (radius*c1, -h, radius*s1),
                    (radius*c1,  h, radius*s1),
                    (radius*c0,  h, radius*s0),
                ]
                side_n = lambda pt: _norm3((pt[0], 0.0, pt[2]))
                top_n, bot_n = (0,1,0), (0,-1,0)
                top_c, bot_c = (0, h, 0), (0, -h, 0)
            else:  # axis == "z"
                side = [
                    (radius*c0, radius*s0, -h),
                    (radius*c1, radius*s1, -h),
                    (radius*c1, radius*s1,  h),
                    (radius*c0, radius*s0,  h),
                ]
                side_n = lambda pt: _norm3((pt[0], pt[1], 0.0))
                top_n, bot_n = (0,0,1), (0,0,-1)
                top_c, bot_c = (0, 0, h), (0, 0, -h)

            # Side quad
            base = len(p.verts)
            for pt in side:
                p.verts.append((pt[0]+pos[0], pt[1]+pos[1], pt[2]+pos[2]))
                p.norms.append(side_n(pt))
            p.idxs.extend([base, base+1, base+2, base, base+2, base+3])

            # Top cap
            base = len(p.verts)
            for pt in [top_c, side[2], side[3]]:
                p.verts.append((pt[0]+pos[0], pt[1]+pos[1], pt[2]+pos[2]))
                p.norms.append(top_n)
            p.idxs.extend([base, base+1, base+2])

            # Bottom cap
            base = len(p.verts)
            for pt in [bot_c, side[0], side[1]]:
                p.verts.append((pt[0]+pos[0], pt[1]+pos[1], pt[2]+pos[2]))
                p.norms.append(bot_n)
            p.idxs.extend([base, base+2, base+1])

        self._prims.append(p)

    def save(self, rel: str):
        path = ROOT / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        _write_glb(path, self)
        print(f"  ok  {rel}")


def _pack_accessor(blob, data, comp_type, gltf_type):
    while len(blob) % 4:
        blob.extend(b"\x00")
    offset = len(blob)
    if gltf_type == "VEC3":
        flat = [c for row in data for c in row]
        blob.extend(struct.pack("<" + "f" * len(flat), *flat))
        count = len(data)
        mins = [min(r[i] for r in data) for i in range(3)]
        maxs = [max(r[i] for r in data) for i in range(3)]
        return offset, 12 * count, count, mins, maxs
    if comp_type == 5123:
        blob.extend(struct.pack("<" + "H" * len(data), *data))
        return offset, 2 * len(data), len(data), None, None
    blob.extend(struct.pack("<" + "I" * len(data), *data))
    return offset, 4 * len(data), len(data), None, None


def _write_glb(path: Path, model: GLBModel):
    blob = bytearray()
    bviews, accessors, prims = [], [], []

    for prim in model._prims:
        attrs = {}
        for attr, gkey in [("verts", "POSITION"), ("norms", "NORMAL")]:
            data = getattr(prim, attr)
            off, bl, count, mn, mx = _pack_accessor(blob, data, 5126, "VEC3")
            bviews.append({"buffer": 0, "byteOffset": off, "byteLength": bl, "target": 34962})
            acc = {"bufferView": len(bviews)-1, "componentType": 5126, "count": count, "type": "VEC3"}
            if mn is not None:
                acc["min"] = mn; acc["max"] = mx
            accessors.append(acc)
            attrs[gkey] = len(accessors) - 1

        ct = 5123 if len(prim.verts) < 65535 else 5125
        off, bl, count, *_ = _pack_accessor(blob, prim.idxs, ct, "SCALAR")
        bviews.append({"buffer": 0, "byteOffset": off, "byteLength": bl, "target": 34963})
        accessors.append({"bufferView": len(bviews)-1, "componentType": ct, "count": count, "type": "SCALAR"})
        prims.append({"attributes": attrs, "indices": len(accessors)-1, "material": prim.mat})

    while len(blob) % 4:
        blob.extend(b"\x00")

    gltf = {
        "asset": {"version": "2.0", "generator": "Jungle Escape asset gen"},
        "scene": 0,
        "scenes": [{"nodes": [0]}],
        "nodes": [{"name": model.name, "mesh": 0}],
        "meshes": [{"name": model.name + "_mesh", "primitives": prims}],
        "materials": [
            {
                "name": f"m{i}",
                "pbrMetallicRoughness": {
                    "baseColorFactor": list(c),
                    "metallicFactor": 0.0,
                    "roughnessFactor": 0.85,
                },
                "alphaMode": "BLEND" if c[3] < 1.0 else "OPAQUE",
            }
            for i, c in enumerate(model._mats)
        ],
        "buffers": [{"byteLength": len(blob)}],
        "bufferViews": bviews,
        "accessors": accessors,
    }
    jb = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    while len(jb) % 4:
        jb += b" "
    total = 12 + 8 + len(jb) + 8 + len(blob)
    with path.open("wb") as f:
        f.write(struct.pack("<4sII", b"glTF", 2, total))
        f.write(struct.pack("<I4s", len(jb), b"JSON"))
        f.write(jb)
        f.write(struct.pack("<I4s", len(blob), b"BIN\x00"))
        f.write(blob)


def gen_map_piece():
    m = GLBModel("map_piece")
    PARCHMENT      = (0.86, 0.74, 0.48, 1.0)
    PARCHMENT_DARK = (0.66, 0.52, 0.30, 1.0)
    ROLL           = (0.72, 0.57, 0.34, 1.0)

    # Flat parchment body
    m.add_box((0.58, 0.04, 0.44), (0, 0, 0), PARCHMENT)
    # Rolled ends (cylinders along Z)
    m.add_cylinder(0.046, 0.44, (-0.29, 0, 0), ROLL, segs=10, axis="z")
    m.add_cylinder(0.046, 0.44, ( 0.29, 0, 0), ROLL, segs=10, axis="z")
    # Binding strip across the middle
    m.add_box((0.042, 0.09, 0.46), (0, 0, 0), PARCHMENT_DARK)

    m.save("assets/3d/collectibles/map_piece.glb")


# ─── PNG ─────────────────────────────────────────────────────────────────────

def _png_chunk(tag: bytes, data: bytes) -> bytes:
    crc = zlib.crc32(tag + data) & 0xFFFFFFFF
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)


def _write_png(rel: str, pixels):
    """pixels[y][x] = (r, g, b, a) each 0-255."""
    H = len(pixels)
    W = len(pixels[0])
    raw = bytearray()
    for row in pixels:
        raw.append(0)   # filter type: None
        for r, g, b, a in row:
            raw.extend((r, g, b, a))
    path = ROOT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(_png_chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0)))
        f.write(_png_chunk(b"IDAT", zlib.compress(bytes(raw), 9)))
        f.write(_png_chunk(b"IEND", b""))
    print(f"  ok  {rel}")


def gen_sand_shoes_icon():
    W, H = 64, 64
    img = [[(0, 0, 0, 0)] * W for _ in range(H)]

    SANDY   = (200, 155,  82, 255)   # main upper
    LIGHT   = (228, 192, 118, 255)   # highlight
    SOLE    = ( 72,  42,  16, 255)   # dark sole
    SEAM    = (145,  95,  40, 255)   # seam / shadow detail
    OUTLINE = ( 32,  16,   4, 255)   # dark edge

    def px(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            img[y][x] = c

    def rect(x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                px(x, y, c)

    def ellipse(cx, cy, rx, ry, c):
        for dy in range(-ry, ry + 1):
            for dx in range(-rx, rx + 1):
                if dx*dx*ry*ry + dy*dy*rx*rx <= rx*rx*ry*ry:
                    px(cx + dx, cy + dy, c)

    # ── Outline silhouette ──────────────────────────────────────────────────
    # Sole outline
    rect(4, 46, 60, 58, OUTLINE)
    rect(6, 58, 58, 62, OUTLINE)
    # Toe ellipse outline
    ellipse(11, 42, 11, 10, OUTLINE)
    # Upper scanlines outline (1 px wider than fill)
    for y in range(11, 47):
        if y < 20:
            x0, x1 = 45, 59
        elif y < 30:
            frac = (y - 20) / 10.0
            x0 = int(45 - frac * 33)
            x1 = 59
        else:
            x0, x1 = 4, 59
        rect(x0, y, x1, y + 1, OUTLINE)

    # ── Sole ────────────────────────────────────────────────────────────────
    rect(5, 47, 59, 57, SOLE)
    rect(7, 57, 57, 61, SOLE)

    # ── Upper body ──────────────────────────────────────────────────────────
    for y in range(12, 46):
        if y < 21:
            x0, x1 = 46, 58
        elif y < 31:
            frac = (y - 21) / 10.0
            x0 = int(46 - frac * 35)
            x1 = 58
        else:
            x0, x1 = 5, 58
        for x in range(x0, x1):
            img[y][x] = SANDY

    # ── Toe cap ─────────────────────────────────────────────────────────────
    ellipse(11, 42, 10, 9, SANDY)

    # ── Ankle collar (shoe opening) ──────────────────────────────────────────
    rect(44, 12, 57, 21, SEAM)
    rect(45, 13, 56, 20, LIGHT)

    # ── Toe highlight ────────────────────────────────────────────────────────
    ellipse(10, 37, 5, 3, LIGHT)

    # ── Sole-upper seam line ─────────────────────────────────────────────────
    rect(5, 47, 59, 49, SEAM)

    # ── Heel back line ───────────────────────────────────────────────────────
    rect(56, 21, 58, 47, SEAM)

    # ── Side seam (stitching visual) ─────────────────────────────────────────
    for y in range(22, 45, 3):
        rect(5, y, 7, y + 2, SEAM)

    # ── Sandy texture dots on vamp ───────────────────────────────────────────
    for cx, cy in [(20, 34), (30, 30), (38, 36), (26, 41), (44, 32), (34, 42), (46, 39)]:
        ellipse(cx, cy, 1, 1, SEAM)

    _write_png("assets/ui/upgrades/sand_shoes_icon.png", img)


if __name__ == "__main__":
    print("Generating missing assets…")
    gen_jump()
    gen_slide()
    gen_land()
    gen_map_piece()
    gen_sand_shoes_icon()
    print("All done.")
