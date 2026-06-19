from __future__ import annotations

import json
import math
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


COLORS = {
    "dirt": (0.47, 0.31, 0.16, 1.0),
    "dirt_light": (0.62, 0.43, 0.23, 1.0),
    "grass": (0.16, 0.52, 0.18, 1.0),
    "grass_light": (0.32, 0.72, 0.26, 1.0),
    "grass_dark": (0.08, 0.28, 0.10, 1.0),
    "leaf": (0.12, 0.48, 0.16, 1.0),
    "palm": (0.18, 0.62, 0.20, 1.0),
    "trunk": (0.36, 0.22, 0.10, 1.0),
    "log": (0.45, 0.28, 0.12, 1.0),
    "rock": (0.48, 0.49, 0.46, 1.0),
    "rock_dark": (0.30, 0.31, 0.29, 1.0),
    "stone": (0.46, 0.45, 0.39, 1.0),
    "stone_dark": (0.30, 0.31, 0.28, 1.0),
    "moss": (0.24, 0.48, 0.18, 1.0),
    "water": (0.10, 0.42, 0.66, 0.88),
    "water_light": (0.25, 0.72, 0.86, 0.78),
    "mud": (0.24, 0.15, 0.08, 1.0),
    "gold": (1.00, 0.78, 0.12, 1.0),
    "gem": (0.10, 0.72, 1.00, 1.0),
    "sun": (1.00, 0.58, 0.06, 1.0),
    "danger": (0.70, 0.18, 0.12, 1.0),
    "black": (0.04, 0.035, 0.03, 1.0),
    "white": (0.92, 0.90, 0.82, 1.0),
    "sand": (0.74, 0.58, 0.34, 1.0),
    "hide": (0.47, 0.30, 0.14, 1.0),
    "hide_dark": (0.23, 0.14, 0.08, 1.0),
    "lion": (0.78, 0.52, 0.20, 1.0),
    "leopard": (0.86, 0.62, 0.24, 1.0),
    "frog": (0.18, 0.58, 0.18, 1.0),
    "bird_blue": (0.10, 0.32, 0.78, 1.0),
    "bird_red": (0.80, 0.12, 0.08, 1.0),
    "croc": (0.15, 0.34, 0.14, 1.0),
}


def clamp_color(color):
    return tuple(max(0.0, min(1.0, float(c))) for c in color)


def add(a, b):
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def sub(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def cross(a, b):
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def length(v):
    return math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])


def normalize(v):
    l = length(v)
    if l <= 0.000001:
        return (0.0, 1.0, 0.0)
    return (v[0] / l, v[1] / l, v[2] / l)


def rotate(v, rot_deg):
    rx, ry, rz = (math.radians(r) for r in rot_deg)
    x, y, z = v
    cy, sy = math.cos(rx), math.sin(rx)
    y, z = y * cy - z * sy, y * sy + z * cy
    cy, sy = math.cos(ry), math.sin(ry)
    x, z = x * cy + z * sy, -x * sy + z * cy
    cy, sy = math.cos(rz), math.sin(rz)
    x, y = x * cy - y * sy, x * sy + y * cy
    return (x, y, z)


def transform_point(v, pos, rot_deg, scale):
    return add(rotate((v[0] * scale[0], v[1] * scale[1], v[2] * scale[2]), rot_deg), pos)


class Model:
    def __init__(self, name: str):
        self.name = name
        self.primitives = []
        self.materials = []
        self.material_lookup = {}

    def material(self, color_name_or_rgba):
        color = COLORS.get(color_name_or_rgba, color_name_or_rgba)
        color = clamp_color(color)
        key = tuple(round(c, 4) for c in color)
        if key in self.material_lookup:
            return self.material_lookup[key]
        idx = len(self.materials)
        self.materials.append(key)
        self.material_lookup[key] = idx
        return idx

    def add_mesh(self, vertices, normals, indices, color):
        self.primitives.append(
            {
                "vertices": vertices,
                "normals": normals,
                "indices": indices,
                "material": self.material(color),
            }
        )

    def add_flat_faces(self, points, faces, color, pos=(0, 0, 0), rot=(0, 0, 0), scale=(1, 1, 1)):
        vertices = []
        normals = []
        indices = []
        for face in faces:
            base = len(vertices)
            p0 = transform_point(points[face[0]], pos, rot, scale)
            p1 = transform_point(points[face[1]], pos, rot, scale)
            p2 = transform_point(points[face[2]], pos, rot, scale)
            normal = normalize(cross(sub(p1, p0), sub(p2, p0)))
            for idx in face:
                vertices.append(transform_point(points[idx], pos, rot, scale))
                normals.append(normal)
            indices.extend([base, base + 1, base + 2])
        self.add_mesh(vertices, normals, indices, color)

    def add_box(self, name, size, pos=(0, 0, 0), color="stone", rot=(0, 0, 0)):
        sx, sy, sz = size[0] / 2, size[1] / 2, size[2] / 2
        faces = [
            ((0, 0, 1), [(-sx, -sy, sz), (sx, -sy, sz), (sx, sy, sz), (-sx, sy, sz)]),
            ((0, 0, -1), [(sx, -sy, -sz), (-sx, -sy, -sz), (-sx, sy, -sz), (sx, sy, -sz)]),
            ((1, 0, 0), [(sx, -sy, sz), (sx, -sy, -sz), (sx, sy, -sz), (sx, sy, sz)]),
            ((-1, 0, 0), [(-sx, -sy, -sz), (-sx, -sy, sz), (-sx, sy, sz), (-sx, sy, -sz)]),
            ((0, 1, 0), [(-sx, sy, sz), (sx, sy, sz), (sx, sy, -sz), (-sx, sy, -sz)]),
            ((0, -1, 0), [(-sx, -sy, -sz), (sx, -sy, -sz), (sx, -sy, sz), (-sx, -sy, sz)]),
        ]
        vertices, normals, indices = [], [], []
        for normal, corners in faces:
            base = len(vertices)
            rn = normalize(rotate(normal, rot))
            for c in corners:
                vertices.append(transform_point(c, pos, rot, (1, 1, 1)))
                normals.append(rn)
            indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        self.add_mesh(vertices, normals, indices, color)

    def add_cylinder(
        self,
        name,
        radius=0.5,
        height=1.0,
        pos=(0, 0, 0),
        color="stone",
        rot=(0, 0, 0),
        segments=10,
        top_radius=None,
        bottom_radius=None,
    ):
        top_radius = radius if top_radius is None else top_radius
        bottom_radius = radius if bottom_radius is None else bottom_radius
        vertices, normals, indices = [], [], []
        h = height / 2.0
        for i in range(segments):
            a0 = math.tau * i / segments
            a1 = math.tau * (i + 1) / segments
            cb0, sb0 = math.cos(a0), math.sin(a0)
            cb1, sb1 = math.cos(a1), math.sin(a1)
            side = [
                (bottom_radius * cb0, -h, bottom_radius * sb0),
                (bottom_radius * cb1, -h, bottom_radius * sb1),
                (top_radius * cb1, h, top_radius * sb1),
                (top_radius * cb0, h, top_radius * sb0),
            ]
            base = len(vertices)
            for p in side:
                vertices.append(transform_point(p, pos, rot, (1, 1, 1)))
                normals.append(normalize(rotate((p[0], (bottom_radius - top_radius) / max(height, 0.001), p[2]), rot)))
            indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])

            if top_radius > 0.0:
                base = len(vertices)
                for p in [(0, h, 0), side[2], side[3]]:
                    vertices.append(transform_point(p, pos, rot, (1, 1, 1)))
                    normals.append(normalize(rotate((0, 1, 0), rot)))
                indices.extend([base, base + 1, base + 2])

            if bottom_radius > 0.0:
                base = len(vertices)
                for p in [(0, -h, 0), side[0], side[1]]:
                    vertices.append(transform_point(p, pos, rot, (1, 1, 1)))
                    normals.append(normalize(rotate((0, -1, 0), rot)))
                indices.extend([base, base + 1, base + 2])
        self.add_mesh(vertices, normals, indices, color)

    def add_sphere(self, name, radius=0.5, pos=(0, 0, 0), color="stone", scale=(1, 1, 1), segments=10, rings=5):
        vertices, normals, indices = [], [], []
        for r in range(rings + 1):
            v = r / rings
            phi = math.pi * v
            for s in range(segments):
                u = s / segments
                theta = math.tau * u
                n = (math.sin(phi) * math.cos(theta), math.cos(phi), math.sin(phi) * math.sin(theta))
                vertices.append((pos[0] + n[0] * radius * scale[0], pos[1] + n[1] * radius * scale[1], pos[2] + n[2] * radius * scale[2]))
                normals.append(normalize(n))
        for r in range(rings):
            for s in range(segments):
                a = r * segments + s
                b = r * segments + (s + 1) % segments
                c = (r + 1) * segments + (s + 1) % segments
                d = (r + 1) * segments + s
                indices.extend([a, b, c, a, c, d])
        self.add_mesh(vertices, normals, indices, color)

    def add_octahedron(self, name, size=(0.5, 0.7, 0.5), pos=(0, 0, 0), color="gem", rot=(0, 0, 0)):
        sx, sy, sz = size
        points = [
            (0, sy, 0),
            (0, -sy, 0),
            (-sx, 0, 0),
            (sx, 0, 0),
            (0, 0, sz),
            (0, 0, -sz),
        ]
        faces = [
            (0, 4, 3), (0, 3, 5), (0, 5, 2), (0, 2, 4),
            (1, 3, 4), (1, 5, 3), (1, 2, 5), (1, 4, 2),
        ]
        self.add_flat_faces(points, faces, color, pos, rot)

    def save(self, rel_path: str):
        out = ROOT / rel_path
        out.parent.mkdir(parents=True, exist_ok=True)
        write_glb(out, self)
        return out


def pack_accessor(blob, data, component_type, gltf_type):
    while len(blob) % 4:
        blob.extend(b"\x00")
    offset = len(blob)
    if gltf_type == "VEC3":
        flat = [c for row in data for c in row]
        blob.extend(struct.pack("<" + "f" * len(flat), *flat))
        count = len(data)
        mins = [min(row[i] for row in data) for i in range(3)]
        maxs = [max(row[i] for row in data) for i in range(3)]
        byte_length = 12 * count
        return offset, byte_length, count, mins, maxs
    if component_type == 5123:
        blob.extend(struct.pack("<" + "H" * len(data), *data))
        byte_length = 2 * len(data)
    else:
        blob.extend(struct.pack("<" + "I" * len(data), *data))
        byte_length = 4 * len(data)
    return offset, byte_length, len(data), None, None


def write_glb(path: Path, model: Model):
    blob = bytearray()
    buffer_views = []
    accessors = []
    primitives = []

    for prim in model.primitives:
        attrs = {}
        for attr_name, gltf_key in [("vertices", "POSITION"), ("normals", "NORMAL")]:
            off, byte_length, count, mins, maxs = pack_accessor(blob, prim[attr_name], 5126, "VEC3")
            buffer_views.append({"buffer": 0, "byteOffset": off, "byteLength": byte_length, "target": 34962})
            accessor = {"bufferView": len(buffer_views) - 1, "componentType": 5126, "count": count, "type": "VEC3"}
            if mins is not None:
                accessor["min"] = mins
                accessor["max"] = maxs
            accessors.append(accessor)
            attrs[gltf_key] = len(accessors) - 1

        component_type = 5123 if len(prim["vertices"]) < 65535 else 5125
        off, byte_length, count, _, _ = pack_accessor(blob, prim["indices"], component_type, "SCALAR")
        buffer_views.append({"buffer": 0, "byteOffset": off, "byteLength": byte_length, "target": 34963})
        accessors.append({"bufferView": len(buffer_views) - 1, "componentType": component_type, "count": count, "type": "SCALAR"})
        primitives.append({"attributes": attrs, "indices": len(accessors) - 1, "material": prim["material"]})

    while len(blob) % 4:
        blob.extend(b"\x00")

    gltf = {
        "asset": {"version": "2.0", "generator": "Jungle Escape generated low-poly asset pipeline"},
        "scene": 0,
        "scenes": [{"nodes": [0]}],
        "nodes": [{"name": model.name, "mesh": 0}],
        "meshes": [{"name": model.name + "_mesh", "primitives": primitives}],
        "materials": [
            {
                "name": "mat_%02d" % i,
                "pbrMetallicRoughness": {"baseColorFactor": list(color), "metallicFactor": 0.0, "roughnessFactor": 0.88},
                "alphaMode": "BLEND" if color[3] < 1.0 else "OPAQUE",
            }
            for i, color in enumerate(model.materials)
        ],
        "buffers": [{"byteLength": len(blob)}],
        "bufferViews": buffer_views,
        "accessors": accessors,
    }

    json_bytes = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    while len(json_bytes) % 4:
        json_bytes += b" "
    total_len = 12 + 8 + len(json_bytes) + 8 + len(blob)
    with path.open("wb") as fh:
        fh.write(struct.pack("<4sII", b"glTF", 2, total_len))
        fh.write(struct.pack("<I4s", len(json_bytes), b"JSON"))
        fh.write(json_bytes)
        fh.write(struct.pack("<I4s", len(blob), b"BIN\x00"))
        fh.write(blob)


def add_grass_blades(m, origin=(0, 0, 0), count=8, spread=0.8):
    for i in range(count):
        x = origin[0] + math.sin(i * 2.17) * spread * (0.25 + 0.07 * (i % 3))
        z = origin[2] + math.cos(i * 1.73) * spread * (0.25 + 0.05 * (i % 2))
        h = 0.35 + 0.08 * (i % 4)
        rot = (10.0 * ((i % 3) - 1), 25.0 * i, 12.0 * ((i % 2) * 2 - 1))
        m.add_box("blade", (0.055, h, 0.045), (x, origin[1] + h * 0.5, z), "grass_light" if i % 2 else "grass", rot)


def add_tree(m, x, z, height=2.5, jungle=True):
    m.add_cylinder("trunk", 0.18, height, (x, height * 0.5, z), "trunk", segments=8, top_radius=0.12, bottom_radius=0.23)
    if jungle:
        for k in range(4):
            m.add_sphere("canopy", 0.65, (x + (k - 1.5) * 0.22, height + 0.25 + k * 0.12, z + (0.15 if k % 2 else -0.12)), "leaf", scale=(1.20, 0.70, 1.05))
    else:
        for k in range(7):
            angle = math.tau * k / 7
            m.add_box("frond", (0.15, 0.055, 1.20), (x + math.cos(angle) * 0.35, height + 0.08, z + math.sin(angle) * 0.35), "palm", (55, math.degrees(angle), 0))


def add_gate(m, name, stone="stone", glow=False):
    for sx in [-1.7, 1.7]:
        m.add_box("post", (0.55, 2.9, 0.55), (sx, 1.45, 0), stone)
        m.add_box("base", (0.85, 0.28, 0.75), (sx, 0.14, 0), "stone_dark")
        m.add_box("moss", (0.58, 0.08, 0.58), (sx, 2.45, 0), "moss")
    m.add_box("crossbar", (4.1, 0.45, 0.55), (0, 2.9, 0), stone)
    m.add_box("threshold", (4.8, 0.14, 0.7), (0, 0.07, 0), "stone_dark")
    if glow:
        m.add_sphere("portal_glow", 0.65, (0, 1.4, -0.08), (0.18, 0.88, 0.65, 0.65), scale=(1.1, 1.45, 0.18))


def add_quadruped(m, body_color, accent, scale=(1, 1, 1), horns=False, long_neck=False, mane=False, stripes=False, spots=False):
    sx, sy, sz = scale
    m.add_sphere("body", 0.55, (0, 0.85 * sy, 0), body_color, scale=(1.45 * sx, 0.70 * sy, 0.55 * sz), segments=10, rings=5)
    neck_y = 1.65 * sy if long_neck else 1.05 * sy
    neck_x = 0.75 * sx
    if long_neck:
        m.add_cylinder("neck", 0.12 * sx, 1.35 * sy, (0.55 * sx, 1.65 * sy, 0), body_color, (0, 0, -14), segments=8)
    m.add_sphere("head", 0.32, (neck_x, neck_y, 0), body_color, scale=(1.05 * sx, 0.85 * sy, 0.75 * sz), segments=8, rings=4)
    for lx in [-0.45, 0.45]:
        for lz in [-0.24, 0.24]:
            m.add_cylinder("leg", 0.075 * sx, 0.85 * sy, (lx * sx, 0.40 * sy, lz * sz), body_color, segments=6)
            m.add_box("hoof", (0.18 * sx, 0.06 * sy, 0.16 * sz), (lx * sx, 0.03 * sy, lz * sz), accent)
    m.add_cylinder("tail", 0.035 * sx, 0.55 * sx, (-0.82 * sx, 0.95 * sy, 0), accent, (0, 0, 72), segments=6)
    for ez in [-0.18, 0.18]:
        m.add_box("ear", (0.05 * sx, 0.28 * sy, 0.16 * sz), (neck_x + 0.05 * sx, neck_y + 0.28 * sy, ez * sz), accent, (0, 0, 20))
    if horns:
        for hz in [-0.17, 0.17]:
            m.add_cylinder("horn", 0.025 * sx, 0.45 * sx, (neck_x + 0.20 * sx, neck_y + 0.12 * sy, hz * sz), "white", (0, 0, 76), segments=6, top_radius=0.0, bottom_radius=0.045 * sx)
    if mane:
        m.add_sphere("mane", 0.45, (neck_x - 0.10 * sx, neck_y, 0), "hide_dark", scale=(0.80 * sx, 1.05 * sy, 0.90 * sz), segments=8, rings=4)
    if stripes:
        for i in range(7):
            m.add_box("stripe", (0.04 * sx, 0.72 * sy, 0.64 * sz), (-0.52 * sx + i * 0.17 * sx, 0.95 * sy, 0), "black", (0, 0, -18 if i % 2 else 18))
    if spots:
        for i in range(12):
            x = -0.55 * sx + (i % 6) * 0.22 * sx
            z = (-0.26 if i % 2 else 0.26) * sz
            m.add_sphere("spot", 0.055 * sx, (x, 1.10 * sy, z), "black", scale=(1, 0.28, 1), segments=6, rings=3)


def build_assets():
    assets = []

    def save(rel, model):
        assets.append(model.save(rel))

    m = Model("dirt_path_straight")
    m.add_box("path", (5.85, 0.14, 3.1), (0, 0, 0), "dirt")
    for x in [-2.15, -0.9, 0.35, 1.65]:
        m.add_box("packed_dirt_patch", (0.75, 0.025, 0.35), (x, 0.085, -0.45 + 0.25 * math.sin(x)), "dirt_light", (0, 20 * x, 0))
    save("assets/3d/environment/path/dirt_path_straight.glb", m)

    m = Model("dirt_path_edge")
    m.add_box("dirt_center", (5.85, 0.10, 3.0), (0, 0, 0), "dirt")
    for side in [-1, 1]:
        m.add_box("grass_blend", (1.2, 0.12, 3.0), (side * 3.15, 0.01, 0), "grass")
        add_grass_blades(m, (side * 2.55, 0.08, -0.7), 8, 0.9)
        add_grass_blades(m, (side * 2.95, 0.08, 0.8), 8, 0.9)
    save("assets/3d/environment/path/dirt_path_edge.glb", m)

    m = Model("grass_clumps")
    for x in [-0.8, 0.1, 0.8]:
        add_grass_blades(m, (x, 0, 0.25 * math.sin(x * 4)), 12, 0.85)
    save("assets/3d/environment/foliage/grass_clumps.glb", m)

    m = Model("ferns")
    for x in [-0.65, 0.25, 0.85]:
        m.add_cylinder("stem", 0.035, 0.55, (x, 0.27, 0), "grass_dark", segments=6)
        for k in range(6):
            angle = -70 + k * 28
            m.add_box("fern_leaf", (0.12, 0.04, 0.65), (x, 0.35 + k * 0.035, 0), "leaf", (-18, angle, 0))
    save("assets/3d/environment/foliage/ferns.glb", m)

    m = Model("bushes")
    for x in [-0.85, 0.0, 0.8]:
        for k in range(5):
            m.add_sphere("leaf_blob", 0.34, (x + math.sin(k * 2.1) * 0.25, 0.30 + 0.08 * (k % 2), math.cos(k * 2.1) * 0.18), "leaf" if k % 2 else "grass", scale=(1.1, 0.75, 1.0))
    save("assets/3d/environment/foliage/bushes.glb", m)

    m = Model("vines")
    for x in [-0.8, -0.35, 0.2, 0.65]:
        m.add_cylinder("hanging_vine", 0.035, 1.65 + 0.2 * math.sin(x * 5), (x, 1.0, 0), "grass_dark", (0, 0, 6 * x), segments=6)
        m.add_box("vine_leaf", (0.22, 0.06, 0.12), (x + 0.08, 0.45, 0.03), "leaf", (0, 25, 20))
    save("assets/3d/environment/foliage/vines.glb", m)

    m = Model("palms")
    add_tree(m, -0.8, 0.0, 3.2, jungle=False)
    add_tree(m, 1.0, 0.2, 4.1, jungle=False)
    save("assets/3d/environment/trees/palms.glb", m)

    m = Model("jungle_trees")
    add_tree(m, -0.9, 0.0, 2.4, jungle=True)
    add_tree(m, 0.9, -0.2, 3.1, jungle=True)
    save("assets/3d/environment/trees/jungle_trees.glb", m)

    m = Model("tree_cluster_bg")
    for i, x in enumerate([-2.2, -1.2, -0.2, 0.8, 1.9, 2.8]):
        add_tree(m, x, 0.25 * math.sin(i), 2.0 + (i % 3) * 0.45, jungle=i % 2 == 0)
    save("assets/3d/environment/trees/tree_cluster_bg.glb", m)

    m = Model("rock_clusters")
    for i, x in enumerate([-0.8, -0.25, 0.45, 0.95]):
        m.add_sphere("rock", 0.35 + 0.06 * (i % 2), (x, 0.22, 0.16 * math.sin(i)), "rock" if i % 2 else "rock_dark", scale=(1.25, 0.65, 0.9), segments=8, rings=4)
    save("assets/3d/environment/rocks/rock_clusters.glb", m)

    m = Model("fallen_log")
    m.add_cylinder("log", 0.28, 5.1, (0, 0.36, 0), "log", (0, 0, 90), segments=10)
    for sx in [-2.55, 2.55]:
        m.add_cylinder("cut_face", 0.29, 0.08, (sx, 0.36, 0), "dirt_light", (0, 0, 90), segments=10)
    save("assets/3d/obstacles/fallen_log.glb", m)

    m = Model("rock_obstacle")
    m.add_sphere("main_rock", 0.58, (0, 0.45, 0), "rock", scale=(1.0, 0.72, 0.92), segments=8, rings=4)
    m.add_sphere("side_rock", 0.34, (0.34, 0.30, 0.24), "rock_dark", scale=(1.1, 0.65, 0.8), segments=8, rings=4)
    m.add_box("moss_top", (0.58, 0.055, 0.30), (-0.08, 0.82, -0.10), "moss", (0, 15, 0))
    save("assets/3d/obstacles/rock_obstacle.glb", m)

    m = Model("spike_trap")
    m.add_box("base", (1.2, 0.12, 0.9), (0, 0.06, 0), "stone_dark")
    for x in [-0.36, 0, 0.36]:
        m.add_cylinder("stake", 0.15, 0.72, (x, 0.45, 0), "danger", (-7 + x * 20, 0, 0), segments=6, top_radius=0.0, bottom_radius=0.16)
    save("assets/3d/obstacles/spike_trap.glb", m)

    m = Model("mud_patch")
    m.add_box("mud", (5.4, 0.045, 2.4), (0, 0.02, 0), "mud")
    for x in [-1.2, 0.2, 1.4]:
        m.add_sphere("mud_ripple", 0.26, (x, 0.055, 0.35 * math.sin(x)), (0.36, 0.25, 0.13, 1.0), scale=(1.8, 0.10, 0.75), segments=8, rings=3)
    save("assets/3d/obstacles/mud_patch.glb", m)

    m = Model("river_gap_kit")
    m.add_box("water_strip", (5.8, 0.05, 3.0), (0, -0.03, 0), "water")
    for sx in [-2.7, 2.7]:
        m.add_box("bank", (0.7, 0.20, 3.0), (sx, 0.05, 0), "dirt_light")
        add_grass_blades(m, (sx, 0.18, 0), 8, 0.8)
    save("assets/3d/obstacles/river_gap/river_gap_kit.glb", m)

    m = Model("wood_bridge")
    for z in [-0.9, -0.3, 0.3, 0.9]:
        m.add_box("plank", (4.8, 0.16, 0.36), (0, 0.10, z), "log", (0, 0, 0))
    for x in [-2.05, 2.05]:
        m.add_box("rail", (0.16, 0.18, 2.5), (x, 0.28, 0), "trunk")
    save("assets/3d/environment/bridges/wood_bridge.glb", m)

    m = Model("broken_bridge")
    for i, z in enumerate([-0.95, -0.35, 0.55]):
        m.add_box("broken_plank", (1.9 if i == 1 else 4.2, 0.16, 0.34), (-0.55 if i == 1 else 0, 0.10, z), "log", (0, 0, 8 if i == 1 else 0))
    m.add_box("gap_marker", (1.4, 0.05, 0.7), (1.15, 0.02, 0.05), "water")
    save("assets/3d/environment/bridges/broken_bridge.glb", m)

    m = Model("rolling_boulder")
    m.add_sphere("boulder", 0.85, (0, 0.85, 0), "rock_dark", scale=(1.08, 0.95, 1.0), segments=10, rings=5)
    for angle in [0, 60, 120]:
        m.add_box("crack", (0.04, 0.05, 0.9), (0, 1.05, 0.02), "rock", (0, angle, 25))
    save("assets/3d/obstacles/rolling_boulder.glb", m)

    m = Model("slide_barrier")
    m.add_cylinder("low_branch", 0.13, 5.2, (0, 1.32, 0), "log", (0, 0, 90), segments=8)
    for x in [-1.5, 1.5]:
        m.add_cylinder("vine", 0.035, 0.85, (x, 0.88, 0), "grass_dark", segments=6)
    save("assets/3d/obstacles/slide_barrier.glb", m)

    m = Model("pressure_plate")
    m.add_box("plate", (1.4, 0.14, 1.0), (0, 0.07, 0), "stone")
    m.add_box("inset", (0.95, 0.035, 0.62), (0, 0.16, 0), "stone_dark")
    m.add_octahedron("glyph", (0.18, 0.05, 0.18), (0, 0.21, 0), "gold")
    save("assets/3d/obstacles/pressure_plate.glb", m)

    m = Model("sand_dune")
    m.add_sphere("dune", 0.95, (0, 0.22, 0), "sand", scale=(1.8, 0.34, 0.85), segments=10, rings=4)
    m.add_box("wind_line", (1.8, 0.025, 0.05), (0.1, 0.48, -0.15), "dirt_light", (0, 12, 0))
    save("assets/3d/obstacles/sand_dune.glb", m)

    for rel, name, glow in [
        ("assets/3d/goals/jungle_gate.glb", "jungle_gate", False),
        ("assets/3d/goals/vine_ruin_arch.glb", "vine_ruin_arch", False),
        ("assets/3d/goals/river_gate.glb", "river_gate", True),
        ("assets/3d/goals/temple_doorway.glb", "temple_doorway", False),
        ("assets/3d/goals/temple_portal.glb", "temple_portal", True),
        ("assets/3d/goals/wildlands_altar.glb", "wildlands_altar", False),
    ]:
        m = Model(name)
        add_gate(m, name, "stone", glow)
        if "vine" in name:
            for x in [-1.7, 1.7]:
                m.add_cylinder("vine_wrap", 0.035, 2.2, (x, 1.55, 0.05), "grass_dark", (0, 0, 8), segments=6)
        if "wildlands" in name:
            m.add_box("sun_disc", (1.25, 0.12, 1.25), (0, 1.2, -0.08), "sun", (0, 0, 45))
        save(rel, m)

    m = Model("treasure_chest")
    m.add_box("chest_base", (1.25, 0.58, 0.72), (0, 0.36, 0), "log")
    m.add_cylinder("lid", 0.36, 1.25, (0, 0.70, 0), "trunk", (0, 0, 90), segments=10)
    m.add_box("gold_band", (1.32, 0.08, 0.08), (0, 0.68, 0.36), "gold")
    m.add_box("lock", (0.22, 0.22, 0.06), (0, 0.42, 0.39), "gold")
    save("assets/3d/rewards/treasure_chest.glb", m)

    m = Model("relic_altar")
    m.add_box("base", (1.5, 0.32, 1.5), (0, 0.16, 0), "stone_dark")
    m.add_box("top", (1.05, 0.28, 1.05), (0, 0.46, 0), "stone")
    m.add_octahedron("sunstone", (0.32, 0.48, 0.32), (0, 1.08, 0), "sun")
    save("assets/3d/rewards/relic_altar.glb", m)

    collectible_specs = [
        ("coin", "assets/3d/collectibles/coin.glb"),
        ("gem", "assets/3d/collectibles/gem.glb"),
        ("brick", "assets/3d/collectibles/brick.glb"),
        ("wood", "assets/3d/collectibles/wood.glb"),
        ("tile", "assets/3d/collectibles/tile.glb"),
        ("food", "assets/3d/collectibles/food.glb"),
        ("tools", "assets/3d/collectibles/tools.glb"),
        ("relic_key", "assets/3d/collectibles/relic_key.glb"),
        ("sunstone_shard", "assets/3d/collectibles/sunstone_shard.glb"),
    ]
    for name, rel in collectible_specs:
        m = Model(name)
        if name == "coin":
            m.add_cylinder("coin", 0.32, 0.10, (0, 0.35, 0), "gold", (90, 0, 0), segments=16)
            m.add_cylinder("coin_inset", 0.18, 0.11, (0, 0.35, 0.01), "dirt_light", (90, 0, 0), segments=16)
        elif name == "gem":
            m.add_octahedron("gem", (0.32, 0.46, 0.32), (0, 0.55, 0), "gem")
        elif name == "brick":
            m.add_box("brick", (0.68, 0.32, 0.36), (0, 0.25, 0), (0.64, 0.22, 0.14, 1.0))
        elif name == "wood":
            m.add_cylinder("wood_bundle", 0.12, 0.86, (0, 0.26, 0), "log", (0, 0, 90), segments=8)
            m.add_cylinder("wood_bundle", 0.12, 0.86, (0, 0.46, 0.12), "trunk", (0, 0, 90), segments=8)
        elif name == "tile":
            m.add_box("tile", (0.72, 0.08, 0.72), (0, 0.14, 0), "stone")
            m.add_box("mark", (0.52, 0.02, 0.08), (0, 0.19, 0), "moss")
        elif name == "food":
            m.add_sphere("fruit", 0.28, (0, 0.36, 0), (0.90, 0.18, 0.08, 1.0), scale=(0.9, 1.05, 0.9))
            m.add_box("leaf", (0.20, 0.045, 0.10), (0.14, 0.66, 0), "leaf", (0, 0, 25))
        elif name == "tools":
            m.add_cylinder("handle", 0.045, 0.85, (0, 0.38, 0), "log", (0, 0, 38), segments=6)
            m.add_box("head", (0.42, 0.12, 0.16), (0.28, 0.62, 0), "stone_dark", (0, 0, 38))
        elif name == "relic_key":
            m.add_cylinder("ring", 0.18, 0.045, (-0.24, 0.5, 0), "gold", (90, 0, 0), segments=12)
            m.add_box("shaft", (0.58, 0.08, 0.08), (0.18, 0.5, 0), "gold")
            m.add_box("tooth", (0.08, 0.20, 0.08), (0.43, 0.40, 0), "gold")
        elif name == "sunstone_shard":
            m.add_octahedron("shard", (0.26, 0.55, 0.20), (0, 0.55, 0), "sun", (0, 0, 18))
        save(rel, m)

    wildlife = [
        ("elephant", "assets/3d/wildlife/elephant.glb"),
        ("lion", "assets/3d/wildlife/lion.glb"),
        ("leopard", "assets/3d/wildlife/leopard.glb"),
        ("cape_buffalo", "assets/3d/wildlife/cape_buffalo.glb"),
        ("rhino", "assets/3d/wildlife/rhino.glb"),
        ("warthog", "assets/3d/wildlife/warthog.glb"),
        ("bird", "assets/3d/wildlife/bird.glb"),
        ("butterfly", "assets/3d/wildlife/butterfly.glb"),
        ("monkey", "assets/3d/wildlife/monkey.glb"),
        ("frog", "assets/3d/wildlife/frog.glb"),
        ("snake", "assets/3d/wildlife/snake.glb"),
        ("weaver_bird", "assets/3d/wildlife/weaver_bird.glb"),
        ("crocodile", "assets/3d/wildlife/crocodile.glb"),
        ("zebra", "assets/3d/wildlife/zebra.glb"),
        ("giraffe", "assets/3d/wildlife/giraffe.glb"),
    ]
    for name, rel in wildlife:
        m = Model(name)
        if name == "elephant":
            add_quadruped(m, "rock", "rock_dark", scale=(1.4, 1.25, 1.2))
            m.add_cylinder("trunk", 0.09, 0.95, (1.15, 0.68, 0), "rock", (0, 0, -18), segments=8, top_radius=0.045, bottom_radius=0.10)
            for z in [-0.36, 0.36]:
                m.add_sphere("ear", 0.38, (0.76, 1.35, z), "rock", scale=(0.18, 1.0, 0.75), segments=8, rings=4)
        elif name == "lion":
            add_quadruped(m, "lion", "hide_dark", scale=(1.0, 1.0, 1.0), mane=True)
        elif name == "leopard":
            add_quadruped(m, "leopard", "hide_dark", scale=(0.95, 0.82, 0.85), spots=True)
        elif name == "cape_buffalo":
            add_quadruped(m, "hide_dark", "black", scale=(1.25, 0.95, 1.1), horns=True)
        elif name == "rhino":
            add_quadruped(m, "rock", "rock_dark", scale=(1.25, 1.0, 1.0), horns=True)
            m.add_cylinder("nose_horn", 0.07, 0.48, (1.10, 1.16, 0), "white", (0, 0, 78), segments=6, top_radius=0.0, bottom_radius=0.09)
        elif name == "warthog":
            add_quadruped(m, "hide", "hide_dark", scale=(0.78, 0.68, 0.8), horns=True)
        elif name in ("bird", "weaver_bird"):
            color = "bird_blue" if name == "bird" else "bird_red"
            for i in range(1 if name == "bird" else 3):
                x = (i - 1) * 0.75
                m.add_sphere("body", 0.22, (x, 0.55 + i * 0.1, 0), color, scale=(0.9, 0.7, 1.2), segments=8, rings=4)
                m.add_box("wing_l", (0.52, 0.04, 0.18), (x - 0.30, 0.55, 0), "bird_blue", (0, 0, 12))
                m.add_box("wing_r", (0.52, 0.04, 0.18), (x + 0.30, 0.55, 0), "bird_blue", (0, 0, -12))
                m.add_box("beak", (0.10, 0.08, 0.20), (x, 0.57, -0.24), "sun")
        elif name == "butterfly":
            m.add_cylinder("body", 0.035, 0.36, (0, 0.42, 0), "black", segments=6)
            for side in [-1, 1]:
                m.add_box("wing", (0.38, 0.04, 0.28), (side * 0.19, 0.48, 0), "sun" if side < 0 else "gem", (0, 0, side * 22))
        elif name == "monkey":
            m.add_sphere("body", 0.32, (0, 0.68, 0), "hide", scale=(0.85, 1.2, 0.8), segments=8, rings=4)
            m.add_sphere("head", 0.22, (0.18, 1.05, 0), "hide_dark", segments=8, rings=4)
            for side in [-1, 1]:
                m.add_cylinder("arm", 0.045, 0.72, (side * 0.28, 0.65, 0), "hide_dark", (0, 0, side * 30), segments=6)
            m.add_cylinder("tail", 0.04, 0.95, (-0.42, 0.72, 0), "hide_dark", (0, 0, 62), segments=6)
        elif name == "frog":
            m.add_sphere("body", 0.34, (0, 0.28, 0), "frog", scale=(1.25, 0.55, 0.9), segments=8, rings=4)
            for x in [-0.18, 0.18]:
                m.add_sphere("eye", 0.08, (x, 0.55, -0.20), "white", segments=6, rings=3)
                m.add_sphere("pupil", 0.035, (x, 0.56, -0.25), "black", segments=6, rings=3)
            for x in [-0.38, 0.38]:
                m.add_box("leg", (0.36, 0.08, 0.12), (x, 0.15, 0.10), "frog", (0, 0, 22 if x > 0 else -22))
        elif name == "snake":
            for i in range(8):
                m.add_sphere("segment", 0.16, (-0.7 + i * 0.2, 0.18, math.sin(i * 0.9) * 0.18), "croc", scale=(1.25, 0.55, 0.8), segments=8, rings=3)
            m.add_sphere("head", 0.20, (0.95, 0.22, 0.10), "croc", scale=(1.2, 0.75, 0.9), segments=8, rings=3)
        elif name == "crocodile":
            m.add_sphere("body", 0.42, (0, 0.34, 0), "croc", scale=(2.2, 0.45, 0.75), segments=10, rings=4)
            m.add_sphere("head", 0.30, (1.05, 0.33, 0), "croc", scale=(1.35, 0.45, 0.7), segments=8, rings=4)
            m.add_cylinder("tail", 0.16, 1.15, (-1.10, 0.32, 0), "croc", (0, 0, 84), segments=8, top_radius=0.02, bottom_radius=0.16)
            for x in [-0.4, 0.4]:
                for z in [-0.32, 0.32]:
                    m.add_box("leg", (0.28, 0.08, 0.12), (x, 0.15, z), "croc")
        elif name == "zebra":
            add_quadruped(m, "white", "black", scale=(1.0, 0.95, 0.9), stripes=True)
        elif name == "giraffe":
            add_quadruped(m, "sand", "hide_dark", scale=(1.0, 1.35, 0.9), long_neck=True, spots=True)
            for z in [-0.10, 0.10]:
                m.add_cylinder("ossicone", 0.025, 0.22, (0.80, 2.58, z), "hide_dark", segments=6)
        save(rel, m)

    m = Model("sand_shoes")
    for x in [-0.28, 0.28]:
        m.add_box("shoe", (0.36, 0.18, 0.78), (x, 0.12, 0), "sand")
        m.add_box("sole", (0.40, 0.05, 0.82), (x, 0.02, 0), "hide_dark")
        m.add_box("strap", (0.42, 0.06, 0.12), (x, 0.22, -0.12), "log")
    save("assets/3d/upgrades/sand_shoes.glb", m)

    return assets


def write_text_assets():
    material_dir = ROOT / "assets/3d/materials"
    vfx_dir = ROOT / "assets/3d/vfx"
    material_dir.mkdir(parents=True, exist_ok=True)
    vfx_dir.mkdir(parents=True, exist_ok=True)
    (material_dir / "mossy_stone.tres").write_text(
        '[gd_resource type="StandardMaterial3D" format=3]\n\n'
        '[resource]\n'
        'resource_name = "Mossy Stone"\n'
        'albedo_color = Color(0.42, 0.43, 0.36, 1)\n'
        'roughness = 0.9\n'
        'metallic = 0.0\n',
        encoding="utf-8",
    )
    (material_dir / "water_stylized.tres").write_text(
        '[gd_resource type="StandardMaterial3D" format=3]\n\n'
        '[resource]\n'
        'resource_name = "Stylized Water"\n'
        'albedo_color = Color(0.12, 0.5, 0.76, 0.78)\n'
        'transparency = 1\n'
        'roughness = 0.35\n',
        encoding="utf-8",
    )
    (vfx_dir / "foliage_sway.gdshader").write_text(
        'shader_type spatial;\n'
        'render_mode world_vertex_coords;\n\n'
        'uniform float sway_strength = 0.045;\n'
        'uniform float sway_speed = 1.6;\n\n'
        'void vertex() {\n'
        '    float wave = sin(TIME * sway_speed + VERTEX.x * 2.1 + VERTEX.z * 1.7);\n'
        '    VERTEX.x += wave * sway_strength * clamp(VERTEX.y, 0.0, 1.0);\n'
        '}\n',
        encoding="utf-8",
    )
    particle_scenes = {
        "torch_flame.tscn": ("TorchFlame", "Color(1, 0.46, 0.08, 1)", 0.75, 24),
        "finish_glow.tscn": ("FinishGlow", "Color(0.2, 0.9, 0.62, 1)", 1.35, 36),
        "pickup_sparkle.tscn": ("PickupSparkle", "Color(1, 0.82, 0.12, 1)", 0.45, 18),
        "dust_puff.tscn": ("DustPuff", "Color(0.65, 0.52, 0.34, 1)", 0.55, 18),
        "hit_burst.tscn": ("HitBurst", "Color(0.85, 0.18, 0.12, 1)", 0.40, 24),
        "sand_trail.tscn": ("SandTrail", "Color(0.78, 0.62, 0.38, 1)", 0.70, 20),
    }
    for filename, (node_name, color, lifetime, amount) in particle_scenes.items():
        (vfx_dir / filename).write_text(
            '[gd_scene load_steps=2 format=3]\n\n'
            '[sub_resource type="ParticleProcessMaterial" id="ParticleProcessMaterial_1"]\n'
            'direction = Vector3(0, 1, 0)\n'
            'spread = 35.0\n'
            'initial_velocity_min = 0.35\n'
            'initial_velocity_max = 1.2\n'
            'gravity = Vector3(0, -0.4, 0)\n'
            f'color = {color}\n\n'
            f'[node name="{node_name}" type="GPUParticles3D"]\n'
            f'amount = {amount}\n'
            f'lifetime = {lifetime}\n'
            'one_shot = true\n'
            'explosiveness = 0.72\n'
            'process_material = SubResource("ParticleProcessMaterial_1")\n',
            encoding="utf-8",
        )


def main():
    assets = build_assets()
    write_text_assets()
    print("Generated %d GLB assets" % len(assets))
    for asset in assets:
        print(asset.relative_to(ROOT).as_posix())


if __name__ == "__main__":
    main()
