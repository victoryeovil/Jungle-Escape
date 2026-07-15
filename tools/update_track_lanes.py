from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEVEL_DIR = ROOT / "data" / "levels3d"

ONE_LANE_TYPES = {
    "narrow_passage",
    "ruins_corridor",
    "tree_root_jump_section",
    "water_slide_entry",
    "water_slide_curve",
    "water_slide_drop",
}
TWO_LANE_TYPES = {"bridge_crossing"}
THREE_LANE_TYPES = {"junction_two_way", "junction_three_way", "animal_chase_lane", "animal_escape_section"}
JUNGLE_GRASS_LEVELS = {1, 2, 7, 8, 9, 11, 13, 19, 20}


def lane_count_for(level_id: int, module_index: int, module: dict) -> int:
    kind = str(module.get("type", ""))
    if kind in ONE_LANE_TYPES:
        return 1
    if kind in TWO_LANE_TYPES:
        return 2
    if kind in THREE_LANE_TYPES:
        return 3
    if str(module.get("mode", "")) == "boat":
        return 2 if (level_id + module_index) % 2 == 0 else 3
    if str(module.get("mode", "")) == "skating":
        return 3 if module_index == 0 else 2
    if kind == "finish_gate_approach":
        return 2 if level_id % 2 else 3
    return (3, 2, 1, 2)[(level_id + module_index) % 4]


def module_for_row(modules: list[dict], row: int, level_length: int) -> dict | None:
    if row >= level_length:
        return None
    cursor = 0
    for module in modules:
        rows = max(1, int(module.get("rows", 1)))
        if cursor <= row < cursor + rows:
            return module
        cursor += rows
    return None


def remap_lane(old_lane: int, lane_count: int, row: int, level_id: int) -> int:
    if lane_count <= 1:
        return 0
    if lane_count == 2:
        if old_lane <= 0:
            return 0
        if old_lane >= 2:
            return 1
        return (row + level_id) % 2
    return max(0, min(2, old_lane))


def update_level(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    level_id = int(data.get("id", 1))
    modules = list(data.get("path_modules", []))

    for index, module in enumerate(modules):
        lanes = lane_count_for(level_id, index, module)
        module["lanes"] = lanes
        module["width"] = ("single", "double", "triple")[lanes - 1]

    if level_id in JUNGLE_GRASS_LEVELS:
        candidates = [
            module
            for module in modules
            if str(module.get("surface", "")) in {"dirt", "grass"}
            and str(module.get("mode", "run")) in {"run", "chase", "escape"}
            and str(module.get("type", "")) not in {"junction_two_way", "junction_three_way"}
        ]
        if candidates:
            selected = (level_id - 1) % len(candidates)
            for index, module in enumerate(candidates):
                module["surface"] = "grass" if index == selected else "dirt"

    level_length = sum(max(1, int(module.get("rows", 1))) for module in modules)
    data["length"] = level_length
    for collection_name in ("obstacles", "coins", "collectables"):
        for item in data.get(collection_name, []):
            row = int(item.get("row", 0))
            module = module_for_row(modules, row, level_length)
            lanes = int(module.get("lanes", 3)) if module is not None else 3
            item["lane"] = remap_lane(int(item.get("lane", 1)), lanes, row, level_id)

    data["environment"] = {
        "wind_strength": round(0.58 + (level_id % 5) * 0.09, 2),
        "wind_speed": round(0.82 + (level_id % 4) * 0.13, 2),
        "gust_strength": round(0.18 + (level_id % 3) * 0.08, 2),
        "grass_footprints": True,
    }
    identity = str(data.get("path_identity", "")).split("; variable 1/2/3-lane living trail", 1)[0]
    data["path_identity"] = identity + "; variable 1/2/3-lane living trail"
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def validate_level(path: Path) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    modules = list(data.get("path_modules", []))
    total_rows = sum(int(module.get("rows", 0)) for module in modules)
    if total_rows != int(data.get("length", -1)):
        raise ValueError(f"{path.name}: module rows {total_rows} != length {data.get('length')}")
    for module in modules:
        lanes = int(module.get("lanes", 0))
        if lanes not in {1, 2, 3}:
            raise ValueError(f"{path.name}: invalid lane count {lanes}")
        surface = str(module.get("surface", "dirt"))
        track = ROOT / "assets" / "3d" / "environment" / "tracks" / surface / f"track_{surface}_{lanes}lane.glb"
        if not track.exists():
            raise ValueError(f"{path.name}: missing track asset {track}")
    for collection_name in ("obstacles", "coins", "collectables"):
        for item in data.get(collection_name, []):
            row = int(item.get("row", 0))
            module = module_for_row(modules, row, total_rows)
            lanes = int(module.get("lanes", 3)) if module is not None else 3
            lane = int(item.get("lane", 0))
            if not 0 <= lane < lanes:
                raise ValueError(f"{path.name}: {collection_name} row {row} lane {lane} outside {lanes}-lane track")


def main() -> None:
    paths = sorted(LEVEL_DIR.glob("level3d_*.json"))
    for path in paths:
        update_level(path)
    for path in paths:
        validate_level(path)
    print(f"Updated {len(paths)} level JSON files with lane topology, grass trails, and wind settings")


if __name__ == "__main__":
    main()
