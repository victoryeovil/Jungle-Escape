# Jungle Escape: Lost Path

A **3D lane runner adventure game** for Android, built with Godot 4.6 + GDScript.

The player controls Kairo or Zuri through procedurally built jungle environments, collecting coins, avoiding obstacles, and making Temple-Run-style 90° path turns across 5 levels.

---

## Quick Start (Developer)

1. Install **Godot 4.6** from https://godotengine.org/download
2. Open Godot, click **Import**, and select `project.godot` in this folder.
3. Press **F5** to run from `scenes/game3d/Game3D.tscn`.
4. Desktop controls: **A/D** = lane switch, **W/Space** = jump, **S** = slide, **Left/Right arrow** = lane switch.
5. For Android export, see `PLAYSTORE_CHECKLIST.md`.

---

## Project Structure

```
jungle_escape/
├── project.godot                  — Godot 4.6 project config (480×854 portrait, mobile renderer)
├── data/
│   ├── levels/                    — 20 archived 2D level JSON files
│   └── levels3d/                  — 5 active 3D level JSON files (level3d_001 … level3d_005)
├── scenes/
│   ├── game3d/Game3D.tscn         — Main 3D gameplay scene ← START HERE
│   ├── menus/LevelSelect.tscn     — Level grid (5 levels, lock/unlock)
│   ├── main_menu/MainMenu.tscn    — Main menu
│   ├── splash/SplashScreen.tscn   — Splash + story intro routing
│   └── menus/                     — Settings, Shop, LoginPrompt, Profile, DailyChallenge
├── scripts/
│   ├── autoload/                  — GameManager, SaveManager, AudioManager, EventBus
│   ├── gameplay/                  — Player3D, InputHandler3D, LevelManager3D (2D archived)
│   └── ui/                        — Game3D, HUD3D, PauseMenu3D, LevelComplete3D, GameOver3D, LevelSelect
├── assets/
│   ├── 3d/characters/             — Kairo (kairo.glb) and Zuri (zuri.glb) with wrapper scenes
│   ├── fonts/                     — title_font.ttf (Cinzel) + body_font.ttf (Inter)
│   ├── ui/icons/                  — HUD icons (pause, restart, hint, coin, key, star)
│   ├── backgrounds/               — bg_main_menu.png, bg_gameplay.png
│   └── sounds/                    — SFX + music WAV starters
└── docs/
    ├── checkpoint.md              — Session-by-session handoff (current: Session 14)
    ├── CHANGELOG.md               — Version history
    ├── 3D-transformation.md       — Full 3D pivot task tracker
    ├── 3D-Gameplaybackgound.md    — Jungle world design spec
    ├── MISSING_3D_ASSETS.md       — Asset gap tracker
    └── PLAYSTORE_CHECKLIST.md     — Android release checklist
```

---

## Gameplay

- Player auto-runs forward through a 3-lane jungle path.
- **Swipe left / right** (or A/D keys) — change lanes or trigger a path turn.
- **Swipe up** (or W/Space) — jump over logs and obstacles.
- **Swipe down** (or S) — slide under low branches.
- **Path turns** — at corner tiles, a yellow "TURN LEFT / TURN RIGHT" prompt appears on screen; swipe any direction to execute the turn. A log-jam dam blocks going straight.
- Collect coins and gems. Hit an obstacle → Game Over. Reach the finish gate → Level Complete (1–3 stars).

## Characters

| ID | Name | Model | License |
|----|------|-------|---------|
| `explorer` | Kairo | Quaternius "Adventurer" (Poly Pizza) | CC0 |
| `jungle_girl` | Zuri | Quaternius "Animated Woman" (Poly Pizza) | CC0 |

Both characters are selectable from the Shop screen. Both are unlocked by default.

## Levels

| # | Name | Length | Turn | Difficulty |
|---|------|--------|------|------------|
| 1 | Jungle Trail | 26 tiles | — | Tutorial |
| 2 | Deep Forest | 33 tiles | Row 20, LEFT | Easy |
| 3 | River of Echoes | 40 tiles | Row 18, RIGHT | Medium |
| 4 | Ancient Ruins | 45 tiles | Row 22, LEFT | Hard |
| 5 | Temple Approach | 50 tiles | Row 25, RIGHT | Hardest |

## Adding a Level

Create `data/levels3d/level3d_006.json` following this schema:

```json
{
  "id": 6,
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

Then bump `TOTAL_LEVELS` in `scripts/ui/LevelSelect.gd`.

**Turn dirs:** `-1` = left (swipe left), `1` = right (swipe right). Obstacles within 3 tiles of a turn row are automatically suppressed by `LevelManager3D._spawn_obstacle()`.

## Save Data

Progress saved to `user://save_data.json`. Settings saved to `user://settings.json`.
Cloud sync is stubbed — wire Firebase/Supabase in `SaveManager.gd`.
