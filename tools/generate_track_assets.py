from __future__ import annotations

import json
import struct

from generate_missing_3d_assets import Model, ROOT


TRACK_LENGTH = 3.08
LANE_WIDTHS = {1: 2.60, 2: 4.45, 3: 6.25}
LANE_OFFSETS = {
    1: (0.0,),
    2: (-0.90, 0.90),
    3: (-1.80, 0.0, 1.80),
}

SURFACES = {
    "dirt": ("dirt", "dirt_light"),
    "grass": ("grass_dark", "grass"),
    "mud": ("mud", "dirt"),
    "stone": ("stone_dark", "stone"),
    "wood": ("log", "trunk"),
    "sand": ("sand", "dirt_light"),
    "skating": ((0.14, 0.18, 0.27, 1.0), (0.28, 0.35, 0.48, 1.0)),
    "water_slide": ((0.04, 0.38, 0.62, 0.94), "water_light"),
    "boat": ((0.03, 0.20, 0.31, 0.96), "water"),
}


def _add_surface_details(model: Model, surface: str, lane_count: int, width: float, accent) -> None:
    if surface in ("dirt", "grass", "mud", "sand"):
        for index, lane_x in enumerate(LANE_OFFSETS[lane_count]):
            model.add_box(
                f"worn_lane_{index}",
                (0.48 if surface != "grass" else 0.62, 0.025, TRACK_LENGTH * 0.88),
                (lane_x, 0.018, 0.0),
                accent,
                (0.0, 2.5 if index % 2 == 0 else -2.0, 0.0),
            )

    if surface == "grass":
        for side in (-1.0, 1.0):
            edge_x = side * (width * 0.5 - 0.20)
            for blade_index, z in enumerate((-1.05, -0.35, 0.42, 1.08)):
                model.add_box(
                    f"grass_edge_{side}_{blade_index}",
                    (0.07, 0.34 + blade_index * 0.035, 0.07),
                    (edge_x + side * (0.05 if blade_index % 2 else -0.05), 0.17, z),
                    "grass_light" if blade_index % 2 else "grass",
                    (0.0, 0.0, side * (8.0 + blade_index * 2.0)),
                )
    elif surface == "mud":
        model.add_sphere("mud_puddle_a", 0.40, (-width * 0.22, 0.025, -0.62), "mud", scale=(1.5, 0.04, 0.75), segments=10, rings=3)
        model.add_sphere("mud_puddle_b", 0.31, (width * 0.18, 0.026, 0.72), "dirt", scale=(1.25, 0.04, 0.72), segments=10, rings=3)
    elif surface == "stone":
        paver_width = width / float(lane_count + 1)
        for lane_index, lane_x in enumerate(LANE_OFFSETS[lane_count]):
            for z_index, z in enumerate((-1.0, 0.0, 1.0)):
                model.add_box(
                    f"paver_{lane_index}_{z_index}",
                    (paver_width, 0.035, 0.82),
                    (lane_x, 0.025 + 0.004 * ((lane_index + z_index) % 2), z),
                    "stone" if (lane_index + z_index) % 2 else "stone_dark",
                    (0.0, (-2.0 + 2.0 * z_index), 0.0),
                )
    elif surface == "wood":
        for plank_index, z in enumerate((-1.25, -0.75, -0.25, 0.25, 0.75, 1.25)):
            model.add_box(
                f"plank_{plank_index}",
                (width * 0.96, 0.055, 0.38),
                (0.0, 0.025 + (plank_index % 2) * 0.008, z),
                "trunk" if plank_index % 2 else "log",
                (0.0, 0.8 if plank_index % 2 else -0.8, 0.0),
            )
        for side in (-1.0, 1.0):
            model.add_box("wood_rail", (0.12, 0.14, TRACK_LENGTH), (side * width * 0.48, 0.08, 0.0), "hide_dark")
    elif surface == "sand":
        for ridge_index, z in enumerate((-0.95, -0.05, 0.84)):
            model.add_box(
                f"sand_ridge_{ridge_index}",
                (width * 0.72, 0.028, 0.07),
                ((ridge_index - 1) * 0.11, 0.023, z),
                "dirt_light",
                (0.0, 5.0 - ridge_index * 4.0, 0.0),
            )
    elif surface == "skating":
        for divider_index in range(1, lane_count):
            divider_x = -width * 0.5 + width * float(divider_index) / float(lane_count)
            model.add_box("lane_light", (0.055, 0.028, TRACK_LENGTH * 0.94), (divider_x, 0.025, 0.0), (0.12, 0.88, 1.0, 1.0))
        for side in (-1.0, 1.0):
            model.add_box("edge_light", (0.10, 0.045, TRACK_LENGTH * 0.96), (side * width * 0.47, 0.035, 0.0), (0.58, 0.25, 0.95, 1.0))
    elif surface in ("water_slide", "boat"):
        for side in (-1.0, 1.0):
            bank_color = (0.16, 0.55, 0.67, 1.0) if surface == "water_slide" else "grass_dark"
            model.add_box("channel_edge", (0.18, 0.18, TRACK_LENGTH), (side * width * 0.48, 0.08, 0.0), bank_color)
        model.add_box("water_glint_a", (width * 0.42, 0.022, 0.08), (-width * 0.10, 0.032, -0.62), "water_light", (0.0, 8.0, 0.0))
        model.add_box("water_glint_b", (width * 0.28, 0.022, 0.06), (width * 0.16, 0.034, 0.71), "water_light", (0.0, -7.0, 0.0))


def build_track(surface: str, lane_count: int) -> str:
    base, accent = SURFACES[surface]
    width = LANE_WIDTHS[lane_count]
    model = Model(f"track_{surface}_{lane_count}lane")
    model.add_box("track_base", (width, 0.16, TRACK_LENGTH), (0.0, -0.08, 0.0), base)
    _add_surface_details(model, surface, lane_count, width, accent)
    rel_path = f"assets/3d/environment/tracks/{surface}/track_{surface}_{lane_count}lane.glb"
    model.save(rel_path)
    return rel_path


def validate_glb(rel_path: str) -> None:
    path = ROOT / rel_path
    with path.open("rb") as handle:
        magic, version, total_length = struct.unpack("<4sII", handle.read(12))
        if magic != b"glTF" or version != 2 or total_length != path.stat().st_size:
            raise ValueError(f"Invalid GLB header: {path}")
        json_length, chunk_type = struct.unpack("<I4s", handle.read(8))
        if chunk_type != b"JSON":
            raise ValueError(f"Missing GLB JSON chunk: {path}")
        document = json.loads(handle.read(json_length).decode("utf-8").rstrip(" \t\r\n\x00"))
    if not document.get("meshes") or not document.get("materials"):
        raise ValueError(f"Track GLB has no renderable geometry: {path}")


def main() -> None:
    generated = [build_track(surface, lanes) for surface in SURFACES for lanes in (1, 2, 3)]
    for path in generated:
        validate_glb(path)
    print(f"Generated {len(generated)} modular track GLBs")
    for path in generated:
        print(path)


if __name__ == "__main__":
    main()
