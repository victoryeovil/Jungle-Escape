# CHECKPOINT - Session 21

---

## Session 25 - Expedition Lives System

### Current Monetization / Retention Focus
The game now introduces Expedition Lives after Level 3 to support survival tension, retention, and future rewarded ads.

### Completed / In Progress
- Added saved Expedition Lives state with 5 maximum lives.
- Added natural regeneration at 1 life every 15 minutes.
- Added life loss on failed 3D runs after Level 3 only.
- Added a shared `SaveManager.can_start_level(level_id)` gate for post-tutorial gameplay.
- Added lives UI to HUD, main menu, and the level-select map.
- Added no-lives popup with coin, gem, full-refill, disabled rewarded-ad, and return-to-camp actions.
- Added Level 3 story text that introduces Expedition Lives.
- Added future rewarded-ad placeholder hooks without showing forced ads.

### Still Needed
- Replace procedural text lives labels with final heart/life icon assets.
- Replace procedural lives/refill/revive panels with final UI art.
- Add real rewarded-ad integration later, keeping it optional.
- Balance refill costs after playtesting.

### Next Recommended Step
Playtest Level 4+ failures and refill flow in the Godot editor, then tune costs and regen timing from real session data.

---

## Session 24 - Reference Map Art, Wildlife, and Build Landmarks

### Current UI Focus
The level selection screen now uses the supplied `bg_jungle_map.png` art as the visual base instead of relying on the procedural map painting.

### What Changed This Session

**LevelSelect.gd**
- Loads `assets/backgrounds/bg_jungle_map.png` through `_load_map_texture()` and uses it for the scrollable level-select background when available.
- Crops out the baked static header/footer from the source PNG before drawing it into scroll sections, so the live Godot header and bottom bar remain the only UI chrome.
- Adds moving wildlife directly on the map canvas: birds, elephants, rabbit, antelope, boar, and monkey.
- Adds a live home construction site that follows `SaveManager.get_home_stage()` from land purchase through complete home.
- Adds a temple reconstruction landmark that advances from ruins to restored temple based on completed level milestones.
- Keeps marker locks, stars, sand-shoe gating, preview panels, and gameplay launches responsive to save/game state.

### Validation
- Ran Godot 4.6.3 headless against `res://scenes/menus/LevelSelect.tscn`; the scene loaded without script errors.
- Ran `git diff --check`; no whitespace errors were reported.

---

## Session 23 - Level Select Map Graphics Refresh

### Current UI Focus
The level selection screen now keeps the live 20-level map, but its graphics match the current gameplay systems instead of reading like a generic procedural route.

### What Changed This Session

**LevelSelect.gd**
- Added scroll-aligned route art for tracking trails, chase streaks, water-slide channels, market dock planks, boat rivers, escape warnings, and the final baobab treasure landmark.
- Reworked the header to `JUNGLE MAP` with a compact 20-level subtitle.
- Added route-type badges beside level medallions for trail, build, track, chase, slide, guide, dock, boat, escape, and final routes.
- Updated the visible level-select names and preview text for the current 3D level identities, including Water Slide Trail, Market River Dock, Rapids Run, Boar Escape, and Treasure Beneath the Baobab.
- Kept the map procedural and SaveManager-driven so locked/unlocked states, stars, sand-shoe gating, previews, and gameplay launches remain responsive.

### Validation
- Ran Godot 4.6.3 headless against `res://scenes/menus/LevelSelect.tscn`; the scene loaded without script errors.
- Ran `git diff --check`; no whitespace errors were reported.

---

## Session 22 - Path Variety, Water Slide, Boat, and Survival Gameplay

### Current Gameplay Focus
The gameplay path system has been redesigned to remove monotony and add survival-adventure variety across the active 3D runner levels.

### What Changed This Session

**LevelManager3D.gd**
- Added `path_modules` parsing with smooth curves, S-curves, width changes, surfaces, modes, and junction metadata.
- Added per-segment path guide triggers so the player follows curved route direction instead of only hard 90-degree turns.
- Added visible module graphics for narrow trails, bridges, ruins corridors, sand ridges, water slides, boat rivers, tracking footprints, chase animals, escape warning signs, route signs, and junction arrows.
- Added 2-way and 3-way junction triggers that emit explicit route-choice state and spawn chosen-route reward trails.
- Added new obstacle visuals: thorn bushes, water rocks, floating logs, crocodile danger zones, whirlpools, crates, and broken planks.
- Added water token, fish token, and river relic pickups.

**Player3D.gd**
- Added path-guidance handling so movement direction, lane baseline, surface, and mode update from the active path segment.
- Added junction-state input: left/right/up choose visible routes only while inside a junction.
- Fixed old turn-zone behavior so a wrong lateral swipe no longer forces the hidden preset turn.
- Added mode speed changes and visible canoe / water-splash player attachments for boat and water-slide modes.

**Game3D.gd / HUD3D.gd**
- Connected path segment, junction, and chosen-route signals.
- Added camera distance/height changes for junction, boat, water slide, chase, and escape sections.
- Added escape camera shake.
- Added HUD mode prompts, junction route prompts, and "Trail Chosen" feedback.
- Added completion resource rewards for Levels 7-20.

**Level data**
- Updated `data/levels3d/level3d_001.json` through `level3d_020.json` with unique path identities, difficulty metadata, gameplay modes, and modular layouts.
- Added working 2-way junctions in levels such as 2, 7, 8, 10, 13, and 17.
- Added working 3-way junctions in levels such as 5, 11, 16, 18, and 20.
- Added water slide gameplay in Level 12 and mixed Level 20.
- Added boat gameplay in Level 15, Level 17, and mixed Level 20.
- Added animal chase in Levels 11, 16, and 20.
- Added animal escape/survival pressure in Level 19.

**Documentation**
- Updated `LEVEL_DESIGN.md` with the active 3D runner module system and Level 1-20 identities.
- Updated `MISSING_3D_ASSETS.md` with path module, water slide, boat, tracking, animal, and UI/effect asset needs.
- Updated `CHANGELOG.md` with the survival gameplay update.

### Validation
- Parsed all `data/levels3d/level3d_*.json` files and verified module row totals match level length, every level has at least two widths, and every level has a curve module.
- Ran `git diff --check`; no whitespace errors were reported.
- Ran Godot 4.6.3 headless against `res://scenes/game3d/Game3D.tscn`; the scene loaded without script errors.
- Full interactive route-choice testing still requires playing the levels in the Godot editor/game window.

### Next Recommended Steps
1. Run the project in Godot and test Level 2 or 7 for 2-way junction choice, Level 5 or 11 for 3-way junction choice, Level 12 for water slide, Level 17 for boat, and Level 19 for escape.
2. Replace procedural placeholders with final GLB modules, animal rigs, and HUD icons when art is ready.

---

## Session 21 — Explorer Shop Preview, Level Gates, and Gameplay Response

### Current Focus
Fix Choose Explorer interactions so Equip actually changes the selected character, buying requires a preview confirmation, and later characters unlock only after specific level milestones.

### What Changed This Session

**Constants.gd**
- Added `available_after_level` to every skin.
- Current gates:
  - Kairo and Zuri: available from start.
  - Monkey: after Level 3.
  - Robot Explorer: after Level 5.
  - Treasure Hunter: after Level 8.
  - Tribal Adventurer: after Level 10.
  - Golden Explorer: after Level 20 and still requires 60 stars.

**Shop.gd**
- Art-plate mode now uses full-row invisible hit targets instead of only the small button rectangle.
- Unlocked explorer rows equip immediately and refresh visible feedback.
- Locked explorer rows open a preview modal first.
- Preview modal shows explorer description, cost, level/star requirement, and an explicit Buy/Locked action.
- Purchases now validate level gates, star gates, and currency before unlocking.
- Successful purchase unlocks and equips the explorer.
- Art-plate mode now overlays an "Equipped" pill over the selected explorer and "Lvl N" pills over unavailable explorers.

**Player3D.gd**
- Kairo and Zuri still use their imported GLB scenes.
- Other selected skins no longer silently look like Kairo in gameplay.
- Monkey, Robot, Treasure Hunter, Tribal Adventurer, and Golden Explorer now use distinct procedural placeholder body/head colors and sizing until final 3D character GLBs are imported.

### Validation
- Ran `git diff --check`; no whitespace errors were reported.
- Godot runtime validation was not run because `godot`, `godot4`, and `Godot_v4.6.3-stable_win64_console.exe` are not available on PATH from this shell.

### Next Recommended Steps
1. Run Choose Explorer in Godot and test: Kairo/Zuri Equip, locked Monkey preview before Level 3, Monkey buy after Level 3, and gameplay model change after equipping.
2. Replace procedural placeholder variants with final GLBs for Monkey, Robot, Treasure, Tribal, and Golden when art assets are ready.

---

## Session 20 — Home and Choose Explorer Reference Art Plates

### Current Focus
Make the Home Building and Choose Explorer screens match the supplied full-screen reference images while preserving the existing build, skin, and navigation logic through transparent hit targets.

### What Changed This Session

**Imported screen art**
- Copied `C:\Users\dell\Downloads\home.png` to `assets/backgrounds/bg_home_building.png`.
- Copied `C:\Users\dell\Downloads\build.png` to `assets/backgrounds/bg_choose_explorer.png`.
- Both images are 941x1672, matching the portrait aspect used by the project.

**HomeBuilding.gd**
- Added `HOME_ART_PATH = "res://assets/backgrounds/bg_home_building.png"`.
- Added reference-art loading via `ResourceLoader` with raw `ImageTexture` fallback before Godot import metadata exists.
- When the art is present, the screen draws the full-screen image through `_draw()` and transparent hit targets over the visible back button, plus button, and six stage action areas.
- Existing procedural home-building UI remains as fallback when the PNG is missing.

**Shop.gd / Choose Explorer**
- Added `SHOP_ART_PATH = "res://assets/backgrounds/bg_choose_explorer.png"`.
- Added reference-art loading via `ResourceLoader` with raw `ImageTexture` fallback before Godot import metadata exists.
- When the art is present, existing scene controls are hidden, the image is drawn through `_draw()`, and transparent hit targets cover the visible back button, currency plus buttons, skin equip/buy buttons, and the bottom "Let's Explore" button.
- Existing procedural/list-based shop UI remains as fallback when the PNG is missing.

**Asset tracking**
- Updated `MISSING_UI_ASSETS.md` to list the two full-screen UI art plates as filled.
- Updated `ASSET_LICENSES.md` with user-provided rows for the home-building and choose-explorer art plates.
- Updated `CHANGELOG.md` with the screen art-plate implementation details.

### Validation
- Confirmed `bg_home_building.png` and `bg_choose_explorer.png` are 941x1672, `Format24bppRgb`.
- Godot runtime validation was not run because `godot`, `godot4`, and `Godot_v4.6.3-stable_win64_console.exe` are not available on PATH from this shell.

### Next Recommended Steps
1. Open the project in Godot so `.import` metadata is generated for the two new PNG files.
2. Run Home Building and Choose Explorer screens, then test back navigation, stage build tap, skin equip/buy taps, and "Let's Explore".
3. Confirm rights for the user-provided art plates before app-store submission if the images are not original or licensed for this project.

---

## Session 19 — Reference Jungle Map Art Plate

### Current Focus
Make the level-select/map page match the supplied jungle map reference image as closely as possible while preserving navigation and level selection.

### What Changed This Session

**Map art asset**
- Copied `C:\Users\dell\Downloads\map.png` to `assets/backgrounds/bg_jungle_map.png`.
- Source image dimensions are 941x1672, which closely matches the project's 480x854 portrait aspect ratio.

**LevelSelect.gd**
- Added `MAP_ART_PATH = "res://assets/backgrounds/bg_jungle_map.png"`.
- Added reference-art loading via `ResourceLoader` with raw `ImageTexture` fallback before Godot import metadata exists.
- When the art is present, `_draw()` now draws the full-screen map image and skips the procedural background, birds, labels, medallions, header, and bottom strip so the visible page matches the supplied design.
- Added transparent hit targets over the embedded back button, plus/upgrade-shop button, and six level markers.
- Kept the existing procedural map as fallback if the PNG is missing.

**Asset tracking**
- Updated `MISSING_UI_ASSETS.md` to mark `bg_jungle_map.png` present.
- Updated `ASSET_LICENSES.md` with a user-provided UI asset row for the map art.
- Updated `CHANGELOG.md` with the map art plate implementation details.

### Validation
- Confirmed `assets/backgrounds/bg_jungle_map.png` is 941x1672, `Format24bppRgb`.
- Ran `git diff --check`; no whitespace errors were reported.
- Godot runtime validation was not run because `godot`, `godot4`, and `Godot_v4.6.3-stable_win64_console.exe` are not available on PATH from this shell.

### Next Recommended Steps
1. Open the project in Godot so `bg_jungle_map.png.import` metadata is generated.
2. Run the game, open Jungle Map, and verify the back button, plus button, Level 1 tap, and any unlocked level taps.
3. If store submission is planned, confirm the user-provided map image rights before shipping.

---

## Session 18 — Generated Missing 3D Asset Fill Pass

### Current Focus
Create project-local 3D assets for the concrete missing GLB/resource targets tracked in `MISSING_3D_ASSETS.md`, following the same auditability expectation used for the imported Kairo and Zuri character assets.

### What Changed This Session

**Generated asset pipeline**
- Added `tools/generate_missing_3d_assets.py`.
- The script writes deterministic glTF 2.0 binary `.glb` files directly, using only local Python standard library code.
- Assets are original project-authored low-poly models, not third-party downloads.

**Generated 3D files**
- Created 54 new `.glb` files under:
  - `assets/3d/environment/`
  - `assets/3d/obstacles/`
  - `assets/3d/goals/`
  - `assets/3d/rewards/`
  - `assets/3d/collectibles/`
  - `assets/3d/wildlife/`
  - `assets/3d/upgrades/`
- Covered path pieces, grass/ferns/bushes/vines, palms, jungle trees, tree clusters, rocks, logs, spikes, mud, river gap kit, bridges, boulder, slide barrier, pressure plate, sand dune, gates, portal, altars, treasure chest, resource collectibles, Big 5 wildlife, supporting wildlife, and Sand Shoes prop.

**Generated materials and VFX**
- Added `assets/3d/materials/mossy_stone.tres`.
- Added `assets/3d/materials/water_stylized.tres`.
- Added `assets/3d/vfx/foliage_sway.gdshader`.
- Added `assets/3d/vfx/torch_flame.tscn`, `finish_glow.tscn`, `pickup_sparkle.tscn`, `dust_puff.tscn`, `hit_burst.tscn`, and `sand_trail.tscn`.

**Asset tracking updates**
- Updated `MISSING_3D_ASSETS.md` with `Generated (original)` status for the generated GLB/resource targets.
- Clarified that level dressing runtime is still procedural until `LevelManager3D.gd` is wired to instantiate the new GLBs.
- Updated `ASSET_LICENSES.md` and `assets/3d/ASSET_CREDITS.md` to document the generated assets as original project output.
- Marked the previously planned CC BY Poly Pizza elephant as not imported / not used, because the elephant GLB now exists as original generated output.

### Validation
- Ran `python tools\generate_missing_3d_assets.py`; it generated 54 GLB files successfully.
- Parsed all 56 project `.glb` files, including Kairo and Zuri, and confirmed valid `glTF` 2.0 binary headers, matching file lengths, JSON chunks, mesh arrays, and material arrays.
- Listed generated `.glb`, `.tres`, `.gdshader`, and `.tscn` files under `assets/3d`.
- Godot import validation was not run because no Godot executable is available from this shell.

### Next Recommended Steps
1. Open the project in Godot so `.import` metadata is generated for the new `.glb` assets.
2. Wire high-impact runtime replacements first: collectibles, bridge pieces, obstacle props, finish gates, then wildlife and dense foliage.
3. Add animation loops later for wildlife; current generated wildlife GLBs are static low-poly models.
4. Generate or source the remaining non-3D UI assets separately: resource icons, character thumbnails, home-stage images, and map background art.

---

## Session 17 — Map Visual Overhaul & Asset Sourcing

### What Changed This Session

**LevelSelect.gd** — Complete procedural visual rewrite:
- All background zones, tree silhouettes, path, river, camp, temple, fog drawn in `_draw()` with `draw_rect`, `draw_polygon`, `draw_polyline`, `draw_circle`, `draw_line`
- Sky gradient (blue → amber) across wildlands zone; zone-specific palette for ruins/jungle/river/temple/camp
- Triangular tree canopies using `draw_polygon` (4 tiers per tree: trunk rect + 3 triangle layers) — 20 left-side trees + 20 right-side trees + 3 accent trees
- Curved river (`draw_polyline` with 8 waypoints) + animated shimmer (alpha pulsed in `_process`)
- Wooden bridge with 6 planks, rails, support posts
- Campfire with triangle flame polygons, A-frame tent, expedition flag
- Temple gate with pillars, lintel, sun-symbol with 8 ray lines, concentric glow halos
- Sandy dune mounds, 4 acacia trees, elephant + warthog silhouettes in wildlands zone
- Fog overlay over locked Level 6 zone
- Stone edge markers along path every 3 waypoints
- Animated birds (2 Label nodes moving in `_process`)
- Stronger marker halos (2 glow rings + gold ring on next level)
- Markers redesigned: 90×90 circular, level name moved to separate label below

**ASSET_LICENSES.md** — created with confirmed CC0 download links:
- Kenney UI Pack Adventure: `kenney_ui-pack-adventure.zip`
- Kenney Game Icons: `kenney_game-icons.zip`
- Quaternius Nature MegaKit: quaternius.com link
- Still-needed table: bg_jungle_map.png, marker PNGs, resource icons, home stage images

**MISSING_UI_ASSETS.md** — updated with 7 priority tiers for map + UI assets

**Asset folder structure created:**
- `assets/backgrounds/`, `assets/ui/map/markers/`, `assets/ui/map/icons/`
- `assets/ui/map/landmarks/`, `assets/ui/map/effects/`

### Current State of the Map

The map now renders with:
- Gradient sky, 5 distinct visual zones
- Natural tree silhouettes (triangular canopies, no rectangles)
- Curved animated river with wooden bridge
- Campfire + tent camp landmark
- Temple gate with sun rays
- Animated birds, pulsing shimmer
- Fog over locked wildlands zone
- Clear circular markers with external name labels
- Parchment-style preview panel

### Still Needed for Production Polish

- Source and import `bg_jungle_map.png` (illustrated background replaces procedural drawing)
- Source Kenney CC0 marker PNGs and replace Button-based markers
- Add resource icon PNGs (currently using emoji fallback)
- Home building stage images (6 PNGs)

---

## Session 16 — Wildlands of Peace: Level 6, Sand Shoes, Story Screen, Map Upgrade

### What Changed This Session

#### Updated: `scripts/ui/LevelSelect.gd` (full rebuild)
- `TOTAL_LEVELS = 6`; Level 6 "Wildlands of Peace" added to `LEVEL_INFO`.
- 5 distinct zone background layers: warm sandy wildlands sky at top (`y 0–168`), ruins shadow band, jungle body, jungle entrance base.
- Wildlands overlay + savanna grass strip in top zone; fog overlay at very top.
- Elephant and warthog silhouettes in wildlands area; acacia-style trees.
- Level markers now use `corner_radius = 40` (fully circular stone badges).
- Level 6 marker: if Level 6 unlocked but sand shoes not owned, shows `👟` icon + "Sand Shoes" caption; opens sand shoes popup instead of level preview.
- Sand Shoes popup (`_build_sand_shoes_popup()`) — cost reminder, "Buy Sand Shoes" button with inline resource check, "Not enough resources" fallback text.
- `_on_buy_sand_shoes()` calls `SaveManager.buy_upgrade("sand_shoes")`; on success closes popup and opens Level 6 preview.
- Coins display in header bar.
- Zone watermark labels (JUNGLE TRAIL, DEEP FOREST, ANCIENT RUINS, TEMPLE APPROACH).
- River bridge updated (two posts, wider body).

#### Updated: `scripts/ui/LevelComplete3D.gd`
- `_on_next()` now routes to `GameManager.go_to_wildlands_unlock()` after Level 5 if sand shoes not yet owned.
- Otherwise continues to Level 6 or level select as before.

#### Created: `scripts/ui/WildlandsUnlock.gd`
- 3-panel story transition screen shown after Level 5.
- Procedural savanna background: sandy sky, midground, ground, horizon haze, acacia trees, elephant silhouette (body + 4 legs), warthog silhouette, sandy path strips.
- 18 animated sand-dust particles (float upward slowly, sine-wave drift).
- Panel text: "The Jungle Opens" → "Peaceful Coexistence" (Victoria Falls / Zimbabwe wildlife story) → "Sand Shoes — New Gear Required".
- Dot-style indicator showing current panel.
- Continue / Skip / Back to Map buttons; last panel becomes "Go to Jungle Map".

#### Created: `scenes/menus/WildlandsUnlock.tscn`
- Bare `Control` root + `WildlandsUnlock.gd` script (same pattern as `LevelSelect.tscn`).

#### Created: `MISSING_UI_ASSETS.md`
- Full manifest of all procedural ColorRect/Label fallbacks that need real PNG assets.
- Sections: map background, level markers, landmark icons, winding trail texture, preview panel, sand shoes popup, wildlands unlock screen, HUD icons, home building stages.
- Integration steps for swapping procedural rendering with TextureRect nodes.

#### Updated: `MISSING_3D_ASSETS.md`
- Priority 4: Level 6 "Wildlands of Peace" row added.
- Priority 8: Elephant, warthog, and weaver bird wildlife rows added (non-hazard, peaceful coexistence story).
- Priority 9b (new): Sand Shoes and 9 resource collectible models/icons.
- Priority 9c (new): Home building stage images (6 stages × 320×240 PNG).
- Priority 10: Level card count updated to 6.
- Integration checklist item 10 updated: all 6 level JSONs exist.

### Files Changed This Session
| File | Change |
|------|--------|
| `scripts/ui/LevelSelect.gd` | Full rebuild — Level 6, zones, circular markers, sand shoes gate |
| `scripts/ui/LevelComplete3D.gd` | Route to WildlandsUnlock after Level 5 |
| `scripts/ui/WildlandsUnlock.gd` | NEW — 3-panel story transition screen |
| `scenes/menus/WildlandsUnlock.tscn` | NEW — scene wrapper |
| `MISSING_UI_ASSETS.md` | NEW — full UI asset manifest |
| `MISSING_3D_ASSETS.md` | Added Level 6, wildlife, upgrade items, home stages |
| `CHANGELOG.md` | New entry: Wildlands of Peace system |
| `TASKS.md` | Phase 3D-Wildlands added; Phase 3D-Map items updated |
| `checkpoint.md` | This block |

### Still Needed (Next Session)
- Import `bg_jungle_map.png` and replace procedural zone ColorRects in `LevelSelect.gd`.
- Add slide-up tween animation for the level preview panel.
- Add ambient particles (birds, butterflies) on the map screen.
- Shop / upgrade screen where players can buy Sand Shoes from within the map.
- Home Building UI screen (6-stage build progress panel).
- Resource HUD during gameplay (show food/bricks/etc. collected mid-run).
- Level 6 visual dressing in `LevelManager3D` (sand dune variations, savanna edge props).
- Android export and device test.

---

# CHECKPOINT - Session 15

---

## Session 15 — Jungle Expedition Map Redesign

### Current Map Focus
The level select screen has been fully redesigned from a plain button grid into a story-driven jungle expedition map.

### What Changed This Session

#### Rewritten: `scripts/ui/LevelSelect.gd`
- Root `Control` builds the entire map procedurally in `_ready()`; no `.tscn` child nodes needed.
- `_draw()` renders the winding dirt trail via `draw_polyline` — shadow, outer edge, centre lane, highlight.
- Background layers: sky strip, jungle floor, ground base.
- Environmental details: left/right tree silhouettes (seeded RNG, deterministic), mid-scene accent trees, ruin stone fragments near Level 4 area, relic glow dot.
- River of Echoes section: blue water band, shimmer lines, bank edges, floating label.
- Fog zone at top: semi-transparent overlay + "Wildlands of Peace" label for the locked area.
- Start Camp landmark and Temple of the First Sun gate icon, both positioned at path endpoints.
- Level markers (Levels 1–5): stone-styled `Button` nodes at `NODE_POS` coordinates; show level name, chapter colour, star display. Current/active level pulses with a gold tween.
- Locked Level 6 teaser node in the fog zone.
- Header bar: title + back button.
- Objective strip at bottom.
- Level preview panel: appears on tapping any unlocked level; shows chapter, name, stars, story description, rewards, Start and Close buttons.
- Back button dismisses preview first, then returns to menu.

#### Rewritten: `scenes/menus/LevelSelect.tscn`
- Stripped to bare root `Control` + script (no Background `ColorRect`, no `VBox`, no `GridContainer`, no `BtnBack` scene nodes — all built in code).

### Files Changed This Session
| File | Change |
|------|--------|
| `scripts/ui/LevelSelect.gd` | Complete rewrite — jungle expedition map |
| `scenes/menus/LevelSelect.tscn` | Stripped to root Control + script only |
| `CHANGELOG.md` | New entry: Jungle Expedition Map Upgrade |
| `TASKS.md` | New Phase 3D Map tasks added |

### Still Needed (Map Polish)
- Create jungle map background PNG (`res://assets/backgrounds/bg_jungle_map.png`) to replace procedural ColorRects.
- Replace procedural tree shapes with actual silhouette sprites once art is available.
- Add slide-up tween animation for the level preview panel.
- Add fog/locked zone particle shimmer.
- Add map scroll (ScrollContainer) for when Level 6+ unlock and the path grows taller.
- Add Sand Shoes requirement marker for Level 6.
- Add Sunstone Shard and Map Piece reward icons to the preview panel.
- Add chapter progress indicator (Shards: 2/5, Map Pieces: 1/3).
- Add ambient life animations (birds, butterflies) on the map screen.
- Add chapter gate unlock animation when a new zone opens.

### Next Recommended Step
Open the project in Godot, navigate to LevelSelect, and visually verify:
1. Winding path renders correctly.
2. Level markers appear at the right positions along the path.
3. Tapping a level opens the preview panel.
4. Back button dismisses the preview, then returns to the main menu.
5. Level 6 teaser is visible in the fog zone but not tappable.

---

# CHECKPOINT - Session 14
**Date:** 2026-06-19  
**Engine:** Godot 4.6 | **Language:** GDScript | **Platform:** Android

---

## Session 14 — Turn System Bug Fixes (Character Rotation, Camera, Obstacles)

### What Changed This Session

#### Fixed: Character runs sideways after turn
- `Player3D._execute_turn()` now sets `rotation.y = atan2(-_move_fwd.x, -_move_fwd.z)` after rotating the heading vectors.
- The character node (and its GLB mesh child) now physically faces the new forward direction immediately when the turn executes.
- `Player3D.reset()` now sets `rotation.y = 0.0` to guarantee the model faces -Z on level start/restart.

#### Fixed: Camera faces backward after turn
- Root cause: `cam_pivot.rotation.y = atan2(to_player.x, -to_player.z)` — the sign on the X argument was wrong.
- For `rotation.y = θ`, the camera's world-forward is `(-sin θ, 0, -cos θ)`, so aligning it toward `to_player` requires `θ = atan2(-to_player.x, -to_player.z)`.
- The wrong formula was invisible on straight paths where `to_player.x = 0`; it only broke on turns.
- Fixed in `Game3D._process`: changed to `atan2(-to_player.x, -to_player.z)`.

#### Fixed: Obstacle clear zone too narrow after turn
- `_spawn_obstacle()` only cleared rows `[tr-3 … tr]` — nothing on the exit side.
- Row 22 lane-1 rock (level 2) sat 2 tiles after the row-20 turn corner and killed the player immediately.
- Extended clear zone to `[tr-3 … tr+3]` — 3 tiles of clear approach + 3 tiles of clear exit around every corner on every level.

#### Fixed: Camera too slow to reposition after turn
- Old lerp `delta * 4.0` took ~0.25 s to swing from behind to the new heading, letting the player run off-screen.
- `Game3D._process` now checks `(_cam_xz - target_xz).length_squared() > 6.0` (≈ 2.45 m). If true, `_cam_xz` snaps instantly; otherwise it lerps at `delta * 8.0`.

### Files Changed This Session
| File | Change |
|------|--------|
| `scripts/gameplay/Player3D.gd` | `_execute_turn` sets `rotation.y`; `reset` sets `rotation.y = 0.0` |
| `scripts/ui/Game3D.gd` | `atan2(-to_player.x, -to_player.z)` camera formula; instant snap on large heading change |
| `scripts/gameplay/LevelManager3D.gd` | Obstacle clear zone extended to `tr + 3` |

### Why These Fixes Are Global
All four fixes are inside shared functions (`_execute_turn`, `Game3D._process`, `_spawn_obstacle`). They apply automatically to every turn in every level — no per-level JSON changes needed.

### Known Limitations After Session 14
1. Turn system only tested with one turn per level. Multiple turns per level need a play-through on a custom JSON with two sequential turns.
2. No headless Godot validation run performed in this shell.
3. After a turn the collision capsule's local axes rotate with the node. The `CapsuleShape3D` is symmetric around Y so physics is unaffected, but this should be confirmed in-editor.

### Next Recommended Steps
1. Run Level 2 end-to-end: swipe left at the turn arrows → character should face -X, camera should be behind immediately, no obstacle for 3+ tiles after the corner.
2. Run Level 3 (right turn at row 18) and Level 4 (left turn at row 22) to confirm the global fixes work on both turn directions.
3. Add a short "TURN LEFT / TURN RIGHT" HUD flash label when entering the trigger zone.
4. Test multiple turns per level (add a second turn to a test JSON).

---

## Session 13 — 3D Gameplay Features: Trees, Surface Jump, Path Turns + Turn Bug Fixes

### What Changed This Session

#### New: Better trees
- **`_palm_tree()`** — rebuilt with taller trunk (3.4–5.0 m), 3 bark rings, 7–10 arching fronds using XZ offset (`cos/sin(angle_rad)*0.38`), optional coconuts.
- **`_jungle_tree()`** — rebuilt with tapered trunk (3.0–4.8 m), 2–3 buttress root flanges, 3–4 layered cone tiers (`CylinderMesh top_radius=0`), secondary branch with leaf cluster.

#### New: Surface-specific jump physics
- Player tracks `_current_surface: String` (dirt/mud/stone) by reading `"surface"` meta from the floor `StaticBody3D` after each `move_and_slide()`.
- `jump()` applies surface multipliers: mud ×0.70, sand ×0.82, stone ×1.06.
- All five level themes have a `"surface"` key in `_setup_theme()`.

#### New: Path turns (Temple Run style)
- **`LevelManager3D`** — added `_parse_turns(data)`, `_seg_pos/fwd/right` cursor dictionaries, `_turn_rows` dict.
- `_spawn_ground()` uses cursor data for all tile positions and heading rotation.
- Obstacles and coins use `_world_pos(row, lane)` helper; logs/branches get `heading_y` rotation.
- `_spawn_turn_zones(data)` spawns turn cues + dam barrier + Area3D trigger per turn row.
- **Turn data** added to `level3d_002.json` (row 20, left), `_003.json` (row 18, right), `_004.json` (row 22, left), `_005.json` (row 25, right).
- Signals: `turn_zone_entered(required_dir: int, corner_pos: Vector3)`, `turn_zone_exited`.
- **`Player3D`** — direction-based movement (`_move_fwd`/`_move_right` vectors), `_execute_turn()` rotates both by ±90°, lane projection works on any heading.
- **`Game3D`** — smooth camera heading follows `_move_fwd` via `atan2`, connects both turn signals.

#### New: Queued-turn system (fixes "no room to turn" bug)
- Trigger zone now spans **3 tiles of approach** (9 m, ~1.1 s at run speed) before the corner.
- Swiping in the correct direction **queues** the turn (`_queued_turn`) rather than executing immediately — prevents player veering off the path if they swipe early.
- In `_physics_process`, turn executes automatically when `dist_to_corner >= -1.5 m` (player is within 1.5 m of the corner).
- Two glowing arrows mark the turn: one 2 tiles out (early warning), one 1 tile out (corner reminder).
- Corner position now passed through the signal: `turn_zone_entered(dir, corner_pos)`.

#### Fixed: Void space bug (level 2, end of first stretch)
- Old wall at `TILE_Z * 1.55` = 4.65 m past tile centre left a 3.15 m void gap the player fell into.
- Replaced with a **log-jam dam** (`_spawn_dam_barrier`) placed exactly at the tile far edge (`TILE_Z * 0.5`).
- Dam has a 4.5 m tall collision box (y = -0.25 to 4.25), preventing both run-through and jump-over.
- Safety net added: `if position.y < -4.0: die()` in `_physics_process`.

#### Dam visual
- Mud base → 3 stacked horizontal log tiers (cylinders rotated 90°) with bark end caps → 4 debris logs → 5 rocks → mud fill strip → 3 moss patches.
- Single invisible `StaticBody3D` collision box (`{"obstacle": true}`) — `PATH_WIDTH + 1.4` wide, 4.5 m tall.

### Files Changed This Session
| File | Change |
|------|--------|
| `scripts/gameplay/LevelManager3D.gd` | Turn system, dam barrier, queued-turn signal, two-arrow cues |
| `scripts/gameplay/Player3D.gd` | Queued turn, corner-pos storage, fall-kill safety net |
| `data/levels3d/level3d_002.json` | Added turn at row 20 dir=-1 |
| `data/levels3d/level3d_003.json` | Added turn at row 18 dir=1 |
| `data/levels3d/level3d_004.json` | Added turn at row 22 dir=-1 |
| `data/levels3d/level3d_005.json` | Added turn at row 25 dir=1 |

### Known Limitations After Session 13
1. Turn system only supports one turn per level; multiple turns per level need `_turn_rows` iteration tested more carefully.
2. After the turn, path tiles and obstacles only exist for the post-turn segment — no visual continuity around the corner.
3. No headless Godot validation performed this session.
4. Camera smoothing after a turn takes ~0.25 s (lerp delta*4); may look slightly delayed on a fast device.

### Next Recommended Steps
1. Run Level 2 in Godot, approach row 20, swipe left when the first arrow appears — verify turn executes at corner.
2. Skip the swipe and run into the dam — verify "You hit an obstacle!" fires, not a void fall.
3. Add a short "TURN!" HUD label that flashes when entering the turn trigger zone.
4. Add multiple turns per level (requires testing `_parse_turns` cursor with two sequential turns).
5. Add a `"surface"` key to the finish gate ground so the player doesn't jump oddly on the last tile.

---

## Session 12 - Atmosphere and Completion Story Polish

### Current Focus
Continue the story/theme upgrade from Session 11 by making chapter atmosphere and level completion feedback feel more connected to the expedition.

### What Changed This Session

#### Updated: Per-level 3D atmosphere
- `Game3D.gd` now applies a level-specific `WorldEnvironment` and light profile before building the level.
- Level 1 keeps the bright jungle baseline.
- Level 2 uses deeper forest greens, heavier fog, and softer sun.
- Level 3 uses cooler river/mist colors.
- Level 4 uses darker ruin tones and denser ancient haze.
- Level 5 uses warmer gold/temple lighting.

#### Updated: Level completion story beats
- `Game3D.gd` now passes the active level id into `LevelComplete3D.show_result()`.
- `LevelComplete3D.gd` now adds a compact story label between coin rewards and buttons.
- Levels 1-5 each have a chapter-specific line referencing the lost path, Sunstone shards, ancient symbols, or the Temple of the First Sun.

#### Updated: Ancient Ruins relic glow
- `LevelManager3D.gd` now tracks Level 4 relic glyph meshes in `_relic_glows`.
- `_animate_relic_glows()` pulses glyph emission during gameplay so ruins feel less static.

### Validation
- Code-level inspection completed for the edited files.
- Confirmed required edited files exist: `Game3D.tscn`, `Game3D.gd`, `LevelComplete3D.gd`, `LevelManager3D.gd`, `CHANGELOG.md`, and `checkpoint.md`.
- Parsed `data/levels3d/level3d_001.json` through `level3d_005.json` with PowerShell `ConvertFrom-Json`; ids, names, lengths, obstacle counts, and coin counts loaded successfully.
- `Godot_v4.6.3-stable_win64_console.exe`, `godot`, and `godot4` are still not available in PATH from this shell.
- A broad Godot executable search across common user folders timed out before returning a result.

### Next Recommended Steps
1. Locate the Godot 4.6 console executable or add it to PATH, then run a headless scene smoke test.
2. Play Levels 1-5 and confirm atmosphere changes are visible without hurting obstacle readability.
3. Complete Levels 1-5 and verify the new story line fits inside the LevelComplete panel on a portrait viewport.
4. Open Shop and verify Session 11 campfire/particle background does not overlap the skin list.
5. If visual spacing is tight, move the LevelComplete story label into the panel scene as a fixed child and increase panel height slightly.

---

## Session 11 — Story Theme and Environment Upgrade

### Current Focus
Strengthen story presence, level-specific visual identity, and jungle atmosphere across gameplay and menu screens so the game feels like a real expedition rather than a generic runner.

### What Changed This Session

#### New: Story Intro Screen
- Created `scenes/menus/StoryIntro.tscn` + `scripts/ui/StoryIntro.gd`.
- Three-panel story sequence: "The Temple of the First Sun", "The Shattered Relic", "The Expedition Begins".
- Procedural animated dark jungle background (22 floating leaf/spore particles + pulsing golden relic glow overlay).
- "Continue ›" and "Begin Journey" navigation; "Skip Story" button on panels 1–2.
- On "Begin Journey" or skip: calls `SaveManager.mark_first_launch_done()` then navigates to MainMenu.

#### Updated: SplashScreen first-launch routing
- `SplashScreen.gd` now checks `SaveManager.is_first_launch()` after the splash timer.
- First-time players → `StoryIntro.tscn`; returning players → `MainMenu.tscn` (unchanged behavior for them).

#### Updated: LevelManager3D — theme system
- Added `_level_id: int` and `_theme: Dictionary` member variables.
- Added `_setup_theme(id: int)` method: configures per-level `dirt_dark`, `dirt_light`, `grass_dark`, `grass_light`, `stone`, and `moss` color entries.
  - Level 1: default bright jungle colors (unchanged)
  - Level 2: darker earthy browns, deep forest greens
  - Level 3: wet mud browns, teal-green grass, gray-green stone (river feel)
  - Level 4: dark stone path, very dark grass, aged stone (ruins feel)
  - Level 5: warm sandy dirt, dramatic stone, richer moss (temple feel)
- `_grass_color()` and `_spawn_ground()` now read from `_theme` instead of hardcoded constants.
- Added `_spawn_level_specific_dressing(data)` called from `build()` after `_spawn_wildlife()`:
  - Level 2: dense vine curtains + two monkey silhouettes in distant trees
  - Level 3: reed clusters + water-colored flat stones along path edges
  - Level 4: broken ancient pillars (with moss) + emissive glowing relic glyphs
  - Level 5: stone pillar corridor with torch on every other pillar pair

#### Updated: MainMenu story text
- `MainMenu.tscn` button labels changed: PLAY → "Begin Journey", Continue Offline → "Continue Expedition", Daily Challenge → "Daily Expedition", Shop → "Choose Explorer".
- Added `LblFlavor` label below subtitle: "The Temple of the First Sun awaits..." (14px, 70% opacity green).

#### Added: Levels 4 and 5 + LevelSelect update
- Created `data/levels3d/level3d_004.json` — "Ancient Ruins": 45 tiles, 28 obstacles (rocks/spikes/logs/branch), 26 coins + 3 gems, id=4. Uses ruins theme (dark stone path, broken pillars, glowing glyphs).
- Created `data/levels3d/level3d_005.json` — "Temple Approach": 50 tiles, 34 obstacles, 28 coins + 5 gems, id=5. Uses temple theme (warm stone path, pillar corridor, torches).
- Updated `LevelSelect.gd` `TOTAL_LEVELS` from 3 → 5.
- Renamed `level3d_002.json` name "Temple Ruins" → "Deep Forest" and `level3d_003.json` "Ancient Depths" → "River of Echoes" to match `build.md` chapter identity.

#### Added: Path variation
- Added `_spawn_path_variation(data)` to `LevelManager3D.gd`, called from `build()`.
- Every 8 rows: leaning root-arch landmarks on both path edges (curved trunks + hanging vines).
- Every 5 rows (55% chance): stone edge markers on path sides (give the trail a bordered, explored-trail feel).
- Every 10 rows (60% chance): ground-level root crossing strip across the mid-path.

#### Updated: SplashScreen atmosphere
- `SplashScreen.gd` adds 16 drifting leaf/spore particles and a pulsing golden relic glow overlay in `_ready()`.
- Background darkened to `Color(0.04, 0.11, 0.04)` to match the jungle intro mood.
- Particle and glow animation runs via `_process()` during the splash wait.

#### Updated: Shop jungle camp background
- `Shop.gd` now calls `_add_jungle_background()` in `_ready()`.
- Adds a `JungleLayers` Control node (inserted at z-order 1, after Background) with:
  - Dark mid-layer ColorRect
  - 6 tree silhouette ColorRects
  - Campfire root with flickering orange glow
  - 18 animated particles: 7 fireflies (pulse alpha), 11 leaf dots (drift upward)
- `_process()` drives campfire glow sine-pulse and particle drift animation.
- All existing Shop functionality unchanged.

### Validation
- All new files created: `StoryIntro.gd`, `StoryIntro.tscn`.
- Existing files edited: `SplashScreen.gd`, `LevelManager3D.gd`, `MainMenu.tscn`, `Shop.gd`.
- Docs updated: `CHANGELOG.md`, `checkpoint.md`.
- No existing method signatures changed; all additions are additive.

### Navigation Flow (Updated)
```
SplashScreen → StoryIntro (first launch) → MainMenu
SplashScreen → MainMenu (returning player — unchanged)
MainMenu: "Begin Journey" / "Continue Expedition" → LevelSelect → Game3D
MainMenu: "Choose Explorer" → Shop (now with jungle camp background)
```

### Known Limitations After Session 11
1. StoryIntro is a purely procedural GDScript scene — no Godot editor preview; relies on `UIStyle.apply()` for fonts.
2. Level 2 monkey silhouettes and Level 3 reed clusters are visible dressing only, no gameplay effect.
3. Level 4 glyph emission does not animate (static emission); animated glow can be added via `_torch_flames` pattern in a future pass.
4. LblFlavor in MainMenu.tscn may need layout adjustment if the button VBox is repositioned.
5. No headless validation run performed in this shell.

### Next Recommended Steps
1. Open Godot editor, press F5 from SplashScreen — first run should show story intro → MainMenu.
2. Play Levels 1–5 in sequence; confirm each looks and feels visually different (path color, dressing, level-specific elements).
3. Check path variation: root arches and stone edge markers should appear along all levels without blocking lanes.
4. Open Shop and verify jungle campfire background animates without UI overlap with the skin list.
5. Consider adding `WorldEnvironment` fog color or `DirectionalLight3D` color per-level for even stronger atmosphere.
6. Add dedicated Levels 4 and 5 LevelComplete messages ("A strange symbol glows on the temple stone...", "The Temple of the First Sun is near...") to `LevelComplete3D.gd`.

---

## Session 10 - InputHandler3D Class-Loading Fix + Main Menu Button Fix

---

## Session 10 - InputHandler3D Class-Loading Fix + Main Menu Button Fix

### What changed

#### Fixed the recurring InputHandler3D parser error
- Root cause: `var player: Player3D = null` created a parse-time dependency on `Player3D`. GDScript registers classes alphabetically; "I" before "P" meant `Player3D` was not yet registered when `InputHandler3D` compiled. Godot reported `Line 7: Could not parse global class "InputHandler3D"` and `Line 27: Expected indented block` (cascading error).
- Fix: changed `var player: Player3D = null` → `var player = null` (untyped). Runtime duck typing handles all method calls correctly; the `player == null` guard makes it safe.

#### Fixed Main Menu buttons not responding to clicks
- Root cause: `MainMenu.gd` had a `_input()` override that called `set_input_as_handled()` when `btn_play.is_hovered()` returned true. Because `_input()` runs before the GUI hover state updates, hovering Play then quickly clicking Settings (or any other button) caused `is_hovered()` to return a stale true, consuming the click before any button's `_gui_input` fired.
- Fix: removed `_input()`, `_position_hits_play_button()`, and `_log_pointer_event()` entirely from `MainMenu.gd`. All six buttons now use only the standard `pressed` signal. The original `has_focus()` bug that required the `_input()` workaround was fixed in Session 7.

---

## Session 9 - 3D Jungle Environment and Parser Fix

### What changed

#### Fixed the reported parser error
- Replaced `scripts/gameplay/InputHandler3D.gd` with a clean swipe/keyboard handler.
- Removed the empty `InputEventScreenDrag` branch that caused:
  - `Parser Error: Could not parse global class "InputHandler3D" from "res://scripts/gameplay/InputHandler3D.gd"`
- Simplified swipe completion so touch-down starts tracking and touch-up resolves the swipe direction in one path.

#### Restored Main Menu Play navigation
- Reworked `scripts/ui/MainMenu.gd` so the menu explicitly unpauses the tree on load.
- Routed Play through `GameManager.go_to_level_select()` instead of duplicating scene-change logic in the menu.
- Hardened Play handling through `gui_input`, `button_down`, `pressed`, and root hit-test paths so a real click/tap has multiple valid routes into navigation.

#### Built a stronger Level 1 jungle world
- Reworked `scripts/gameplay/LevelManager3D.gd` from a flat green strip with basic boxes into a procedural low-poly jungle runner scene.
- Level 1 now builds organized child groups:
  - `Terrain`
  - `JunglePath`
  - `Trees`
  - `GrassAndPlants`
  - `RocksAndLogs`
  - `Obstacles`
  - `Collectibles`
  - `Animals`
  - `Ruins`
  - `FinishGate`
- Added dirt path segments, grass side strips, pebbles, roots, ferns, bushes, vines, palms, broad jungle trees, mossy ruin fragments, side logs, and clustered rocks.
- Added procedural butterflies and parrot-style bird flyovers as decorative Level 1 wildlife.
- Added rotating/bobbing procedural coins and gems.
- Rebuilt the finish into a mossy stone temple gate with torches and a portal glow.

#### Improved obstacle language
- Added a low-branch slide obstacle type.
- Updated `data/levels3d/level3d_001.json` so row 13 uses `branch` instead of a generic spike.
- Updated `scripts/gameplay/Player3D.gd` so sliding temporarily lowers the player collision capsule, allowing the low branch to be cleared by sliding.

#### Asset tracking
- Added root `ASSET_LICENSES.md`.
- Updated `MISSING_3D_ASSETS.md` to mark Level 1 procedural jungle content as present and tested while keeping final GLB production assets tracked as still missing.
- Updated `CHANGELOG.md` with the 3D jungle environment entry.

### Validation

- `data/levels3d/level3d_001.json` parsed successfully.
- Static checks passed for bracket balance and nonempty GDScript blocks in the changed gameplay scripts.
- Godot 4.6.3 headless scene load passed:
  - Command: `Godot_v4.6.3-stable_win64_console.exe --headless --path . --scene res://scenes/game3d/Game3D.tscn --quit-after 3`
  - Result: no `InputHandler3D` parser error and no `LevelManager3D` compile error.
- Godot 4.6.3 headless button-flow test passed:
  - Main Menu Play signal opened `res://scenes/menus/LevelSelect.tscn`.
  - Level 1 button opened `res://scenes/game3d/Game3D.tscn`.

### Known limitations after Session 9

1. Level 1 environment is still procedural primitive geometry, not final imported GLB environment art.
2. Dedicated Kairo/Zuri jump and land clips are still missing.
3. Wildlife is decorative procedural mesh animation; final parrot/butterfly GLBs are still needed.
4. No Android device run was performed in this shell.
5. Godot reported the same shutdown leak/resource warning on headless quit; the scene still loaded successfully.

### Next recommended step

Open `scenes/game3d/Game3D.tscn` in the Godot editor and visually check Level 1 camera framing, obstacle readability, slide branch clearance, character scale, and coin pickup feel on a portrait viewport.

---

## Session 8 - 3D Character Import

### What changed

#### Imported playable 3D characters

| Character | Source model | Local files | License |
|-----------|--------------|-------------|---------|
| Kairo | Quaternius "Adventurer" from Poly Pizza | `assets/3d/characters/kairo/kairo.glb`, `assets/3d/characters/kairo/Kairo.tscn` | CC0 1.0 / Public Domain |
| Zuri | Quaternius "Animated Woman" from Poly Pizza | `assets/3d/characters/zuri/zuri.glb`, `assets/3d/characters/zuri/Zuri.tscn` | CC0 1.0 / Public Domain |

Source pages:
- Kairo: `https://poly.pizza/m/5EGWBMpuXq`
- Zuri: `https://poly.pizza/m/nIItLV9nxS`

#### New asset ledger
- **`assets/3d/ASSET_CREDITS.md`** - Added source URLs, author, license, download date, and local usage for the imported 3D characters and preview images.

#### Runtime player model wiring
- **`Player3D.gd`** now loads the selected 3D character scene at runtime:
  - `explorer` -> `res://assets/3d/characters/kairo/Kairo.tscn`
  - `jungle_girl` -> `res://assets/3d/characters/zuri/Zuri.tscn`
- The old capsule/head placeholder nodes remain in `Game3D.tscn` as a fallback, but are hidden when a real character scene loads.
- `Constants.gd` now labels the two default skins as **Kairo** and **Zuri**.
- `SaveManager.gd` now keeps both `explorer` and `jungle_girl` unlocked by default, including for existing saves.

#### Animation wiring
- Both imported GLBs include 24 animations.
- `Player3D.gd` now calls these available imported clips:
  - Run: `CharacterArmature|Run`
  - Strafe left: `CharacterArmature|Run_Left`
  - Strafe right: `CharacterArmature|Run_Right`
  - Slide: `CharacterArmature|Roll`
  - Collect: `CharacterArmature|Interact`
  - Hit: `CharacterArmature|HitRecieve`
  - Victory: `CharacterArmature|Wave`
  - Defeat: `CharacterArmature|Death`
- `LevelManager3D.gd` now calls `Player3D.play_collect()` on coin/gem pickup.
- `Game3D.gd` now calls `Player3D.play_victory()` when the finish gate is reached.

### Validation

- Both GLB files were checked as valid GLB 2.0 files.
- Both GLBs include all animation names currently referenced by `Player3D.gd`.
- Godot import metadata exists:
  - `assets/3d/characters/kairo/kairo.glb.import`
  - `assets/3d/characters/zuri/zuri.glb.import`
- Godot imported scene cache exists:
  - `.godot/imported/kairo.glb-12fb58dea859db7ea9760dab01ddfd95.scn`
  - `.godot/imported/zuri.glb-0bd01636021ad15a77dc39fc4e23b301.scn`
- Basic file/reference checks passed for the new character paths.

### Known limitations after Session 8

1. **Dedicated jump/land clips are still missing** - the physics jump works, but these two free character GLBs do not include exact jump and land clips. Use Quaternius Universal Animation Library or custom Blender clips later.
2. **No live Godot scene test was run from this shell** - `godot` is not available on PATH. Open the project in Godot and run `Game3D.tscn` to visually confirm scale/orientation on screen.
3. **Environment art is now procedurally dressed but not final** - Level 1 has a fuller low-poly jungle pass with path, foliage, obstacles, coins, wildlife, ruins, and gate; final imported GLB environment art is still needed before store screenshots.

### Next session priorities

1. Open `scenes/game3d/Game3D.tscn` in Godot and verify Kairo scale, orientation, animation playback, and camera framing.
2. Equip Zuri in the Shop and verify she loads correctly in `Game3D`.
3. Source or import jump/land clips and wire them into `Player3D.gd`.
4. Replace Level 1 environment placeholders first: dirt path, trees, log, rock, coin, and finish gate.
5. Add Android/device visual test once the character and Level 1 art pass are stable.

---

## Session 7 — 3D Pivot (Lane Runner)

### What changed

#### Critical button fix
- **`MainMenu.gd`** — Removed `btn_play.has_focus()` from `_position_hits_play_button()`.
  Godot 4 auto-focuses the first button on scene load (BtnPlay). With that check present,
  every click anywhere called `get_viewport().set_input_as_handled()` and consumed the event
  before any button could show a press state or fire its signal. Removing the check restores
  all button visual feedback and navigation.

#### New 3D scripts (9 files)

| Script | Extends | Purpose |
|--------|---------|---------|
| `scripts/gameplay/Player3D.gd` | `CharacterBody3D` | 3-lane runner: auto-forward, X-lerp lane snap, jump, slide, obstacle death via `get_slide_collision()` |
| `scripts/gameplay/InputHandler3D.gd` | `Node` | Touch swipe (min 40px / max 0.5s) + keyboard fallback (A/D/W/S/Space) |
| `scripts/gameplay/LevelManager3D.gd` | `Node3D` | Builds full level from JSON — ground, trees, 4 obstacle types, coins/gems with `Area3D`, finish gate |
| `scripts/ui/Game3D.gd` | `Node3D` | Scene controller — loads JSON, wires signals, win/lose, star rating, saves progress |
| `scripts/ui/HUD3D.gd` | `CanvasLayer` | Pause button + level label + live coin counter |
| `scripts/ui/PauseMenu3D.gd` | `Control` | PROCESS_WHEN_PAUSED overlay — Resume, Restart, Main Menu |
| `scripts/ui/LevelComplete3D.gd` | `Control` | Win overlay — stars + coins, Next/Replay/Map |
| `scripts/ui/GameOver3D.gd` | `Control` | Fail overlay — Retry/Map |
| `scripts/ui/LevelSelect.gd` | `Control` | Level grid with `SaveManager`-driven lock/unlock + star display |

#### New 3D scenes (2 files)

| Scene | Key nodes |
|-------|-----------|
| `scenes/game3d/Game3D.tscn` | `WorldEnvironment` (blue sky + fog), 2× `DirectionalLight3D`, `CharacterBody3D` player (capsule placeholder), `CamPivot/Camera3D` (third-person), `LevelManager`, `InputHandler`, HUD CanvasLayer, PauseMenu/LevelComplete/GameOver overlays |
| `scenes/menus/LevelSelect.tscn` | 3-column `GridContainer`, dynamic lock/unlock buttons, Back → Main Menu |

#### Level data (3 JSON files in `data/levels3d/`)

| File | Name | Length | Obstacles | Coins | Gems |
|------|------|--------|-----------|-------|------|
| `level3d_001.json` | Jungle Trail | 25 tiles | 7 | 16 | 1 |
| `level3d_002.json` | Temple Ruins | 33 tiles | 13 | 22 | 2 |
| `level3d_003.json` | Ancient Depths | 40 tiles | 20 | 23 | 2 |

Obstacle types implemented: `log` (full-lane, jump to clear), `rock` (single-lane, dodge), `spike` (low, dodge), `mud` (visual stub).

#### Updated existing files
- **`GameManager.gd`** — Added `go_to_gameplay_3d(level_id)` and `go_to_level_select()`; `restart_level()` now calls `go_to_gameplay_3d`.
- **`MainMenu.gd`** — Play and Continue Offline both navigate to `LevelSelect.tscn` (was `LevelMap.tscn`).
- **`project.godot`** — Description updated; renderer was already `mobile` (correct for 3D).
- **`3D-transformation.md`** — All implemented tasks marked `[x]`, deferred items `[~]`.
- **`MISSING_3D_ASSETS.md`** — Created; lists every placeholder with integration instructions.

### Architecture notes for this session

- **Obstacle death mechanism:** `StaticBody3D` nodes inside obstacles are tagged `body.set_meta("obstacle", true)`. After each `move_and_slide()` in `Player3D`, `get_slide_collision()` checks every collider for this meta — matching means instant `die()`.
- **Coin pickup:** Each coin is a `Node3D` with a child `Area3D` (SphereShape3D r=0.35). `body_entered` calls `GameManager.collect_coin()` / `collect_gem()` and `queue_free()`s the coin.
- **Finish gate:** `Area3D` (BoxShape3D) at end of level. `body_entered` → `finish_reached` signal → `Game3D` freezes player, calls `SaveManager.complete_level()`, shows `LevelComplete3D` overlay.
- **Camera:** `CamPivot` node at fixed Y=2.5, Z offset +4.5 from player. `Game3D._process` updates only `cam_pivot.global_position.z = player.global_position.z + 4.5`.
- **Adding level 4+:** Drop `data/levels3d/level3d_004.json` with the same schema. Increase `TOTAL_LEVELS` in `LevelSelect.gd` to `4`.

### Full navigation flow (3D game)

```
SplashScreen → MainMenu
MainMenu (Play / Continue Offline) → LevelSelect
LevelSelect (Level N) → Game3D (loads level3d_00N.json)
Game3D (finish gate) → LevelComplete overlay → Next → Game3D (N+1) OR Map → LevelSelect
Game3D (obstacle hit) → GameOver overlay → Retry → Game3D (same) OR Map → LevelSelect
Game3D (pause) → PauseMenu overlay → Resume / Restart / Main Menu
MainMenu (Settings / Shop / Login / Daily Challenge) → existing menus (unchanged)
```

### What is NOT done yet (next session priorities)

1. **Real 3D player model + animations** — capsule placeholder used; wire `AnimationPlayer` states in `Player3D.gd` when `.glb` model arrives. See `MISSING_3D_ASSETS.md`.
2. **Final environment meshes** — Level 1 now uses richer procedural primitive geometry; replace with imported GLB kits through `LevelManager3D` when final art is sourced.
3. **Coin polish** — procedural coins now rotate and bob; replace with final coin/gem scenes and pickup VFX later.
4. **River gap collision** - `_remove_ground_at()` now removes the path tile and adds a visual water gap; add invisible fail zones/bridge logic for Level 3.
5. **Distance / score counter** in HUD.
6. **On-screen swipe buttons** for players who find touch swipe unreliable.
7. **Android export** — configure export preset + keystore; test on device.
8. **Levels 4–10** — extend `data/levels3d/` and bump `TOTAL_LEVELS` in `LevelSelect.gd`.

---

## Session 6 — Full Button Navigation Wiring

### What changed

- **MainMenu.gd + MainMenu.tscn** — Added three missing buttons: Shop, Continue Offline, Daily Challenge.
  - `BtnShop` → `res://scenes/menus/Shop.tscn`
  - `BtnContinueOffline` → `res://scenes/level_map/LevelMap.tscn`
  - `BtnDailyChallenge` → `res://scenes/menus/DailyChallenge.tscn`
  - VBox expanded: `offset_top = -180, offset_bottom = 220` (400 px) to fit all 6 buttons without clipping.
  - Background `ColorRect` explicitly set to `mouse_filter = 2` (MOUSE_FILTER_IGNORE) to prevent it eating clicks.
  - Restored the full Session 5 navigation logic: `button_down`, `_navigation_pending`, `call_deferred("_open_level_map")`, root-level touch/mouse hit-testing, and `[NAV]` diagnostic logs.

- **DailyChallenge.tscn + DailyChallenge.gd** — Created new placeholder scene with title, "Coming Soon!" text, and a working Back button that calls `GameManager.go_to_menu()`.

- **GameplayScreen.tscn** — Added `process_mode = 2` (PROCESS_MODE_WHEN_PAUSED) to the PauseMenu node.
  - Critical bug fix: Godot 4.6 blocks `_gui_input` (button presses) on nodes whose `process_mode` is PAUSABLE when `get_tree().paused = true`. Without this fix, every button in the PauseMenu was dead after the pause button was pressed.

- **PauseMenu.gd** — In `_on_settings()`, added `get_tree().paused = false` before `change_scene_to_file`.
  - Without this, Settings would load with the tree still paused, making its buttons equally dead.

- **EventBus.gd** — Added `@warning_ignore("unused_signal")` before every signal declaration to suppress GDScript warnings. The event-bus pattern means signals are emitted/connected from other files, not from EventBus itself.

- **GameManager.gd** — Renamed `level_id` → `_level_id` in `_on_level_completed()` to fix the unused-parameter warning.

### Full button connection audit (Godot 4.6)

| Screen | Buttons | Status |
|--------|---------|--------|
| MainMenu | Play, Settings, Login/Profile, Shop, Continue Offline, Daily Challenge | ✅ All connected |
| LevelMap | Back, Level 1–20 (dynamic) | ✅ All connected |
| Settings | Back, Reset | ✅ All connected |
| Shop | Back, Buy Hints, skin equip/buy (dynamic) | ✅ All connected |
| LoginPrompt | Google, Email, Maybe Later | ✅ All connected |
| Profile | Back, Log Out | ✅ All connected |
| DailyChallenge | Back | ✅ All connected |
| HUD | Pause, Hint, Restart | ✅ All connected |
| PauseMenu | Resume, Restart, Settings, Quit | ✅ Fixed (process_mode=WHEN_PAUSED) |
| LevelComplete | Next, Replay, Map, Share, Challenge Friend | ✅ All connected |
| GameOver | Retry, Map | ✅ All connected |

### @onready path audit
All `@onready` node paths verified against scene trees — zero mismatches.

### Known open issue
- `UIStyle.gd` uses `preload()` for all 6 icon PNGs and 2 font TTFs. These assets exist on disk (confirmed via `ls`). Do NOT change preload to lazy-load — the assets are real.

---

## Session 5 — Missing UI Asset Completion

### What changed
- **Generated only missing assets** from the asset update instruction:
  - `assets/ui/icons/icon_pause.png`
  - `assets/ui/icons/icon_restart.png`
  - `assets/ui/icons/icon_hint.png`
  - `assets/ui/icons/icon_coin.png`
  - `assets/ui/icons/icon_key.png`
  - `assets/ui/icons/icon_star.png`
  - `assets/backgrounds/bg_gameplay.png`
  - `assets/backgrounds/bg_main_menu.png`
- **Added fonts**:
  - `assets/fonts/title_font.ttf` (Cinzel)
  - `assets/fonts/body_font.ttf` (Inter)
  - `assets/fonts/FONT_LICENSES.md`
- **Added `UIStyle.gd`** to centralize UI font application and HUD icon sizing.
- **Integrated assets**:
  - HUD pause/hint/restart buttons now use icons.
  - HUD and level-map coin/key/star counters use icon assets.
  - Main menu uses `bg_main_menu.png`.
  - Gameplay uses `bg_gameplay.png` behind the grid.
  - Menus, HUD, level map, settings, shop, login prompt, pause, level complete, and game-over UI apply the new fonts.
- **Updated docs**: `CHANGELOG.md`, `TASKS.md`, `README.md`, `MISSING_ASSETS.md`, and this checkpoint.

### Validation
- New PNG validation: 6 icons at 128×128 with transparent corners; 2 backgrounds at 720×1280.
- Font validation: `title_font.ttf` and `body_font.ttf` have valid TTF headers.
- Static `res://` reference scan: 0 missing references.
- Lightweight GDScript scan: 0 issues in changed scripts.
- Godot 4.6.3 headless project and MainMenu scene load checks passed.

### Follow-up fix
- Fixed the Main Menu Play button not navigating after the UI asset pass:
  - `UIStyle._apply_label()` now uses `String(label.name).to_lower()` instead of calling `to_lower()` directly on `StringName`.
  - Runtime-created background `TextureRect` nodes and counter icons now use `Control.MOUSE_FILTER_IGNORE`.
  - `MainMenu.gd` now also listens to `BtnPlay.button_down`, guards duplicate clicks, and defers a direct scene change to `res://scenes/level_map/LevelMap.tscn`.
  - Added `[NAV]` diagnostic logs in `SplashScreen.gd`, `MainMenu.gd`, `GameManager.gd`, and `LevelMap.gd`.
  - Added root-level MainMenu input diagnostics and Play fallback hit testing using raw event position, viewport mouse position, scaled position, hovered state, and focus state.
- Validation after the fix:
  - Static `res://` reference scan: 0 missing references.
  - Lightweight GDScript scan for changed scripts: 0 issues.
  - Godot 4.6.3 headless simulated Play click prints `change_scene_to_file returned 0`, `LevelMap ready`, and `current_scene=res://scenes/level_map/LevelMap.tscn`.

---

## Session 4 — Bug Fixes

### What changed
- **KI-008 FIXED** — Replaced `get_tree().back()` (Godot 4 crash) in both Settings.gd and Shop.gd:
  - `Settings._on_back()` now checks `GameManager.state`: if PAUSED (came from PauseMenu), calls `GameManager.restart_level()`; otherwise calls `GameManager.go_to_menu()`.
  - `Shop._on_back()` now calls `GameManager.go_to_menu()`.
  - Also emits `EventBus.settings_changed` from Settings back so AudioManager applies the new volume immediately.
- **KI-010 FIXED** — `Grid._parse_switch_gates()` added. Reads `"switch_gates": {"A": [[col,row], ...]}` from level JSON and populates `_switch_gates` dictionary with `Vector2i` gate positions. Called at end of `_build_grid()`.
- **Profile.tscn + Profile.gd CREATED** — `scenes/menus/Profile.tscn` now exists (was crashing when user logged in and pressed "Profile" button in MainMenu). Shows player name, coins, gems, stars, levels completed. Has "Log Out" button (clears login state) and "Back" button.

---

## Session 3 — Asset Wiring Summary

### What changed
- **GameplayScreen.gd** rewritten to build a proper background at runtime:
  - Layer 0: `floor.png` tiled via `TextureRect.STRETCH_TILE` across the full 480×854 viewport (no more plain green ColorRect).
  - Layer 1: semi-transparent dark panel (`GridFrame`) placed just behind the grid to frame the level clearly on the textured background. Built after `level_ready` fires so grid dimensions are known.
- **Confirmed** all 13 active tile scripts have `texture_path` set pointing to existing PNGs.
- **Confirmed** `Grid._spawn_floor()` loads `floor.png` / `wall.png` / `river.png` with ColorRect fallback — all three textures exist on disk.
- **Confirmed** `Player._setup_visual()` loads `explorer.png` (and all 6 other skin PNGs exist).
- **Confirmed** `AudioManager._load_sounds()` loads all 23 WAV files at runtime (no more preload crash).
- **Created** `MISSING_ASSETS.md` — full catalogue of every absent asset with sizes, locations, and free sources.

### Visual state of Level 1 now
- Full-screen jungle floor texture as background ✅
- Wall tiles: `wall.png` sprite ✅
- Floor tiles: `floor.png` sprite ✅
- Coin tile: `coin.png` sprite ✅
- Exit tile: `exit.png` sprite + pulsing tween ✅
- Player: `explorer.png` sprite ✅
- HUD buttons: pause/hint/restart icons wired ✅
- Font: `title_font.ttf` and `body_font.ttf` wired through `UIStyle.gd` ✅

---

## What Was Built in Sessions 1–2

A complete Godot 4 project skeleton for **Jungle Escape: Lost Path**. The project covers Phases 1 and 2 of the 6-phase plan.

### Files Created

| Area | Files |
|------|-------|
| Project config | `project.godot` |
| Autoloads | `GameManager.gd`, `SaveManager.gd`, `AudioManager.gd`, `EventBus.gd` |
| Data | `Constants.gd`, `LevelLoader.gd` |
| Gameplay | `Grid.gd`, `Player.gd`, `InputHandler.gd` |
| Tile scripts (14) | `BaseTile`, `CoinTile`, `GemTile`, `FruitTile`, `KeyTile`, `GateTile`, `ExitTile`, `SpikeTile`, `SnakeTile`, `RiverTile`, `BridgeTile`, `MudTile`, `VineTile`, `SwitchTile` |
| UI scripts (11) | `SplashScreen`, `MainMenu`, `LevelMap`, `HUD`, `PauseMenu`, `LevelComplete`, `GameOver`, `Settings`, `Shop`, `LoginPrompt`, `GameplayScreen` |
| Scenes (.tscn) | All of the above + 13 tile scenes |
| Level data | `level_001.json` – `level_020.json` (Worlds 1 & 2) |
| Docs | `README.md`, `TASKS.md`, `CHANGELOG.md`, `KNOWN_ISSUES.md`, `LEVEL_DESIGN.md`, `PLAYSTORE_CHECKLIST.md` |

---

## Current State

### What Works (Session 9 - 3D characters + Level 1 jungle runner)
- **Full navigation flow:** Splash → Main Menu → Level Select → 3D game → Level Complete / Game Over → back
- **3D gameplay:** Player auto-runs forward through a procedurally-built 3D jungle runner environment
- **Level 1 art pass:** Dirt trail, layered grass/ferns/bushes/vines, palms, jungle trees, rocks, logs, ruins, butterflies, bird flyovers, rotating coins, and temple finish gate are generated by `LevelManager3D.gd`
- **Playable 3D characters:** Kairo and Zuri GLBs are imported, credited, and selectable through the existing skin system
- **Character animation hooks:** Run, strafe left/right, slide/roll, collect/interact, hit, victory, and defeat clips are wired where available
- **Controls:** Swipe left/right = lane change, swipe up = jump, swipe down = slide; keyboard A/D/W/S for desktop testing
- **Obstacles:** Log (full-lane, must jump), rock (single-lane, must dodge), low branch (must slide), spike/stakes, mud visual
- **Collectibles:** Rotating/bobbing procedural gold coins and blue gems with `Area3D` pickup detection
- **Finish gate:** Mossy stone temple gate with torches, portal glow, and `Area3D` trigger; completes the level
- **Overlays:** PauseMenu, LevelComplete (shows stars + coins), GameOver — all functional with working buttons
- **Star rating:** 1 star = finish, 2 stars = ≥50% coins, 3 stars = all coins
- **Progress saves:** `SaveManager` persists stars, coins, unlocked levels between sessions
- **3 playable levels:** Jungle Trail (easy), Temple Ruins (medium), Ancient Depths (hard)
- **All menus functional:** Settings, Shop, LoginPrompt, Profile, DailyChallenge unchanged and working

### What Is NOT Done Yet
- **Jump/land animation clips** — physics jump works, but the imported free character GLBs do not include exact jump/land clips
- **Editor visual validation** - a headless Godot scene-load check passed from the downloaded Godot executable, but Kairo/Zuri scale, camera framing, and obstacle readability still need a visual editor/device pass
- **Final environment meshes** — Level 1 has procedural jungle dressing, but final imported GLB environment packs are still needed; see `MISSING_3D_ASSETS.md`
- **Collectible polish** — procedural coins/gems now rotate and bob, but final coin/gem models and pickup VFX are still needed
- **River gap gameplay logic** - `_remove_ground_at()` now adds a visual gap, but Level 3 still needs proper bridge/gap collision and fail handling
- **Login is fake** — `_simulate_login()` stub; no Firebase/Supabase
- **No cloud save** — `add_pending_sync()` queues but nothing uploads
- **Android export not configured** — no export preset, no keystore
- **Levels 4+ missing** — add JSON files + bump `TOTAL_LEVELS` in `LevelSelect.gd`
- **Daily challenge** — placeholder screen only

---

## Parser Errors Fixed (Session 2)

1. `Constants.WORLDS` used `range()` in a `const` — replaced with `level_start`/`level_end` + `static func world_levels()`.
2. `JSON.parse_string()` inferred as Variant via `:=` — changed to `var x: Variant =` in `SaveManager.gd` and `LevelLoader.gd`.
3. `InputHandler.gd` accessed uncast `InputEvent` properties — added `event as InputEventScreenTouch` etc. casts.
4. `AudioManager.gd` had class-level `preload()` for missing `.wav` files — moved to runtime `load()` with `ResourceLoader.exists()` guard.
5. `Grid.gd` had `const TEXTURE = preload(...)` for missing `.png` files — replaced with runtime load + `ColorRect` fallback.

## Known Issues Still Open

1. **KI-009** — `SaveManager.get_setting()` default parameter uses `= null` which conflicts with strict typing. Works at runtime but may produce type warnings. Low priority.

2. **No switch-tile levels** — Switch + gate mechanic is now fully wired (KI-010 fixed), but no level JSON files use `X` tiles yet. Add them in World 3+ levels.

3. **Simulated login only** — `LoginPrompt._simulate_login()` grants coins and sets `is_logged_in`, but no real auth backend exists. Cloud save queue (`add_pending_sync`) is stubbed.

---

## Next Session — Recommended Order

### Priority 1 — First Run Smoke Test
1. Open the project in Godot 4.6 (F5 to run).
2. Expected flow: SplashScreen → MainMenu → LevelSelect → Level 1 → collect coins → reach finish gate → LevelComplete → Level 2.
3. Check Godot Output panel for `[NAV]` logs; any `ERROR` line means a scene path is wrong.
4. Press A/D to change lanes, W/Space to jump, S to slide.
5. Verify Kairo loads by default, then equip Zuri in Shop and confirm she loads in `Game3D`.

### Priority 2 — 3D Art Pass
Replace placeholder geometry with real low-poly assets. Follow `MISSING_3D_ASSETS.md` integration notes.
- **Character polish:** verify Kairo/Zuri scale and orientation in the editor; add dedicated jump/land animation clips when sourced.
- **Obstacles/trees:** replace calls in `LevelManager3D._box_obstacle()` and `_tree()` with `preload("res://assets/3d/...")` instances.
- Free sources: kenney.nl (Nature Kit, Prototype Kit), opengameart.org "low poly jungle".

### Priority 3 — More Levels
Add `data/levels3d/level3d_004.json` … `level3d_010.json` using the same schema.
Bump `TOTAL_LEVELS = 10` in `LevelSelect.gd`.

### Priority 4 — Audio Pass
Wire `AudioManager._sfx_map` entries for 3D gameplay:
```gdscript
_sfx_map["coin"]           = load("res://assets/sounds/coin.wav")
_sfx_map["level_complete"] = load("res://assets/sounds/level_complete.wav")
_sfx_map["game_over"]      = load("res://assets/sounds/game_over.wav")
_sfx_map["button"]         = load("res://assets/sounds/button.wav")
```

### Priority 5 — Android Build
Follow `PLAYSTORE_CHECKLIST.md` step by step.

---

## Architecture Notes for Next Session

- **Signal flow:** All cross-system communication goes through `EventBus`. Never add direct `get_node()` calls between unrelated scenes.
- **Adding a new tile type:** (1) Create `scripts/gameplay/tiles/NewTile.gd` extending `BaseTile`. (2) Create `scenes/gameplay/tiles/NewTile.tscn`. (3) Add the char to `Constants.gd` and to `Grid.TILE_SCENES` dictionary. (4) Add it to the level JSON legend.
- **Adding a new level:** Just drop a new JSON file in `data/levels/`. No code change needed.
- **Local save path:** `user://save_data.json` — on Android this is inside the app's private storage (no permissions needed).

---

## File Tree (for quick orientation)

```
jungle_escape/
├── checkpoint.md               ← YOU ARE HERE (Session 8)
├── 3D-transformation.md        ← 3D pivot spec + task tracking
├── MISSING_3D_ASSETS.md        ← all placeholder → real asset gaps
├── project.godot
├── CHANGELOG.md / README.md / TASKS.md / KNOWN_ISSUES.md
├── assets/
│   ├── fonts/                  (Cinzel + Inter TTF)
│   ├── backgrounds/            (bg_main_menu.png, bg_gameplay.png)
│   ├── ui/icons/               (6 HUD icons)
│   ├── sounds/                 (starter .wav SFX/music)
│   ├── sprites/                (tiles, characters, ui)
│   └── 3d/
│       ├── ASSET_CREDITS.md    ✅ 3D source/license ledger
│       └── characters/
│           ├── kairo/          ✅ Kairo GLB + wrapper scene
│           └── zuri/           ✅ Zuri GLB + wrapper scene
├── data/
│   ├── levels/
│   │   └── level_001.json … level_020.json   ✅ (2D puzzle levels, archived)
│   └── levels3d/
│       ├── level3d_001.json  ✅  Jungle Trail  (25 tiles, 7 obstacles)
│       ├── level3d_002.json  ✅  Temple Ruins  (33 tiles, 13 obstacles)
│       └── level3d_003.json  ✅  Ancient Depths (40 tiles, 20 obstacles)
├── scenes/
│   ├── splash/SplashScreen.tscn              ✅
│   ├── main_menu/MainMenu.tscn               ✅ (Play → LevelSelect)
│   ├── game3d/Game3D.tscn                    ✅ ← 3D main gameplay scene
│   ├── menus/
│   │   ├── LevelSelect.tscn                  ✅ ← 3D level grid
│   │   ├── Settings.tscn                     ✅
│   │   ├── Shop.tscn                         ✅
│   │   ├── LoginPrompt.tscn                  ✅
│   │   ├── Profile.tscn                      ✅
│   │   └── DailyChallenge.tscn               ✅
│   ├── level_map/LevelMap.tscn               ✅ (2D, archived)
│   └── gameplay/GameplayScreen.tscn          ✅ (2D, archived)
└── scripts/
    ├── autoload/
    │   ├── GameManager.gd   ✅ (+go_to_gameplay_3d, +go_to_level_select)
    │   ├── SaveManager.gd   ✅
    │   ├── AudioManager.gd  ✅
    │   └── EventBus.gd      ✅
    ├── gameplay/
    │   ├── Player3D.gd      ✅ ← 3D lane runner
    │   ├── InputHandler3D.gd ✅ ← swipe + keyboard
    │   ├── LevelManager3D.gd ✅ ← procedural level builder
    │   ├── Grid.gd / Player.gd / InputHandler.gd  (2D, archived)
    │   └── tiles/ (14 tile scripts, 2D archived)
    └── ui/
        ├── Game3D.gd        ✅ ← 3D scene controller
        ├── HUD3D.gd         ✅
        ├── PauseMenu3D.gd   ✅
        ├── LevelComplete3D.gd ✅
        ├── GameOver3D.gd    ✅
        ├── LevelSelect.gd   ✅
        ├── MainMenu.gd      ✅ (updated)
        └── (other 2D UI scripts unchanged)
```
