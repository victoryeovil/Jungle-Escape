# 3D Asset Credits - Jungle Escape: Lost Path

Record every third-party 3D asset imported into the project here.

## Playable Characters

| Local asset | In-game name | Source title | Author | Source URL | License | Download date | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `res://assets/3d/characters/kairo/kairo.glb` | Kairo | Adventurer | Quaternius | https://poly.pizza/m/5EGWBMpuXq | CC0 1.0 / Public Domain | 2026-06-18 | Downloaded as GLB from Poly Pizza static asset URL. Includes 24 animations. |
| `res://assets/3d/characters/kairo/kairo_source_preview.jpg` | Kairo source preview | Adventurer preview image | Quaternius / Poly Pizza | https://poly.pizza/m/5EGWBMpuXq | CC0 1.0 source model; preview retained for internal reference | 2026-06-18 | Internal source reference only. |
| `res://assets/3d/characters/zuri/zuri.glb` | Zuri | Animated Woman | Quaternius | https://poly.pizza/m/nIItLV9nxS | CC0 1.0 / Public Domain | 2026-06-18 | Downloaded as GLB from Poly Pizza static asset URL. Includes 24 animations. |
| `res://assets/3d/characters/zuri/zuri_source_preview.jpg` | Zuri source preview | Animated Woman preview image | Quaternius / Poly Pizza | https://poly.pizza/m/nIItLV9nxS | CC0 1.0 source model; preview retained for internal reference | 2026-06-18 | Internal source reference only. |
| `res://assets/3d/characters/monkey/monkey.glb` | Monkey | Original generated playable character | Jungle Escape project | — | Original project-authored output | 2026-06-23 | Animated low-poly monkey explorer with scout vest, backpack, and nine gameplay clips. |
| `res://assets/3d/characters/robot/robot.glb` | Robot Explorer | Original generated playable character | Jungle Escape project | — | Original project-authored output | 2026-06-23 | Animated steel/cyan robot explorer with power pack and nine gameplay clips. |
| `res://assets/3d/characters/treasure/treasure.glb` | Treasure Hunter | Original generated playable character | Jungle Escape project | — | Original project-authored output | 2026-06-23 | Animated explorer with hat, satchel, map tube, and backpack. |
| `res://assets/3d/characters/tribal/tribal.glb` | Tribal Adventurer | Original generated playable character | Jungle Escape project | — | Original project-authored output | 2026-06-23 | Animated fictional woven-adventure design with Sunstone accents. |
| `res://assets/3d/characters/golden/golden.glb` | Golden Explorer | Original generated playable character | Jungle Escape project | — | Original project-authored output | 2026-06-23 | Animated gold/obsidian explorer with emissive Sunstone accents. |
| `res://assets/3d/characters/monkey/monkey_source_preview.png` | Monkey source preview | Generated low-poly presentation render | Jungle Escape project / OpenAI image generation | — | Project-generated output | 2026-06-23 | 1220×720 full-body preview matching the Monkey GLB design brief. |
| `res://assets/3d/characters/robot/robot_source_preview.png` | Robot Explorer source preview | Generated low-poly presentation render | Jungle Escape project / OpenAI image generation | — | Project-generated output | 2026-06-23 | 1220×720 full-body preview matching the Robot Explorer GLB design brief. |
| `res://assets/3d/characters/treasure/treasure_source_preview.png` | Treasure Hunter source preview | Generated low-poly presentation render | Jungle Escape project / OpenAI image generation | — | Project-generated output | 2026-06-23 | 1220×720 full-body preview matching the Treasure Hunter GLB design brief. |
| `res://assets/3d/characters/tribal/tribal_source_preview.png` | Tribal Adventurer source preview | Generated low-poly presentation render | Jungle Escape project / OpenAI image generation | — | Project-generated output | 2026-06-23 | 1220×720 full-body preview matching the fictional woven-adventure GLB design brief. |
| `res://assets/3d/characters/golden/golden_source_preview.png` | Golden Explorer source preview | Generated low-poly presentation render | Jungle Escape project / OpenAI image generation | — | Project-generated output | 2026-06-23 | 1220×720 full-body preview matching the Golden Explorer GLB design brief. |

## Project-Authored Generated 3D Assets

| Local asset group | Source | Author | License/status | Generated date | Notes |
| --- | --- | --- | --- | --- | --- |
| `res://assets/3d/environment/**/*.glb` | `tools/generate_missing_3d_assets.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-19 | Low-poly path, foliage, tree, rock, and bridge kits. |
| `res://assets/3d/obstacles/**/*.glb` | `tools/generate_missing_3d_assets.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-19 | Low-poly fallen log, rock, spike trap, mud patch, river gap, boulder, slide barrier, pressure plate, and sand dune. |
| `res://assets/3d/goals/**/*.glb`, `res://assets/3d/rewards/**/*.glb` | `tools/generate_missing_3d_assets.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-19 | Low-poly gates, portals, altars, and treasure chest. |
| `res://assets/3d/collectibles/**/*.glb` | `tools/generate_missing_3d_assets.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-19 | Low-poly coin, gem, resources, relic key, and Sunstone shard. |
| `res://assets/3d/wildlife/**/*.glb` | `tools/generate_missing_3d_assets.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-19 | Static low-poly Big 5 and supporting wildlife. Animation loops remain future polish. |
| `res://assets/3d/upgrades/sand_shoes.glb`, `res://assets/3d/materials/*.tres`, `res://assets/3d/vfx/*` | `tools/generate_missing_3d_assets.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-19 | Sand Shoes prop, materials, foliage shader, and particle scene resources. |
| `res://assets/3d/characters/{monkey,robot,treasure,tribal,golden}/**` | `tools/generate_playable_characters.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-23 | Animated low-poly playable skin GLBs and Godot wrapper scenes. |
| `res://assets/3d/outfits/**`, `res://assets/3d/vehicles/canoe.glb` | `tools/generate_mode_equipment.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-23 | Modular upgrade, skating, and boat clothing plus the pointed expedition canoe used by `Player3D.gd`. |
| `res://assets/3d/environment/tracks/**/*.glb` | `tools/generate_track_assets.py` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-23 | 27 modular one-, two-, and three-lane track assets across nine surfaces, wired through `LevelManager3D.gd`. |
| Runtime Level 7-20 procedural dressing nodes | `scripts/gameplay/LevelManager3D.gd` | Jungle Escape project | Original project-authored output; no third-party attribution required | 2026-06-25 | Primitive-mesh side dressing for settlement props, tall grass, gorge spray, market stalls/reeds, logs/mounds, river mist, relic tablets, baobabs, and gold relics. |

## License Notes

- Poly Pizza lists both source model pages as `Public Domain (CC0)` / `CC0 1.0`.
- Attribution is not required for CC0, but the project keeps credits for auditability and store-review safety.
- If these models are edited in Blender later, add a new row with the modified local path and a short modification note.
