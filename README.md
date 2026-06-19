# Jungle Escape: Lost Path

A **3D lane runner adventure game** for Android, built with Godot 4.6 + GDScript.

The player controls Kairo or Zuri through procedurally built jungle environments, collecting coins and resources, avoiding obstacles, and making Temple-Run-style 90° path turns across 6 levels — ending in the Wildlands of Peace where Sand Shoes are required to continue.

---

## Quick Start (Developer)

1. Install **Godot 4.6** from https://godotengine.org/download
2. Open Godot, click **Import**, and select `project.godot` in this folder.
3. Press **F5** to run from `scenes/main_menu/MainMenu.tscn`.
4. Desktop controls: **A/D** = lane switch, **W/Space** = jump, **S** = slide, **Left/Right arrow** = lane switch.
5. For Android export, see `PLAYSTORE_CHECKLIST.md`.

---

## Project Structure

```
jungle_escape/
├── project.godot                  — Godot 4.6 project config (480×854 portrait, mobile renderer)
├── data/
│   ├── levels/                    — 20 archived 2D level JSON files
│   └── levels3d/                  — 6 active 3D level JSON files (level3d_001 … level3d_006)
├── scenes/
│   ├── game3d/Game3D.tscn         — Main 3D gameplay scene
│   ├── menus/LevelSelect.tscn     — Jungle expedition map (procedural draw, 6 levels)
│   ├── menus/WildlandsUnlock.tscn — Level 6 story transition screen
│   ├── menus/UpgradeShop.tscn     — Sand Shoes and future upgrades
│   ├── menus/HomeBuilding.tscn    — 6-stage home building progression
│   ├── main_menu/MainMenu.tscn    — Main menu
│   └── splash/SplashScreen.tscn  — Splash + story intro routing
├── scripts/
│   ├── autoload/                  — GameManager, SaveManager, AudioManager, EventBus
│   ├── gameplay/                  — Player3D, InputHandler3D, LevelManager3D
│   └── ui/                        — Game3D, HUD3D, LevelSelect, LevelComplete3D, UpgradeShop, HomeBuilding
├── assets/
│   ├── 3d/characters/             — Kairo (kairo.glb) and Zuri (zuri.glb) with wrapper scenes
│   ├── fonts/                     — title_font.ttf (Cinzel) + body_font.ttf (Inter)
│   ├── ui/icons/                  — HUD icons (pause, restart, hint, coin, key, star)
│   ├── backgrounds/               — bg_main_menu.png, bg_gameplay.png
│   └── sounds/                    — SFX + music WAV starters
└── docs/
    ├── checkpoint.md              — Session-by-session handoff (current: Session 17)
    ├── CHANGELOG.md               — Version history
    ├── TASKS.md                   — Full task tracker
    ├── MISSING_UI_ASSETS.md       — UI/map/icon asset gap tracker
    └── MISSING_3D_ASSETS.md       — 3D model/animation asset gap tracker
```

---

## Gameplay

- Player auto-runs forward through a 3-lane jungle path.
- **Swipe left / right** (or A/D keys) — change lanes or trigger a path turn.
- **Swipe up** (or W/Space) — jump over logs and obstacles.
- **Swipe down** (or S) — slide under low branches.
- **Path turns** — at corner tiles, a "TURN LEFT / TURN RIGHT" prompt appears; swipe any direction to execute. A log-jam dam blocks going straight.
- Collect coins, gems, and resources. Hit an obstacle → Game Over. Reach the finish gate → Level Complete (1–3 stars).
- **Level 6** requires **Sand Shoes** (150 Coins, bought in the Upgrade Shop) — deep sand blocks movement without them.

---

## Characters

| ID | Name | Model | License |
|----|------|-------|---------|
| `explorer` | Kairo | Quaternius "Adventurer" (Poly Pizza) | CC0 |
| `jungle_girl` | Zuri | Quaternius "Animated Woman" (Poly Pizza) | CC0 |

Both characters are selectable from the Shop screen and unlocked by default.

---

## Levels

| # | Name | Length | Turn | Difficulty |
|---|------|--------|------|------------|
| 1 | Jungle Trail | 26 tiles | — | Tutorial |
| 2 | Deep Forest | 33 tiles | Row 20, LEFT | Easy |
| 3 | River of Echoes | 40 tiles | Row 18, RIGHT | Medium |
| 4 | Ancient Ruins | 45 tiles | Row 22, LEFT | Hard |
| 5 | Temple Approach | 50 tiles | Row 25, RIGHT | Hardest |
| 6 | Wildlands of Peace | 40 tiles | Row 18, LEFT | Special — Sand Shoes required |

---

## Collectables

All collectables are implemented in code. Icon and 3D model assets are still needed for most types.

| Collectable | In-game ID | Icon | 3D Model | Notes |
|-------------|-----------|------|----------|-------|
| **Coins** | `coins` | ✅ (emoji 🪙) | ✅ procedural cylinder | Primary currency. Earned every level. |
| **Gems** | `gems` | ❌ missing `icon_gem.png` | ❌ missing `gem.glb` | Bonus pickups. Higher value than coins. |
| **Bricks** | `bricks` | ❌ missing `icon_bricks.png` | ❌ missing `brick.glb` | Home building resource. |
| **Wood** | `wood` | ❌ missing `icon_wood.png` | ❌ missing `wood.glb` | Home building resource. |
| **Tiles** | `tiles` | ❌ missing `icon_tiles.png` | ❌ missing `tile.glb` | Home building resource. |
| **Windows** | `windows` | ❌ missing `icon_windows.png` | ❌ missing (UI only) | Home building resource. |
| **Food** | `food` | ❌ missing `icon_food.png` | ❌ missing `food.glb` | Resource drop. |
| **Tools** | `tools` | ❌ missing `icon_tools.png` | ❌ missing `tools.glb` | Home building resource. |
| **Relic Keys** | `relic_keys` | ❌ missing `icon_relic_key.png` | ❌ missing `relic_key.glb` | Rare drop. Used in ruins/temple levels. |
| **Sunstone Shards** | `sunstone_shards` | ❌ missing `icon_sunstone_shard.png` | ❌ missing `sunstone_shard.glb` | Story collectible. Glowing amber crystal. |
| **Map Pieces** | `map_pieces` | ❌ missing `icon_map_piece.png` | ❌ missing (UI only) | Story collectible. Torn parchment. |

All icon PNGs belong in `res://assets/ui/icons/`. All 3D collectible GLBs belong in `res://assets/3d/collectibles/`.  
See `MISSING_3D_ASSETS.md` (Priority 7 & 9b) and `MISSING_UI_ASSETS.md` (Priority 3) for full specs.

---

## Outstanding Assets (Highest Priority)

These are the most impactful missing assets blocking visual polish:

| Asset | Path | Impact |
|-------|------|--------|
| 🗺 **Jungle Map Background** | `res://assets/backgrounds/bg_jungle_map.png` | **HIGH** — replaces procedural ColorRect map; 480×854 illustrated expedition map |
| 👟 **Sand Shoes Icon** | `res://assets/ui/upgrades/sand_shoes_icon.png` | **HIGH** — shown in shop popup and upgrade confirmation |
| 💎 **Gem 3D model** | `res://assets/3d/collectibles/gem.glb` | **HIGH** — current placeholder is a procedural sphere |
| ✦ **Sunstone Shard icon + model** | `res://assets/ui/icons/icon_sunstone_shard.png` | **HIGH** — story collectible, shown on level complete screen |
| 🗝 **Relic Key icon** | `res://assets/ui/icons/icon_relic_key.png` | **MEDIUM** — drops in ruins/temple levels |
| 🗺 **Map Piece icon** | `res://assets/ui/icons/icon_map_piece.png` | **MEDIUM** — required for home building Stage 1 |

---

## Upgrades

| ID | Name | Cost | Effect |
|----|------|------|--------|
| `sand_shoes` | Sand Shoes | 150 Coins | Unlocks Level 6. Required to walk and jump on sand. |

Upgrades are purchased from the **Upgrade Shop** (`scenes/menus/UpgradeShop.tscn`).

---

## Home Building

After Level 5, the player can build a home using collected resources:

| Stage | Name | Cost |
|-------|------|------|
| 1 | Buy Land | 250 Coins + 1 Map Piece |
| 2 | Foundation | 20 Bricks + 3 Tools |
| 3 | Walls | 30 Bricks + 10 Wood |
| 4 | Roof & Tiles | 5 Tiles + 5 Wood |
| 5 | Windows | 2 Windows |
| 6 | Complete Home | 2 Tools + 5 Wood |

---

## Adding a Level

Create `data/levels3d/level3d_007.json` following this schema:

```json
{
  "id": 7,
  "length": 35,
  "seed": 102,
  "name": "My Level",
  "turns": [
    { "row": 17, "dir": -1 }
  ],
  "obstacles": [
    { "type": "rock", "lane": 0, "row": 5 },
    { "type": "log",  "lane": 1, "row": 9 }
  ],
  "coins": [
    { "lane": 1, "row": 3 },
    { "gem": true, "lane": 1, "row": 34 }
  ]
}
```

Then bump `TOTAL_LEVELS` in `scripts/ui/LevelSelect.gd` and add an entry to `LEVEL_INFO`.

**Turn dirs:** `-1` = left, `1` = right. Obstacles within 3 tiles of a turn row are automatically suppressed.

---

## Save Data

Progress saved to `user://save_data.json`. Tracks: coins, stars per level, unlocked levels, resource inventory, owned upgrades, home building stage.  
Cloud sync is stubbed — wire Firebase/Supabase in `SaveManager.gd`.
