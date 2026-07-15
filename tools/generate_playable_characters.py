from __future__ import annotations

import json
import math
import struct
from dataclasses import dataclass
from pathlib import Path

from generate_missing_3d_assets import Model


ROOT = Path(__file__).resolve().parents[1]


def _quat(euler_degrees: tuple[float, float, float]) -> tuple[float, float, float, float]:
    rx, ry, rz = (math.radians(value) * 0.5 for value in euler_degrees)
    sx, cx = math.sin(rx), math.cos(rx)
    sy, cy = math.sin(ry), math.cos(ry)
    sz, cz = math.sin(rz), math.cos(rz)
    return (
        sx * cy * cz - cx * sy * sz,
        cx * sy * cz + sx * cy * sz,
        cx * cy * sz - sx * sy * cz,
        cx * cy * cz + sx * sy * sz,
    )


def _add_euler(
    base: tuple[float, float, float], delta: tuple[float, float, float]
) -> tuple[float, float, float]:
    return tuple(base[index] + delta[index] for index in range(3))


@dataclass
class Part:
    name: str
    parent: str
    translation: tuple[float, float, float]
    rotation: tuple[float, float, float]
    primitive: dict | None = None
    material: int | None = None


class Character:
    def __init__(self, name: str):
        self.name = name
        self.parts: list[Part] = [Part("CharacterRig", "", (0.0, 0.0, 0.0), (0.0, 0.0, 0.0))]
        self.materials: list[dict] = []
        self._material_lookup: dict[tuple, int] = {}

    def material(
        self,
        name: str,
        color: tuple[float, float, float, float],
        metallic: float = 0.0,
        roughness: float = 0.82,
        emissive: tuple[float, float, float] | None = None,
    ) -> int:
        key = (name, color, metallic, roughness, emissive)
        if key in self._material_lookup:
            return self._material_lookup[key]
        entry = {
            "name": name,
            "pbrMetallicRoughness": {
                "baseColorFactor": list(color),
                "metallicFactor": metallic,
                "roughnessFactor": roughness,
            },
            "alphaMode": "BLEND" if color[3] < 1.0 else "OPAQUE",
        }
        if emissive is not None:
            entry["emissiveFactor"] = list(emissive)
        index = len(self.materials)
        self.materials.append(entry)
        self._material_lookup[key] = index
        return index

    def add_joint(
        self,
        name: str,
        parent: str = "CharacterRig",
        pos: tuple[float, float, float] = (0.0, 0.0, 0.0),
        rot: tuple[float, float, float] = (0.0, 0.0, 0.0),
    ) -> str:
        self.parts.append(Part(name, parent, pos, rot))
        return name

    def add_shape(
        self,
        name: str,
        kind: str,
        material: int,
        parent: str = "CharacterRig",
        pos: tuple[float, float, float] = (0.0, 0.0, 0.0),
        rot: tuple[float, float, float] = (0.0, 0.0, 0.0),
        size: tuple[float, float, float] = (0.5, 0.5, 0.5),
    ) -> str:
        source = Model(name)
        if kind == "box":
            source.add_box(name, size, color=(1.0, 1.0, 1.0, 1.0))
        elif kind == "sphere":
            source.add_sphere(
                name,
                radius=0.5,
                color=(1.0, 1.0, 1.0, 1.0),
                scale=size,
                segments=10,
                rings=5,
            )
        elif kind == "cylinder":
            source.add_cylinder(
                name,
                radius=size[0],
                height=size[1],
                color=(1.0, 1.0, 1.0, 1.0),
                segments=max(6, int(size[2])),
            )
        elif kind == "cone":
            source.add_cylinder(
                name,
                radius=size[0],
                height=size[1],
                color=(1.0, 1.0, 1.0, 1.0),
                segments=max(6, int(size[2])),
                top_radius=0.0,
                bottom_radius=size[0],
            )
        elif kind == "octahedron":
            source.add_octahedron(
                name,
                size=size,
                color=(1.0, 1.0, 1.0, 1.0),
            )
        else:
            raise ValueError(f"Unsupported shape: {kind}")
        self.parts.append(Part(name, parent, pos, rot, source.primitives[0], material))
        return name

    def part(self, name: str) -> Part:
        return next(part for part in self.parts if part.name == name)


def _pack_floats(blob: bytearray, rows: list[tuple[float, ...]]) -> tuple[int, int]:
    while len(blob) % 4:
        blob.extend(b"\x00")
    offset = len(blob)
    flat = [component for row in rows for component in row]
    blob.extend(struct.pack("<" + "f" * len(flat), *flat))
    return offset, len(flat) * 4


def _pack_indices(blob: bytearray, values: list[int]) -> tuple[int, int, int]:
    while len(blob) % 4:
        blob.extend(b"\x00")
    offset = len(blob)
    component_type = 5123 if max(values, default=0) < 65535 else 5125
    fmt = "H" if component_type == 5123 else "I"
    blob.extend(struct.pack("<" + fmt * len(values), *values))
    return offset, len(values) * (2 if component_type == 5123 else 4), component_type


def _animation_specs(character: Character) -> list[dict]:
    def rotations(
        node: str,
        times: list[float],
        deltas: list[tuple[float, float, float]],
    ) -> dict:
        base = character.part(node).rotation
        return {
            "node": node,
            "path": "rotation",
            "times": times,
            "values": [_quat(_add_euler(base, delta)) for delta in deltas],
        }

    def translations(
        node: str,
        times: list[float],
        deltas: list[tuple[float, float, float]],
    ) -> dict:
        base = character.part(node).translation
        return {
            "node": node,
            "path": "translation",
            "times": times,
            "values": [
                tuple(base[index] + delta[index] for index in range(3))
                for delta in deltas
            ],
        }

    clips: list[dict] = []
    idle_times = [0.0, 0.75, 1.5]
    clips.append(
        {
            "name": "CharacterArmature|Idle",
            "channels": [
                translations("CharacterRig", idle_times, [(0, 0, 0), (0, 0.035, 0), (0, 0, 0)]),
                rotations("Head", idle_times, [(0, -3, 0), (0, 3, 0), (0, -3, 0)]),
            ],
        }
    )

    run_times = [0.0, 0.24, 0.48]
    run_channels = [
        translations("CharacterRig", run_times, [(0, 0, 0), (0, 0.07, 0), (0, 0, 0)]),
        rotations("Arm_L", run_times, [(-36, 0, 0), (36, 0, 0), (-36, 0, 0)]),
        rotations("Arm_R", run_times, [(36, 0, 0), (-36, 0, 0), (36, 0, 0)]),
        rotations("Leg_L", run_times, [(32, 0, 0), (-32, 0, 0), (32, 0, 0)]),
        rotations("Leg_R", run_times, [(-32, 0, 0), (32, 0, 0), (-32, 0, 0)]),
    ]
    if any(part.name == "Tail" for part in character.parts):
        run_channels.append(rotations("Tail", run_times, [(0, -18, -12), (0, 18, 12), (0, -18, -12)]))
    clips.append({"name": "CharacterArmature|Run", "channels": run_channels})

    for name, lean in [("CharacterArmature|Run_Left", 10.0), ("CharacterArmature|Run_Right", -10.0)]:
        channels = list(run_channels)
        channels.append(rotations("CharacterRig", run_times, [(0, 0, 0), (0, 0, lean), (0, 0, 0)]))
        clips.append({"name": name, "channels": channels})

    roll_times = [0.0, 0.18, 0.36, 0.54, 0.70]
    clips.append(
        {
            "name": "CharacterArmature|Roll",
            "channels": [
                translations("CharacterRig", roll_times, [(0, 0, 0), (0, -0.38, 0), (0, -0.55, 0), (0, -0.38, 0), (0, 0, 0)]),
                rotations("CharacterRig", roll_times, [(0, 0, 0), (-70, 0, 0), (-155, 0, 0), (-245, 0, 0), (-359, 0, 0)]),
            ],
        }
    )
    clips.append(
        {
            "name": "CharacterArmature|Interact",
            "channels": [
                rotations("Arm_L", [0.0, 0.25, 0.55], [(0, 0, 0), (-72, 0, -24), (0, 0, 0)]),
                rotations("Arm_R", [0.0, 0.25, 0.55], [(0, 0, 0), (-72, 0, 24), (0, 0, 0)]),
            ],
        }
    )
    clips.append(
        {
            "name": "CharacterArmature|HitRecieve",
            "channels": [
                rotations("CharacterRig", [0.0, 0.16, 0.42], [(0, 0, 0), (-20, 0, 8), (0, 0, 0)]),
                translations("CharacterRig", [0.0, 0.16, 0.42], [(0, 0, 0), (0, 0.05, 0.18), (0, 0, 0)]),
            ],
        }
    )
    clips.append(
        {
            "name": "CharacterArmature|Wave",
            "channels": [
                rotations("Arm_R", [0.0, 0.3, 0.55, 0.8, 1.05], [(0, 0, 0), (0, 0, 145), (0, -28, 145), (0, 28, 145), (0, 0, 0)]),
                translations("CharacterRig", [0.0, 0.5, 1.05], [(0, 0, 0), (0, 0.04, 0), (0, 0, 0)]),
            ],
        }
    )
    clips.append(
        {
            "name": "CharacterArmature|Death",
            "channels": [
                rotations("CharacterRig", [0.0, 0.45, 0.9], [(0, 0, 0), (0, 0, 42), (0, 0, 88)]),
                translations("CharacterRig", [0.0, 0.45, 0.9], [(0, 0, 0), (0, -0.25, 0), (0, -0.75, 0)]),
            ],
        }
    )
    return clips


def write_character_glb(path: Path, character: Character) -> None:
    blob = bytearray()
    buffer_views: list[dict] = []
    accessors: list[dict] = []
    meshes: list[dict] = []
    name_to_index = {part.name: index for index, part in enumerate(character.parts)}

    def add_float_accessor(rows: list[tuple[float, ...]], gltf_type: str, target: int | None = None) -> int:
        offset, length = _pack_floats(blob, rows)
        view = {"buffer": 0, "byteOffset": offset, "byteLength": length}
        if target is not None:
            view["target"] = target
        buffer_views.append(view)
        dimensions = len(rows[0])
        accessor = {
            "bufferView": len(buffer_views) - 1,
            "componentType": 5126,
            "count": len(rows),
            "type": gltf_type,
        }
        if gltf_type in ("SCALAR", "VEC3"):
            accessor["min"] = [min(row[index] for row in rows) for index in range(dimensions)]
            accessor["max"] = [max(row[index] for row in rows) for index in range(dimensions)]
        accessors.append(accessor)
        return len(accessors) - 1

    nodes: list[dict] = []
    for part in character.parts:
        node = {"name": part.name}
        if part.translation != (0.0, 0.0, 0.0):
            node["translation"] = list(part.translation)
        if part.rotation != (0.0, 0.0, 0.0):
            node["rotation"] = list(_quat(part.rotation))
        nodes.append(node)

        if part.primitive is None:
            continue
        primitive = part.primitive
        position_accessor = add_float_accessor(primitive["vertices"], "VEC3", 34962)
        normal_accessor = add_float_accessor(primitive["normals"], "VEC3", 34962)
        offset, length, component_type = _pack_indices(blob, primitive["indices"])
        buffer_views.append({"buffer": 0, "byteOffset": offset, "byteLength": length, "target": 34963})
        accessors.append(
            {
                "bufferView": len(buffer_views) - 1,
                "componentType": component_type,
                "count": len(primitive["indices"]),
                "type": "SCALAR",
            }
        )
        meshes.append(
            {
                "name": part.name + "_mesh",
                "primitives": [
                    {
                        "attributes": {"POSITION": position_accessor, "NORMAL": normal_accessor},
                        "indices": len(accessors) - 1,
                        "material": part.material,
                    }
                ],
            }
        )
        node["mesh"] = len(meshes) - 1

    for index, part in enumerate(character.parts):
        children = [child_index for child_index, child in enumerate(character.parts) if child.parent == part.name]
        if children:
            nodes[index]["children"] = children

    animations: list[dict] = []
    for clip in _animation_specs(character):
        samplers: list[dict] = []
        channels: list[dict] = []
        for track in clip["channels"]:
            time_rows = [(float(value),) for value in track["times"]]
            value_rows = [tuple(float(value) for value in row) for row in track["values"]]
            input_accessor = add_float_accessor(time_rows, "SCALAR")
            output_accessor = add_float_accessor(value_rows, "VEC4" if track["path"] == "rotation" else "VEC3")
            samplers.append({"input": input_accessor, "output": output_accessor, "interpolation": "LINEAR"})
            channels.append(
                {
                    "sampler": len(samplers) - 1,
                    "target": {"node": name_to_index[track["node"]], "path": track["path"]},
                }
            )
        animations.append({"name": clip["name"], "samplers": samplers, "channels": channels})

    while len(blob) % 4:
        blob.extend(b"\x00")
    gltf = {
        "asset": {"version": "2.0", "generator": "Jungle Escape animated character pipeline"},
        "scene": 0,
        "scenes": [{"nodes": [0]}],
        "nodes": nodes,
        "meshes": meshes,
        "materials": character.materials,
        "animations": animations,
        "buffers": [{"byteLength": len(blob)}],
        "bufferViews": buffer_views,
        "accessors": accessors,
    }
    json_bytes = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    while len(json_bytes) % 4:
        json_bytes += b" "
    total_length = 12 + 8 + len(json_bytes) + 8 + len(blob)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as handle:
        handle.write(struct.pack("<4sII", b"glTF", 2, total_length))
        handle.write(struct.pack("<I4s", len(json_bytes), b"JSON"))
        handle.write(json_bytes)
        handle.write(struct.pack("<I4s", len(blob), b"BIN\x00"))
        handle.write(blob)


def _add_face(character: Character, head: str, eye_material: int, muzzle_material: int | None = None) -> None:
    if muzzle_material is not None:
        character.add_shape("Muzzle", "sphere", muzzle_material, head, (0.0, -0.03, -0.24), size=(0.35, 0.24, 0.22))
    for side, x in [("L", -0.09), ("R", 0.09)]:
        character.add_shape(f"Eye_{side}", "sphere", eye_material, head, (x, 0.06, -0.255), size=(0.055, 0.07, 0.035))


def _add_humanoid_rig(
    character: Character,
    body_material: int,
    skin_material: int,
    leg_material: int,
    boot_material: int,
    torso_scale: tuple[float, float, float] = (0.70, 0.88, 0.42),
) -> None:
    character.add_shape("Torso", "sphere", body_material, pos=(0.0, 1.28, 0.0), size=torso_scale)
    character.add_shape("Belt", "cylinder", boot_material, pos=(0.0, 0.98, 0.0), size=(0.34, 0.11, 10))
    character.add_joint("Head", pos=(0.0, 1.86, 0.0))
    character.add_shape("HeadMesh", "sphere", skin_material, "Head", size=(0.52, 0.58, 0.50))
    for side, x in [("L", -0.38), ("R", 0.38)]:
        arm = character.add_joint(f"Arm_{side}", pos=(x, 1.48, 0.0), rot=(0.0, 0.0, -5.0 if side == "L" else 5.0))
        character.add_shape(f"ArmMesh_{side}", "cylinder", body_material, arm, (0.0, -0.30, 0.0), size=(0.105, 0.62, 8))
        character.add_shape(f"Hand_{side}", "sphere", skin_material, arm, (0.0, -0.64, -0.01), size=(0.18, 0.20, 0.17))
    for side, x in [("L", -0.18), ("R", 0.18)]:
        leg = character.add_joint(f"Leg_{side}", pos=(x, 0.92, 0.0))
        character.add_shape(f"LegMesh_{side}", "cylinder", leg_material, leg, (0.0, -0.37, 0.0), size=(0.13, 0.76, 8))
        character.add_shape(f"Boot_{side}", "box", boot_material, leg, (0.0, -0.78, -0.08), size=(0.26, 0.22, 0.42))


def build_monkey() -> Character:
    c = Character("MonkeyExplorer")
    fur = c.material("warm_brown_fur", (0.36, 0.16, 0.055, 1.0), roughness=0.96)
    light_fur = c.material("tan_face", (0.76, 0.43, 0.18, 1.0), roughness=0.92)
    vest = c.material("scout_vest", (0.16, 0.38, 0.12, 1.0))
    leather = c.material("dark_leather", (0.12, 0.055, 0.025, 1.0))
    eye = c.material("eyes", (0.025, 0.018, 0.012, 1.0), roughness=0.3)
    gold = c.material("buckles", (0.95, 0.62, 0.08, 1.0), metallic=0.45, roughness=0.35)
    c.add_shape("Torso", "sphere", fur, pos=(0.0, 1.10, 0.0), size=(0.68, 0.82, 0.50))
    c.add_shape("Vest", "sphere", vest, pos=(0.0, 1.13, -0.025), size=(0.73, 0.68, 0.53))
    c.add_shape("VestBuckle", "box", gold, pos=(0.0, 1.06, -0.30), size=(0.12, 0.15, 0.05))
    c.add_joint("Head", pos=(0.0, 1.68, -0.02))
    c.add_shape("HeadMesh", "sphere", fur, "Head", size=(0.58, 0.55, 0.52))
    for side, x in [("L", -0.29), ("R", 0.29)]:
        c.add_shape(f"Ear_{side}", "sphere", light_fur, "Head", (x, 0.02, 0.0), size=(0.22, 0.28, 0.15))
    _add_face(c, "Head", eye, light_fur)
    for side, x in [("L", -0.36), ("R", 0.36)]:
        arm = c.add_joint(f"Arm_{side}", pos=(x, 1.30, 0.0), rot=(0.0, 0.0, -9.0 if side == "L" else 9.0))
        c.add_shape(f"ArmMesh_{side}", "cylinder", fur, arm, (0.0, -0.34, 0.0), size=(0.085, 0.72, 8))
        c.add_shape(f"Hand_{side}", "sphere", light_fur, arm, (0.0, -0.73, 0.0), size=(0.17, 0.19, 0.16))
    for side, x in [("L", -0.16), ("R", 0.16)]:
        leg = c.add_joint(f"Leg_{side}", pos=(x, 0.82, 0.0))
        c.add_shape(f"LegMesh_{side}", "cylinder", fur, leg, (0.0, -0.31, 0.0), size=(0.095, 0.66, 8))
        c.add_shape(f"Foot_{side}", "box", light_fur, leg, (0.0, -0.67, -0.10), size=(0.22, 0.16, 0.38))
    c.add_joint("Tail", pos=(0.0, 1.02, 0.30), rot=(65.0, 0.0, 0.0))
    c.add_shape("TailMesh", "cylinder", fur, "Tail", (0.0, 0.48, 0.0), size=(0.055, 0.98, 8))
    c.add_shape("Backpack", "box", leather, pos=(0.0, 1.17, 0.32), size=(0.42, 0.52, 0.20))
    return c


def build_robot() -> Character:
    c = Character("RobotExplorer")
    steel = c.material("brushed_steel", (0.48, 0.54, 0.58, 1.0), metallic=0.75, roughness=0.30)
    dark = c.material("graphite", (0.075, 0.095, 0.11, 1.0), metallic=0.55, roughness=0.36)
    cyan = c.material("cyan_display", (0.04, 0.62, 0.90, 1.0), metallic=0.1, roughness=0.2, emissive=(0.03, 0.35, 0.65))
    yellow = c.material("hazard_yellow", (0.95, 0.64, 0.07, 1.0), metallic=0.25, roughness=0.38)
    c.add_shape("Torso", "box", steel, pos=(0.0, 1.24, 0.0), size=(0.72, 0.74, 0.48))
    c.add_shape("ChestPanel", "box", dark, pos=(0.0, 1.27, -0.265), size=(0.46, 0.35, 0.05))
    c.add_shape("ChestGlow", "box", cyan, pos=(0.0, 1.30, -0.296), size=(0.28, 0.09, 0.025))
    c.add_joint("Head", pos=(0.0, 1.86, 0.0))
    c.add_shape("HeadMesh", "box", steel, "Head", size=(0.56, 0.48, 0.50))
    c.add_shape("FaceScreen", "box", dark, "Head", (0.0, 0.0, -0.275), size=(0.42, 0.25, 0.05))
    for side, x in [("L", -0.12), ("R", 0.12)]:
        c.add_shape(f"Eye_{side}", "box", cyan, "Head", (x, 0.03, -0.307), size=(0.075, 0.055, 0.02))
    c.add_shape("Antenna", "cylinder", dark, "Head", (0.0, 0.33, 0.0), size=(0.025, 0.24, 6))
    c.add_shape("AntennaTip", "sphere", yellow, "Head", (0.0, 0.47, 0.0), size=(0.10, 0.10, 0.10))
    for side, x in [("L", -0.46), ("R", 0.46)]:
        arm = c.add_joint(f"Arm_{side}", pos=(x, 1.47, 0.0))
        c.add_shape(f"Shoulder_{side}", "sphere", yellow, arm, size=(0.23, 0.23, 0.23))
        c.add_shape(f"ArmMesh_{side}", "cylinder", steel, arm, (0.0, -0.34, 0.0), size=(0.095, 0.62, 8))
        c.add_shape(f"Hand_{side}", "box", dark, arm, (0.0, -0.68, 0.0), size=(0.21, 0.18, 0.22))
    for side, x in [("L", -0.21), ("R", 0.21)]:
        leg = c.add_joint(f"Leg_{side}", pos=(x, 0.87, 0.0))
        c.add_shape(f"LegMesh_{side}", "cylinder", steel, leg, (0.0, -0.36, 0.0), size=(0.12, 0.70, 8))
        c.add_shape(f"Foot_{side}", "box", dark, leg, (0.0, -0.75, -0.09), size=(0.29, 0.22, 0.44))
    c.add_shape("PowerPack", "box", dark, pos=(0.0, 1.28, 0.33), size=(0.44, 0.48, 0.22))
    c.add_shape("PowerCore", "sphere", cyan, pos=(0.0, 1.28, 0.46), size=(0.16, 0.16, 0.10))
    return c


def build_treasure_hunter() -> Character:
    c = Character("TreasureHunter")
    skin = c.material("skin", (0.48, 0.25, 0.12, 1.0), roughness=0.88)
    olive = c.material("olive_jacket", (0.13, 0.29, 0.12, 1.0))
    khaki = c.material("khaki", (0.55, 0.42, 0.22, 1.0))
    leather = c.material("leather", (0.18, 0.075, 0.025, 1.0))
    gold = c.material("gold_trim", (0.92, 0.63, 0.10, 1.0), metallic=0.5, roughness=0.32)
    eye = c.material("eyes", (0.025, 0.018, 0.012, 1.0), roughness=0.3)
    parchment = c.material("parchment", (0.82, 0.70, 0.44, 1.0), roughness=0.95)
    _add_humanoid_rig(c, olive, skin, khaki, leather)
    _add_face(c, "Head", eye)
    c.add_shape("HatBrim", "cylinder", leather, "Head", (0.0, 0.31, 0.0), size=(0.37, 0.07, 12))
    c.add_shape("HatCrown", "cylinder", khaki, "Head", (0.0, 0.45, 0.0), size=(0.24, 0.25, 10))
    c.add_shape("HatBand", "cylinder", leather, "Head", (0.0, 0.36, 0.0), size=(0.255, 0.07, 10))
    c.add_shape("Satchel", "box", leather, pos=(0.38, 1.02, 0.12), rot=(0, 0, -9), size=(0.32, 0.42, 0.20))
    c.add_shape("SatchelBuckle", "box", gold, pos=(0.38, 1.05, -0.005), size=(0.10, 0.09, 0.04))
    c.add_shape("MapTube", "cylinder", parchment, pos=(-0.36, 1.14, 0.24), rot=(8, 0, -18), size=(0.075, 0.65, 8))
    c.add_shape("Backpack", "box", khaki, pos=(0.0, 1.26, 0.31), size=(0.42, 0.52, 0.22))
    return c


def build_tribal_adventurer() -> Character:
    c = Character("TribalAdventurer")
    skin = c.material("deep_skin", (0.25, 0.105, 0.055, 1.0), roughness=0.9)
    woven = c.material("woven_teal", (0.04, 0.34, 0.31, 1.0), roughness=0.94)
    orange = c.material("woven_orange", (0.86, 0.29, 0.055, 1.0), roughness=0.92)
    leather = c.material("dark_leather", (0.10, 0.045, 0.025, 1.0))
    bead = c.material("sunstone_beads", (0.96, 0.68, 0.10, 1.0), metallic=0.2, roughness=0.42)
    eye = c.material("eyes", (0.02, 0.015, 0.01, 1.0), roughness=0.3)
    _add_humanoid_rig(c, woven, skin, orange, leather, torso_scale=(0.72, 0.90, 0.44))
    _add_face(c, "Head", eye)
    c.add_shape("Headband", "cylinder", orange, "Head", (0.0, 0.19, 0.0), size=(0.275, 0.09, 12))
    for side, x in [("L", -0.11), ("R", 0.11)]:
        c.add_shape(f"HeadBead_{side}", "sphere", bead, "Head", (x, 0.27, -0.22), size=(0.07, 0.07, 0.05))
    for index, x in enumerate([-0.18, -0.09, 0.0, 0.09, 0.18]):
        c.add_shape(f"Necklace_{index}", "sphere", bead, pos=(x, 1.55 - abs(x) * 0.55, -0.31), size=(0.065, 0.065, 0.045))
    c.add_shape("WovenSash", "box", orange, pos=(-0.08, 1.27, -0.30), rot=(0, 0, -18), size=(0.14, 0.62, 0.055))
    c.add_shape("UtilityPouch", "box", leather, pos=(0.34, 1.02, 0.04), size=(0.28, 0.30, 0.18))
    c.add_shape("CarvedBackpack", "box", leather, pos=(0.0, 1.26, 0.32), size=(0.40, 0.48, 0.22))
    c.add_shape("SunEmblem", "octahedron", bead, pos=(0.0, 1.28, 0.47), size=(0.12, 0.16, 0.06))
    return c


def build_golden_explorer() -> Character:
    c = Character("GoldenExplorer")
    dark_gold = c.material("dark_gold", (0.58, 0.32, 0.045, 1.0), metallic=0.72, roughness=0.30)
    gold = c.material("sun_gold", (0.96, 0.67, 0.08, 1.0), metallic=0.82, roughness=0.22)
    cream = c.material("ivory_cloth", (0.86, 0.77, 0.54, 1.0), roughness=0.78)
    obsidian = c.material("obsidian", (0.035, 0.028, 0.022, 1.0), metallic=0.25, roughness=0.28)
    glow = c.material("sunstone_glow", (1.0, 0.42, 0.025, 1.0), metallic=0.1, roughness=0.18, emissive=(0.75, 0.18, 0.01))
    _add_humanoid_rig(c, gold, cream, dark_gold, obsidian, torso_scale=(0.74, 0.92, 0.45))
    for side, x in [("L", -0.09), ("R", 0.09)]:
        c.add_shape(f"Eye_{side}", "sphere", glow, "Head", (x, 0.06, -0.255), size=(0.055, 0.07, 0.035))
    c.add_shape("HelmBrim", "cylinder", dark_gold, "Head", (0.0, 0.31, 0.0), size=(0.34, 0.07, 12))
    c.add_shape("HelmCrown", "cylinder", gold, "Head", (0.0, 0.45, 0.0), size=(0.23, 0.26, 10))
    c.add_shape("SunCrest", "octahedron", glow, "Head", (0.0, 0.51, -0.19), size=(0.10, 0.15, 0.06))
    for side, x in [("L", -0.39), ("R", 0.39)]:
        c.add_shape(f"ShoulderGuard_{side}", "sphere", dark_gold, pos=(x, 1.48, 0.0), size=(0.34, 0.20, 0.38))
    c.add_shape("ChestSun", "octahedron", glow, pos=(0.0, 1.31, -0.33), size=(0.14, 0.20, 0.07))
    c.add_shape("RelicPack", "box", dark_gold, pos=(0.0, 1.26, 0.33), size=(0.44, 0.52, 0.24))
    c.add_shape("RelicCore", "octahedron", glow, pos=(0.0, 1.28, 0.49), size=(0.13, 0.19, 0.07))
    return c


CHARACTERS = {
    "monkey": build_monkey,
    "robot": build_robot,
    "treasure": build_treasure_hunter,
    "tribal": build_tribal_adventurer,
    "golden": build_golden_explorer,
}


def read_glb_json(path: Path) -> dict:
    with path.open("rb") as handle:
        magic, version, total_length = struct.unpack("<4sII", handle.read(12))
        if magic != b"glTF" or version != 2 or total_length != path.stat().st_size:
            raise ValueError(f"Invalid GLB header: {path}")
        json_length, chunk_type = struct.unpack("<I4s", handle.read(8))
        if chunk_type != b"JSON":
            raise ValueError(f"Missing GLB JSON chunk: {path}")
        return json.loads(handle.read(json_length).decode("utf-8"))


def main() -> None:
    expected_clips = {
        "CharacterArmature|Idle",
        "CharacterArmature|Run",
        "CharacterArmature|Run_Left",
        "CharacterArmature|Run_Right",
        "CharacterArmature|Roll",
        "CharacterArmature|Interact",
        "CharacterArmature|HitRecieve",
        "CharacterArmature|Wave",
        "CharacterArmature|Death",
    }
    for skin_id, builder in CHARACTERS.items():
        character = builder()
        output = ROOT / "assets" / "3d" / "characters" / skin_id / f"{skin_id}.glb"
        write_character_glb(output, character)
        gltf = read_glb_json(output)
        clips = {animation["name"] for animation in gltf.get("animations", [])}
        if clips != expected_clips:
            raise ValueError(f"Animation mismatch for {skin_id}: {sorted(clips)}")
        if len(gltf.get("nodes", [])) < 20 or len(gltf.get("meshes", [])) < 15:
            raise ValueError(f"Character detail check failed for {skin_id}")
        print(
            f"{output.relative_to(ROOT).as_posix()}: "
            f"{len(gltf['nodes'])} nodes, {len(gltf['meshes'])} meshes, "
            f"{len(gltf['animations'])} animations, {output.stat().st_size} bytes"
        )


if __name__ == "__main__":
    main()
