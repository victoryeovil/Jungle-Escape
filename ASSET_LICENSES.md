# Asset Licenses — Jungle Escape: Lost Path

This root ledger summarizes commercial-safety status for all assets. Detailed imported 3D character credits remain in `res://assets/3d/ASSET_CREDITS.md`.

---

## Assets to Download (Free, Confirmed CC0)

### Kenney UI Pack — Adventure
- **License:** CC0 Public Domain
- **Download:** https://kenney.nl/media/pages/assets/ui-pack-adventure/9a877376bc-1723597274/kenney_ui-pack-adventure.zip
- **Used for:** Level marker button styles, HUD panels, preview panel borders
- **Extract to:** `res://assets/ui/kenney_ui_adventure/`
- **Contents:** 128 sprites (buttons, panels, sliders) in PNG + SVG

### Kenney Game Icons
- **License:** CC0 Public Domain
- **Download:** https://kenney.nl/media/pages/assets/game-icons/1ebf9c14af-1677661579/kenney_game-icons.zip
- **Used for:** Lock, star, flag, map, scroll icons on level markers
- **Extract to:** `res://assets/ui/kenney_game_icons/`
- **Contents:** 105 icons

### Kenney Game Icons Expansion
- **License:** CC0 Public Domain
- **Download:** https://kenney.nl/assets/game-icons-expansion
- **Used for:** Resource icons (bricks, wood, food etc.) and upgrade icons
- **Extract to:** `res://assets/ui/kenney_game_icons_expansion/`

### Quaternius — Stylized Nature MegaKit
- **License:** CC0 Public Domain
- **Download:** https://quaternius.com/packs/stylizednaturemegakit.html
  (mirror: https://poly.pizza/bundle/Stylized-Nature-MegaKit-T34GZFA0fm)
- **Used for:** 3D jungle trees, rocks, bushes for gameplay scenes
- **Extract to:** `res://assets/3d/nature/quaternius/`
- **Contents:** 116 models (40 trees, 35 plants, 27 rocks); FBX/OBJ/glTF; Godot 4 ready

### Quaternius — Ultimate Stylized Nature Pack
- **License:** CC0 Public Domain
- **Download:** https://quaternius.com/packs/ultimatestylizednature.html
- **Used for:** Palm trees and tropical plants in 3D scenes
- **Extract to:** `res://assets/3d/nature/quaternius/`

---

## Assets Requiring Attribution (CC BY)

### Poly Pizza — Elephant (Poly by Google)
- **License:** CC BY 3.0 — **ATTRIBUTION REQUIRED IN GAME CREDITS**
- **Credit line:** "Elephant" by Poly by Google, CC BY 3.0
- **Download:** https://poly.pizza/m/cx0-TiCjDOx
- **Status:** Not imported / not used after the generated original elephant GLB pass.
- **Former intended use:** Elephant silhouette in Wildlands zone
- **Extract to:** `res://assets/3d/animals/elephant.glb`

---

## User-Provided UI Assets

| Asset | Source | License/status | Local files | Usage notes |
| --- | --- | --- | --- | --- |
| Jungle map full-screen reference art | User provided `C:\Users\dell\Downloads\map.png` in Codex session | User-provided project asset; confirm rights before store submission if the image source is not original or licensed for this project | `res://assets/backgrounds/bg_jungle_map.png` | Used by `LevelSelect.gd` as the exact map page art plate with transparent gameplay hit targets layered above it. |
| Build Your Home full-screen reference art | User provided `C:\Users\dell\Downloads\home.png` in Codex session | User-provided project asset; confirm rights before store submission if the image source is not original or licensed for this project | `res://assets/backgrounds/bg_home_building.png` | Used by `HomeBuilding.gd` as the exact home-building screen art plate with transparent controls layered above it. |
| Choose Explorer full-screen reference art | User provided `C:\Users\dell\Downloads\build.png` in Codex session | User-provided project asset; confirm rights before store submission if the image source is not original or licensed for this project | `res://assets/backgrounds/bg_choose_explorer.png` | Used by `Shop.gd` as the exact character-select screen art plate with transparent controls layered above it. |

---

## Still Needed (Not Yet Sourced)

| Asset | Purpose | Target path | Priority |
|-------|---------|-------------|----------|
| `marker_*.png` (5 states) | Level marker images | `assets/ui/map/markers/` | HIGH |
| `landmark_camp.png` etc. | Camp/river/temple/wildlands | `assets/ui/map/landmarks/` | MED |
| `icon_sand_shoes.png` | Sand Shoes upgrade icon 64×64 | `assets/ui/upgrades/` | MED |
| `icon_*.png` (9 resources) | Resource icons for HUD/shop | `assets/ui/icons/` | MED |
| `home_stage_1-6.png` | Home building progress visuals | `assets/ui/home/` | LOW |

---

## License Quick Reference

| License | Commercial | Attribution | Modify |
|---------|-----------|-------------|--------|
| CC0     | ✅         | ❌ no       | ✅      |
| CC BY   | ✅         | ✅ REQUIRED | ✅      |
| CC BY-NC| ❌ no      | ✅ REQUIRED | ✅      |

**Rule:** Default to CC0. Use CC BY only when CC0 unavailable; add credit line.

---

## Project-Authored Generated 3D Assets

| Asset group | Source | License/status | Local files | Usage notes |
| --- | --- | --- | --- | --- |
| Generated low-poly 3D environment, obstacle, goal, reward, collectible, wildlife, upgrade, material, and VFX assets | Authored in `tools/generate_missing_3d_assets.py` for this project | Original project-authored output; no third-party license or attribution required | `res://assets/3d/environment/`, `res://assets/3d/obstacles/`, `res://assets/3d/goals/`, `res://assets/3d/rewards/`, `res://assets/3d/collectibles/`, `res://assets/3d/wildlife/`, `res://assets/3d/upgrades/`, `res://assets/3d/materials/`, `res://assets/3d/vfx/` | Low-poly GLB/resource fill pass for the targets tracked in `MISSING_3D_ASSETS.md`. Godot still needs to import the GLBs in-editor to create `.import` metadata before runtime replacement work. |

---

## Imported 3D Characters

| Asset | Source | Author | License | Local files | Usage notes |
| --- | --- | --- | --- | --- | --- |
| Kairo playable explorer, based on `Adventurer` | Poly Pizza: https://poly.pizza/m/5EGWBMpuXq | Quaternius | CC0 1.0 / Public Domain | `res://assets/3d/characters/kairo/kairo.glb`, `res://assets/3d/characters/kairo/Kairo.tscn` | Default playable male explorer. Includes imported animation clips used by `Player3D.gd`. |
| Zuri playable explorer, based on `Animated Woman` | Poly Pizza: https://poly.pizza/m/nIItLV9nxS | Quaternius | CC0 1.0 / Public Domain | `res://assets/3d/characters/zuri/zuri.glb`, `res://assets/3d/characters/zuri/Zuri.tscn` | Selectable female explorer. Includes imported animation clips used by `Player3D.gd`. |

## Procedural Godot Assets

| Asset group | Source | License/status | Usage notes |
| --- | --- | --- | --- |
| Level 1 jungle path, terrain, grass, ferns, bushes, palms, jungle trees, vines, rocks, logs, ruins, low branch, coins, butterflies, birds, torches, and temple finish gate | Authored procedurally in `res://scripts/gameplay/LevelManager3D.gd` using Godot primitive meshes and project materials | Original project implementation; no third-party asset license required | Mobile-friendly low-poly placeholder-to-production art direction. Final GLB environment packs can replace these nodes later while preserving gameplay signals and collision metadata. |

## License Rules

- Prefer CC0/public-domain assets from Quaternius, Kenney, or verified Poly Pizza pages.
- Do not import OpenGameArt assets unless the exact asset license is checked and recorded here.
- Record source URL, author, license, local path, download date, and modification notes before shipping any imported asset.
