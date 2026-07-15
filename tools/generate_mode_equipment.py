from __future__ import annotations

from pathlib import Path

from generate_missing_3d_assets import Model
from generate_playable_characters import read_glb_json


ROOT = Path(__file__).resolve().parents[1]


def build_upgrade_outfit() -> Model:
    model = Model("UpgradeOutfit")
    olive = (0.12, 0.34, 0.16, 1.0)
    olive_light = (0.24, 0.52, 0.24, 1.0)
    leather = (0.18, 0.075, 0.028, 1.0)
    brass = (0.92, 0.62, 0.10, 1.0)
    sand = (0.72, 0.52, 0.26, 1.0)

    # Reinforced expedition vest that remains readable over every base skin.
    for side in (-1, 1):
        model.add_box(
            "vest_front",
            (0.28, 0.62, 0.085),
            (side * 0.18, 1.28, -0.31),
            olive,
            (0, 0, side * 3),
        )
        model.add_box(
            "shoulder_strap",
            (0.10, 0.62, 0.075),
            (side * 0.23, 1.45, -0.34),
            olive_light,
            (0, 0, side * 9),
        )
        model.add_box("belt_pouch", (0.25, 0.22, 0.20), (side * 0.34, 0.99, -0.04), leather)
        model.add_box("sand_boot", (0.31, 0.25, 0.48), (side * 0.18, 0.16, -0.08), sand)
        model.add_box("boot_sole", (0.34, 0.07, 0.53), (side * 0.18, 0.025, -0.09), leather)
        model.add_box("wrist_guard", (0.21, 0.18, 0.20), (side * 0.47, 0.91, -0.02), leather)
    model.add_box("vest_back", (0.58, 0.56, 0.075), (0.0, 1.29, 0.29), olive)
    model.add_box("utility_belt", (0.76, 0.12, 0.43), (0.0, 0.99, 0.0), leather)
    model.add_box("belt_buckle", (0.15, 0.13, 0.055), (0.0, 0.99, -0.25), brass)
    model.add_box("field_pack", (0.44, 0.48, 0.20), (0.0, 1.27, 0.38), olive_light)
    model.add_cylinder("canteen", 0.09, 0.25, (0.34, 1.12, 0.30), brass, (90, 0, 0), segments=10)
    return model


def build_skating_outfit() -> Model:
    model = Model("SkatingOutfit")
    navy = (0.04, 0.12, 0.24, 1.0)
    cyan = (0.04, 0.68, 0.88, 1.0)
    violet = (0.48, 0.20, 0.80, 1.0)
    silver = (0.62, 0.68, 0.72, 1.0)
    black = (0.025, 0.03, 0.04, 1.0)

    # Helmet cap, safety stripe, elbow/knee protection, and inline skates.
    model.add_sphere("helmet", 0.42, (0.0, 2.12, 0.03), navy, scale=(0.78, 0.48, 0.72), segments=12, rings=5)
    model.add_box("helmet_brow", (0.58, 0.075, 0.12), (0.0, 1.98, -0.25), cyan)
    model.add_box("helmet_stripe", (0.10, 0.13, 0.58), (0.0, 2.25, 0.03), violet)
    for side in (-1, 1):
        model.add_sphere("elbow_pad", 0.15, (side * 0.47, 1.04, -0.04), navy, scale=(0.85, 0.75, 0.52), segments=8, rings=4)
        model.add_sphere("knee_pad", 0.17, (side * 0.18, 0.49, -0.15), violet, scale=(0.82, 0.95, 0.48), segments=8, rings=4)
        model.add_box("skate_boot", (0.29, 0.27, 0.48), (side * 0.18, 0.17, -0.09), navy)
        model.add_box("skate_frame", (0.12, 0.08, 0.52), (side * 0.18, -0.01, -0.08), silver)
        for wheel_z in (-0.22, 0.0, 0.22):
            model.add_cylinder(
                "skate_wheel",
                0.065,
                0.12,
                (side * 0.18, -0.08, wheel_z - 0.08),
                cyan if wheel_z == 0.0 else black,
                (0, 0, 90),
                segments=10,
            )
    model.add_box("safety_harness", (0.68, 0.09, 0.08), (0.0, 1.34, -0.34), cyan)
    model.add_box("safety_harness", (0.09, 0.58, 0.08), (-0.18, 1.34, -0.34), cyan, (0, 0, -18))
    model.add_box("safety_harness", (0.09, 0.58, 0.08), (0.18, 1.34, -0.34), cyan, (0, 0, 18))
    return model


def build_boat_outfit() -> Model:
    model = Model("BoatOutfit")
    orange = (0.96, 0.31, 0.045, 1.0)
    orange_dark = (0.55, 0.12, 0.025, 1.0)
    yellow = (1.00, 0.76, 0.10, 1.0)
    navy = (0.035, 0.12, 0.20, 1.0)
    aqua = (0.08, 0.60, 0.72, 1.0)

    # Life jacket is split into panels to avoid replacing the character's identity.
    for side in (-1, 1):
        model.add_box("life_jacket_front", (0.29, 0.66, 0.12), (side * 0.18, 1.30, -0.34), orange, (0, 0, side * 3))
        model.add_box("reflective_strip", (0.08, 0.52, 0.025), (side * 0.17, 1.32, -0.415), yellow, (0, 0, side * 6))
        model.add_box("water_boot", (0.30, 0.31, 0.48), (side * 0.18, 0.18, -0.06), navy)
        model.add_box("boot_trim", (0.31, 0.06, 0.49), (side * 0.18, 0.33, -0.06), aqua)
    model.add_box("life_jacket_back", (0.60, 0.62, 0.10), (0.0, 1.30, 0.31), orange_dark)
    model.add_box("waist_buckle", (0.16, 0.13, 0.07), (0.0, 1.05, -0.43), navy)
    model.add_box("waist_strap", (0.72, 0.09, 0.08), (0.0, 1.05, -0.37), yellow)
    model.add_cylinder("flotation_collar", 0.29, 0.12, (0.0, 1.64, 0.0), orange, (90, 0, 0), segments=12)
    model.add_box("river_pack", (0.40, 0.38, 0.18), (0.0, 1.24, 0.42), aqua)
    return model


def build_canoe() -> Model:
    model = Model("ExpeditionCanoe")
    hull = (0.38, 0.16, 0.055, 1.0)
    wood = (0.66, 0.36, 0.11, 1.0)
    wood_light = (0.86, 0.58, 0.22, 1.0)
    rope = (0.74, 0.58, 0.30, 1.0)
    metal = (0.22, 0.27, 0.29, 1.0)

    # Hollow, pointed canoe hull with the origin centred at waterline.
    points = [
        (0.0, 0.16, -1.65),
        (-0.72, 0.28, -0.78),
        (-0.76, 0.28, 0.78),
        (0.0, 0.16, 1.65),
        (0.72, 0.28, 0.78),
        (0.76, 0.28, -0.78),
        (-0.42, -0.22, -0.70),
        (-0.44, -0.22, 0.70),
        (0.44, -0.22, 0.70),
        (0.42, -0.22, -0.70),
    ]
    faces = [
        (0, 1, 6), (0, 6, 9), (0, 9, 5),
        (1, 2, 7), (1, 7, 6),
        (2, 3, 7), (3, 8, 7), (3, 4, 8),
        (4, 5, 9), (4, 9, 8),
        (6, 7, 8), (6, 8, 9),
    ]
    model.add_flat_faces(points, faces, hull)
    for side in (-1, 1):
        model.add_box("gunwale", (0.10, 0.10, 2.55), (side * 0.68, 0.31, 0.0), wood_light)
        model.add_box("bow_rail", (0.09, 0.09, 0.82), (side * 0.38, 0.28, -1.22), wood_light, (0, side * -28, 0))
        model.add_box("stern_rail", (0.09, 0.09, 0.82), (side * 0.38, 0.28, 1.22), wood_light, (0, side * 28, 0))
    for seat_z in (-0.52, 0.52):
        model.add_box("seat", (1.10, 0.10, 0.28), (0.0, 0.27, seat_z), wood)
    model.add_box("keel", (0.12, 0.10, 2.20), (0.0, -0.25, 0.0), wood)
    model.add_cylinder("paddle_shaft", 0.035, 2.05, (0.82, 0.60, 0.10), rope, (0, 0, 61), segments=8)
    model.add_box("paddle_blade", (0.28, 0.50, 0.07), (1.70, 1.08, 0.10), wood_light, (0, 0, -29))
    model.add_box("bow_guard", (0.14, 0.24, 0.18), (0.0, 0.22, -1.60), metal)
    return model


ASSETS = {
    "assets/3d/outfits/upgrade/upgrade_outfit.glb": build_upgrade_outfit,
    "assets/3d/outfits/skating/skating_outfit.glb": build_skating_outfit,
    "assets/3d/outfits/boat/boat_outfit.glb": build_boat_outfit,
    "assets/3d/vehicles/canoe.glb": build_canoe,
}


def main() -> None:
    for relative_path, builder in ASSETS.items():
        output = builder().save(relative_path)
        gltf = read_glb_json(output)
        if gltf.get("asset", {}).get("version") != "2.0":
            raise ValueError(f"Invalid glTF version: {relative_path}")
        if not gltf.get("meshes") or not gltf.get("materials"):
            raise ValueError(f"Missing runtime geometry: {relative_path}")
        primitive_count = sum(len(mesh.get("primitives", [])) for mesh in gltf["meshes"])
        print(
            f"{output.relative_to(ROOT).as_posix()}: "
            f"{primitive_count} primitives, {len(gltf['materials'])} materials, "
            f"{output.stat().st_size} bytes"
        )


if __name__ == "__main__":
    main()
