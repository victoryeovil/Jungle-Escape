# CHANGELOG — Jungle Escape: Lost Path

## [Unreleased] - Generated 3D Asset Fill Pass

### Added
- **Original generated low-poly 3D asset kit** - 54 new `.glb` files created under `assets/3d/` for environment path pieces, foliage, trees, rocks, obstacles, bridges, finish gates, rewards, collectibles, wildlife, and the Sand Shoes prop.
- **3D material and VFX resources** - added `mossy_stone.tres`, `water_stylized.tres`, `foliage_sway.gdshader`, and six `GPUParticles3D` scene resources for torch flame, finish glow, pickup sparkle, dust puff, hit burst, and sand trail effects.
- **Repeatable asset generator** - added `tools/generate_missing_3d_assets.py`, a deterministic local GLB/resource generator for the project-authored missing 3D asset pass.

### Changed
- **`MISSING_3D_ASSETS.md`** now marks generated GLB/resource targets as `Generated (original)` and clarifies that level runtime dressing remains procedural until `LevelManager3D.gd` is wired to instantiate the new assets.
- **`ASSET_LICENSES.md` and `assets/3d/ASSET_CREDITS.md`** now document the generated assets as original project-authored output with no third-party attribution requirement.
- **Poly Pizza Elephant entry** in `ASSET_LICENSES.md` is marked not imported / not used because `assets/3d/wildlife/elephant.glb` is now an original generated asset.

### Validation
- Generated 54 GLB files and confirmed all 56 project GLBs have valid `glTF` 2.0 binary headers, JSON chunks, meshes, and materials.
- Godot import metadata has not been generated yet because the editor/headless executable is not available from this shell.

## [Unreleased] - Jungle Map Visual Overhaul

### Changed
- **LevelSelect.gd** fully rewritten with layered procedural rendering: all backgrounds, trees, path, river, camp, temple, fog, and marker halos now drawn in `_draw()` for correct depth ordering.

### Added
- **Sky gradient** at top of map (blue sky → sandy amber wildlands) via thin horizontal draw_rect bands.
- **Triangular tree canopies** — 4-layer polygon silhouettes (trunk + 3 canopy tiers) replace plain rectangles; trees now have authentic jungle outline.
- **Curved river** — `draw_polyline` with 8-point arc replaces straight rectangles; animated shimmer alpha pulses via `_process()`.
- **Improved bridge** — 6 visible planks with rails and support posts drawn in `_draw()`.
- **Animated birds** — two `Label` nodes tween across map at different heights and speeds each frame.
- **Campfire flames** — triangle polygon flames + log rects + tent A-frame + expedition flag.
- **Temple gate** — two stone pillars, lintel, sun-symbol with 8 `draw_line` rays, concentric glow halos.
- **Sandy dune mounds** — triangle polygons at wildlands zone bottom edge.
- **Acacia tree helper** (`_dacacia`) — trunk rect + flat spreading canopy, used for 4 acacia trees in wildlands zone.
- **Distant elephant and warthog silhouettes** in wildlands zone drawn directly in `_draw()`.
- **Fog overlay** over locked Level 6 zone; dissipates when Level 6 unlocked.
- **Stone path edge markers** — small circles along path sides every 3 waypoints.
- **Stronger marker halos** — two glow rings per unlocked level + extra gold halo on current/next level.
- **Marker name labels** moved outside button for cleaner circles; 90×90 circular badges (up from 88×76 rectangular).
- **Parchment-style preview panel** with corner ornaments, divider line, chapter label.
- **Zone labels** positioned clearly without overlap; `~ River of Echoes ~` centred at water zone.
- **ASSET_LICENSES.md** created — documents Kenney UI Pack Adventure, Kenney Game Icons, Quaternius Nature MegaKit, Quaternius Ultimate Nature Pack, Poly Pizza Elephant; includes download URLs, licenses, extract paths and still-needed table.
- **Asset folder structure** created: `assets/backgrounds/`, `assets/ui/map/markers/`, `assets/ui/map/icons/`, `assets/ui/map/landmarks/`, `assets/ui/map/effects/`.

### Notes
- Map still uses procedural rendering; replace with `bg_jungle_map.png` + marker PNGs once sourced.
- Animated `_process()` calls `queue_redraw()` every frame for bird/shimmer animation — acceptable for a static menu.

## [Unreleased] - Level 6 Full Implementation: Sand Physics, Dressing, Shops

### Added
- **Sand terrain physics** in `Player3D` — on sand without Sand Shoes: speed ×0.45, jump blocked; emits `sand_blocked` signal.
- **Sand warning HUD** in `HUD3D` — floating "Sand Shoes Required" toast that auto-dismisses after 2.2 s; Level 6 shows live resource bar (food, bricks, wood, sunstone shards).
- **Level 6 atmosphere** in `Game3D._level_atmosphere()` — warm sandy sky (`Color(0.62, 0.52, 0.32)`), low fog density, bright sun at 1.32 energy.
- **Resource drops at level finish** in `Game3D._on_finish_reached()` — each level awards specific resources (e.g. Level 6: wood×1, bricks×2, food×1, sunstone_shard×1) via `GameManager.collect_resource()`.
- **Resource reward display** in `LevelComplete3D.show_result()` — added optional `resources: Dictionary` param; appends an icon row below coins label.
- **`EventBus.resource_collected` signal** — emitted on every resource award; HUD3D subscribed to refresh resource bar labels.
- **`GameManager.collect_resource()`** — central method: `SaveManager.add_resource()` + emits `EventBus.resource_collected`.
- **`GameManager.go_to_upgrade_shop()` / `go_to_home_building()`** — navigation methods for the two new screens.
- **Level 6 savanna 3D dressing** in `LevelManager3D` — acacia trees, dry grass tufts, sandy rock clusters, elephant and warthog silhouettes; `_spawn_dressing()` routes to `_spawn_wildlands_dressing()` for Level 6; `_spawn_path_variation()` and `_spawn_wildlife()` have Level 6 overrides.
- **River gap kill zone** in `LevelManager3D._remove_ground_at()` — `Area3D` with `BoxShape3D` triggers `die()` when a `CharacterBody3D` enters the gap; visual gap gains water shimmer strips.
- **Upgrade Shop screen** (`scripts/ui/UpgradeShop.gd` + `scenes/menus/UpgradeShop.tscn`) — full procedural upgrade listing with affordability check, buy button, inventory strip, and feedback toast.
- **Home Building screen** (`scripts/ui/HomeBuilding.gd` + `scenes/menus/HomeBuilding.tscn`) — 6-stage construction progress UI; locked stages shown greyed; spend resources to advance.
- **"Open Upgrade Shop" link** in LevelSelect sand shoes popup (bottom button).
- **"Build Your Home" button** on last panel of WildlandsUnlock story screen.

## [Unreleased] - Wildlands of Peace: Level 6, Sand Shoes & Story Transition

### Added
- **Level 6 — "Wildlands of Peace"** (`data/levels3d/level3d_006.json`) — 40-row sandy expedition level with one right turn at row 20, 11 obstacles, and 24 collectibles including a final gem.
- **Sandy terrain theme** in `LevelManager3D._setup_theme()` — Level 6 uses warm sandy colours (`dirt_dark = Color(0.72, 0.60, 0.38)`) and sets `"surface": "sand"`, activating the existing ×0.45 speed penalty without sand shoes.
- **Sand Shoes upgrade** in `Constants.UPGRADES` — costs 100 coins + 2 Food + 1 Relic Key; gates entry to Level 6; icon `👟`.
- **New resource collectibles** in `Constants.RESOURCES` — bricks, wood, tiles, windows, food, tools, relic_keys, sunstone_shards, map_pieces (9 types).
- **Home Building stages** in `Constants.HOME_STAGES` — 6 progressive build stages from "Buy Land" → "Complete Home", each with resource cost dict.
- **Wildlife tips** in `Constants.WILDLIFE_TIPS` — 5 educational messages about coexisting with wild animals.
- **SaveManager resource API** — `get_resource()`, `add_resource()`, `spend_resource()`, `get_all_resources()`.
- **SaveManager upgrade API** — `has_upgrade()`, `unlock_upgrade()`, `buy_upgrade()` (checks heterogeneous coin + resource cost dict).
- **SaveManager home API** — `get_home_stage()`, `set_home_stage()`.
- **`WildlandsUnlock.gd` + `WildlandsUnlock.tscn`** — 3-panel post-Level-5 story screen: savanna background with procedural elephant/warthog silhouettes and drifting sand particles; panels cover "The Jungle Opens", "Peaceful Coexistence" (Zimbabwe/Victoria Falls wildlife story), and "Sand Shoes Required" (purchase prompt); Continue / Skip / Back-to-Map navigation.
- **`GameManager.go_to_wildlands_unlock()`** — navigation method that routes to the WildlandsUnlock story screen.
- **Sand Shoes gate on Level 6 map marker** — marker shows `👟` icon and "Sand Shoes" caption when Level 6 is unlocked but shoes are not owned; tapping opens the Sand Shoes popup instead of the level preview.
- **Sand Shoes popup** — dedicated card (`_build_sand_shoes_popup()`) with cost reminder and "Buy Sand Shoes" button; inline "Not enough resources" feedback on failure.
- **Level 6 entry in `LEVEL_INFO`** — "Wildlands of Peace", Chapter 6, zone "wildlands", warm sandy marker colour.
- **`MISSING_UI_ASSETS.md`** — full manifest of every map, marker, icon, popup, and home-building UI asset not yet imported.

### Changed
- **`LevelSelect.gd` rebuilt** — `TOTAL_LEVELS = 6`; 5 distinct visual zone backgrounds (sandy wildlands top, ruins band, river crossing, jungle body, jungle entrance); level markers now use corner_radius = 40 (fully circular badges); coins display in header; zone label watermarks; savanna acacia trees and elephant/warthog silhouettes in wildlands zone.
- **`LevelComplete3D._on_next()`** — after completing Level 5, routes to `GameManager.go_to_wildlands_unlock()` instead of directly to Level 6 (only if sand shoes not yet owned).
- **`MISSING_3D_ASSETS.md`** — added Level 6 dressing row to Priority 4, two new wildlands wildlife rows (elephant, warthog, weaver bird), upgrade item models section (Priority 9b), home building stage images (Priority 9c), and Level 6 level card.

---

## [Unreleased] - Jungle Expedition Map Upgrade

### Added
- Redesigned the level select screen into a full jungle expedition map (`LevelSelect.gd` + `LevelSelect.tscn` rewritten).
- Winding dirt trail drawn procedurally with `_draw()` polyline (shadow → outer edge → centre lane → highlight).
- Jungle background layers: sky strip, main floor, ground base, left/right tree silhouettes, mid-scene accent trees, ancient ruin stone fragments, relic glow detail.
- River of Echoes section: blue water band, two shimmer strips, bank edges, and floating label.
- Fog zone overlay at top (locked area), with "Wildlands of Peace (Unlocks after Level 5)" label.
- Start Camp landmark: flag pole, tent, yellow pennant, "START CAMP" label.
- Temple of the First Sun icon: stone gate with two pillars, lintel, golden inner glow, label.
- Themed level markers for Levels 1–5: stone-border `Button` nodes at path positions with chapter colour, level name, and star display.
- Current-level marker pulses gold using a looping `Tween`.
- Locked Level 6 "Wildlands" teaser node in the fog zone.
- Level preview panel (slides up on tap): chapter, level name, star rating, story description, rewards hint, **Start Expedition** and **Close** buttons.
- Objective strip at bottom: "Follow the Lost Path → reach the Temple of the First Sun".
- Header bar: `✦ JUNGLE MAP ✦` title, back button.
- Any-swipe back when preview is open dismisses the panel rather than returning to menu.
- Deterministic tree layout via seeded `RandomNumberGenerator` (seed 7771) — same positions every open.

### Changed
- Replaced plain 3-column `GridContainer` level buttons with map-based path progression.
- `LevelSelect.tscn` stripped to a bare root `Control` + script; all nodes built programmatically.
- `LevelSelect.gd` `_populate()` / `@onready` grid references removed; replaced with `_build_bg()`, `_build_env_details()`, `_build_river()`, `_build_fog_zone()`, `_build_camp()`, `_build_temple_icon()`, `_build_level_markers()`, `_build_ui_overlay()`, `_build_preview_panel()`.

### Notes
- Map coordinates are tuned for 480×854 portrait.
- Level 6 "Wildlands of Peace" node is a non-interactive teaser; full unlock, Sand Shoes mechanic, and wildlife zone arrive in a future session.
- Level preview panel does not yet animate in — simple `visible = true/false` for now; slide-up tween can be added as polish.

---

## [Unreleased] - Turn System: Character Rotation, Camera Fix, Obstacle Clear Zone

### Fixed
- **Character runs sideways after turn** (`Player3D._execute_turn`) — character mesh never rotated when the heading changed; player physically moved in the new direction but the 3D model kept facing -Z so it appeared to run sideways. `_execute_turn` now sets `rotation.y = atan2(-_move_fwd.x, -_move_fwd.z)` immediately after updating the heading vectors, rotating the full `CharacterBody3D` node (and its GLB child) to face the new forward direction. `reset()` also sets `rotation.y = 0.0` on respawn.
- **Camera faces backward after turn** (`Game3D._process`) — `atan2(to_player.x, -to_player.z)` was the wrong formula. For a Y-rotated node, world-forward = `(-sin θ, 0, -cos θ)`, so pointing at the player requires `θ = atan2(-to_player.x, -to_player.z)`. The sign error was invisible on straight paths (where `to_player.x = 0`) but flipped the camera 180° on every turn, making the player see where they came from. Fixed by negating the first `atan2` argument.
- **Camera too slow after turn** (`Game3D._process`) — old `delta * 4.0` lerp took ~0.25 s to reposition from behind, letting the player run off-screen. Now snaps `_cam_xz` instantly when `(_cam_xz - target_xz).length_squared() > 6.0` (turn-sized jump); uses `delta * 8.0` lerp for small adjustments.
- **Obstacle immediately after turn kills player** (`LevelManager3D._spawn_obstacle`) — clear zone was only `[tr-3 … tr]` so the exit side of every turn had no protection. Row-22 lane-1 rock in level 2 (2 tiles after the row-20 corner) killed the player on entry. Extended to `[tr-3 … tr+3]` — 3 tiles clear on both sides of every corner. Applies globally to all levels.

---

## [Unreleased] - 3D Gameplay: Trees, Surface Jump, Path Turns

### Added
- **Layered cone jungle trees** in `LevelManager3D._jungle_tree()` — tapered trunk, 2–3 buttress root flanges, 3–4 cone tiers (Temple Run style), secondary branch with leaf cluster. Replaces old cylinder-trunk + sphere-canopy placeholder.
- **Arching palm trees** in `LevelManager3D._palm_tree()` — taller trunk (3.4–5.0 m), 3 bark rings, 7–10 outward-leaning fronds, optional coconuts.
- **Surface-specific jump physics** — `Player3D` now detects the surface material under the player (`_detect_surface()`, reads `"surface"` meta from `StaticBody3D`). Jump velocity multiplier: mud ×0.70, sand ×0.82, stone ×1.06.
- **Path turns** — `LevelManager3D` now parses `"turns"` in level JSON, builds a cursor-based row-transform dictionary (`_seg_pos/fwd/right`), and rotates all ground tiles, obstacles, and coins along the correct heading after a 90° corner.
- **Queued-turn system** — swiping in the turn direction queues the turn (`_queued_turn`); it auto-executes in `_physics_process` when the player is within 1.5 m of the corner. Prevents false-turns if the player swipes 3 tiles early.
- **Wide turn trigger zone** — 3 tiles of approach (9 m ≈ 1.1 s at run speed) so the player has ample time to queue a swipe before reaching the corner.
- **Two glowing turn arrows** on the path surface — one 2 tiles before the corner (early warning), one 1 tile before (corner reminder). Both emit yellow with emission glow material.
- **Log-jam dam barrier** (`_spawn_dam_barrier`) replacing the plain wall blocker — mud base, 3 stacked horizontal log tiers with bark end caps, 4 debris logs, 5 rocks, moss patches. Placed exactly at the tile far edge so no void gap exists.
- **Turn data** in level JSON files: level 2 row 20 left, level 3 row 18 right, level 4 row 22 left, level 5 row 25 right.
- **Fall-kill safety net** in `Player3D._physics_process` — `if position.y < -4.0: die()` prevents silent void falls if a geometry gap is ever created.

### Changed
- `turn_zone_entered` signal signature changed from `(required_dir: int)` to `(required_dir: int, corner_pos: Vector3)` — corner position is now passed through so Player3D can execute the queued turn at the right moment.
- `Player3D.move_lane()` — turn swipe now queues (`_queued_turn = dir`) instead of immediately calling `_execute_turn()`.
- `Player3D._on_turn_zone_entered()` — now accepts `corner_pos: Vector3` and stores it; also resets `_queued_turn`.
- `Player3D._on_turn_zone_exited()` — also clears `_queued_turn`.
- Dam collision box is 4.5 m tall (y −0.25 to 4.25) — tall enough to block a maximally jumping player (capsule top ≈ 3.44 m).

### Fixed
- **Void space at Level 2 turn (row 20)** — old wall sat 4.65 m past tile centre, leaving 3.15 m of empty air the player could fall through. Dam now sits at exactly the tile far edge (1.5 m past centre) with collision extending to y = −0.25.

---

## [Unreleased] - Story Theme and Environment Upgrade

### Added
- **Level-specific gameplay atmosphere** in `Game3D.gd` - each 3D chapter now applies distinct WorldEnvironment background, fog color/density, ambient light, sun color, and fill-light strength before building the level.
- **Story completion messages** in `LevelComplete3D.gd` - level clear now displays a short chapter-specific expedition line tied to the lost path, Sunstone shards, ancient symbols, and the Temple of the First Sun.
- **Animated relic glyph glow** in `LevelManager3D.gd` - Level 4 glyphs now pulse their emission at runtime instead of staying static.
- **Story intro screen** (`scenes/menus/StoryIntro.tscn` + `scripts/ui/StoryIntro.gd`) — three-panel opening narrative with animated jungle background, floating leaf particles, and a pulsing relic glow. First-time players see the story of the Temple of the First Sun, the shattered Sunstone Heart, and the expedition of Kairo and Zuri before reaching the main menu.
- **Level-specific visual themes** in `LevelManager3D.gd` — each level now uses a unique color palette for terrain, grass, and path dirt. Level 2 (deep forest) gets darker greens and hanging vines with monkey silhouettes. Level 3 (River of Echoes) adds reed clusters and water-colored stones. Level 4 (Ancient Ruins) places broken pillars and emissive glowing relic glyphs. Level 5 (Temple Approach) builds a stone pillar corridor with torches at every other gate.
- **Jungle camp background on the Shop/Skins screen** (`Shop.gd`) — animated dark jungle layers, tree silhouettes, a flickering campfire with glow, and floating firefly/leaf particles that drift upward behind the skin list.
- **Story flavor text on the main menu** — subtitle "The Temple of the First Sun awaits..." added below the existing "Lost Path" subtitle in `MainMenu.tscn`.
- **`_setup_theme(id)`** method in `LevelManager3D.gd` — clean per-level theme dictionary for dirt, grass, stone, and moss colors, called at the top of `build()`.
- **`_spawn_level_specific_dressing(data)`** method in `LevelManager3D.gd` — level-specific decorative spawning distinct from the shared `_spawn_dressing()` pass.
- **`_spawn_path_variation(data)`** method in `LevelManager3D.gd` — adds leaning root-arch landmarks over path edges every 8 rows, stone edge markers every 5 rows, and ground-level root crossing strips every 10 rows. Makes every stretch of path feel distinct rather than a flat uniform corridor.
- **`data/levels3d/level3d_004.json`** — "Ancient Ruins": 45-tile level, 28 obstacles (rocks, spikes, logs, branch slides), 26 regular coins + 3 gems. Uses the dark ruins theme with glowing glyphs and broken pillars.
- **`data/levels3d/level3d_005.json`** — "Temple Approach": 50-tile level, 34 obstacles, 28 regular coins + 5 gems. The hardest level; uses the temple corridor theme with stone pillar gates and torches.

### Changed
- **3D level completion flow** now passes the active level id into `LevelComplete3D.show_result()` so the overlay can use the correct story beat.
- **First-launch routing** in `SplashScreen.gd` — first-time players are now routed to `StoryIntro.tscn` instead of `MainMenu.tscn`. `SaveManager.is_first_launch()` gates the branch; returning players skip the intro.
- **Main menu button labels** updated to story-consistent text: "PLAY" → "Begin Journey", "Continue Offline" → "Continue Expedition", "Daily Challenge" → "Daily Expedition", "Shop" → "Choose Explorer".
- **Grass and path colors** in `LevelManager3D` now read from the active theme dictionary rather than hardcoded constants, so every level tier looks visually distinct.
- **Level name corrections**: `level3d_002.json` renamed "Temple Ruins" → "Deep Forest"; `level3d_003.json` renamed "Ancient Depths" → "River of Echoes". Names now match the intended chapter identity described in `build.md`.
- **`LevelSelect.gd`** `TOTAL_LEVELS` bumped from 3 to 5, unlocking levels 4 and 5 in the level grid.
- **`SplashScreen.gd`** now procedurally adds 16 drifting jungle particle dots, a pulsing golden relic glow overlay, and a darker background on top of the existing scene nodes — giving the splash screen a jungle atmosphere to match the story mood.

### Notes
- Level 1 remains the polish benchmark; its theme uses the original default colors so existing look is preserved.
- Story and visual identity should now guide all future screen and level design additions.

---

## [Unreleased] - 3D Jungle Environment Update

### Added
- Created a stronger procedural low-poly Level 1 jungle runner environment in `scripts/gameplay/LevelManager3D.gd`.
- Added organized 3D level groups under `LevelManager`: terrain, path, trees, plants, rocks/logs, obstacles, collectibles, animals, ruins, and finish gate.
- Added dirt trail segments with grass side strips, edge details, pebbles, roots, ferns, bushes, vines, palms, jungle trees, mossy ruins, and side logs.
- Added procedural ambient wildlife for Level 1: butterflies hovering near foliage and parrot-style bird flyovers.
- Added rotating and bobbing coin/gem collectibles.
- Added a Level 1 mossy stone temple finish gate with torches and a portal glow.
- Added a low-branch slide obstacle type and changed Level 1 row 13 from a spike to a branch.
- Added `ASSET_LICENSES.md` to summarize commercial-safety status for imported characters and procedural 3D environment assets.

### Changed
- Replaced the flat green ground look with a layered jungle trail composition suitable for a mobile 3D runner.
- Updated `Player3D.gd` so sliding temporarily lowers the collision capsule, allowing slide-under obstacles to work mechanically.
- Updated `MainMenu.gd` so the menu unpauses itself on load and Play routes through `GameManager.go_to_level_select()`.
- Updated `MISSING_3D_ASSETS.md` to separate tested procedural Level 1 content from remaining final GLB production asset gaps.

### Fixed
- Fixed `InputHandler3D.gd` parser failure by removing the empty `InputEventScreenDrag` branch and simplifying touch-up swipe handling.
- Fixed the `InputHandler3D` global class parse cascade that prevented `Game3D.gd` from loading cleanly.
- Fixed `InputHandler3D.gd` class-loading order error: removed the `Player3D` type annotation from `var player` (changed to untyped/dynamic). GDScript parses files alphabetically; "I" before "P" meant `Player3D` was not yet registered when `InputHandler3D` was compiled, causing the "Could not parse global class" error at line 7 and the cascading "Expected indented block" error at line 27. Removing the annotation eliminates the dependency; runtime duck typing is unaffected.
- Fixed all Main Menu buttons being unclickable: the `_input()` override in `MainMenu.gd` was calling `set_input_as_handled()` when `btn_play.is_hovered()` returned a stale true. Because `_input()` fires before the GUI hover state updates, a recent hover over the Play button would block clicks on any other button in the same frame. Fix: removed `_input()`, `_position_hits_play_button()`, and `_log_pointer_event()` entirely; the standard `pressed` signal on each button is sufficient now that the original `has_focus()` bug is resolved.
- Hardened the Play button path with direct `gui_input`, `button_down`, and `pressed` handling so it works even if the tree was previously paused.

### Validation
- Parsed `data/levels3d/level3d_001.json` successfully.
- Ran Godot 4.6.3 headless scene load: `res://scenes/game3d/Game3D.tscn` loaded without `InputHandler3D` parser errors or `LevelManager3D` compile errors.
- Verified the Play button signal path in Godot headless: Main Menu Play opens `LevelSelect.tscn`, and Level 1 opens `Game3D.tscn`.

### Notes
- Level 1 is now visually fuller, but the environment still uses procedural primitive meshes rather than final imported GLB art packs.
- Final jump/land character animation clips and production wildlife/environment models remain tracked in `MISSING_3D_ASSETS.md`.

---

## [0.2.1] - 2026-06-18  *(Session 8 - 3D Character Import)*

### Added
- **`assets/3d/characters/kairo/kairo.glb`** - Imported Kairo's playable 3D character model from Quaternius "Adventurer" on Poly Pizza.
- **`assets/3d/characters/zuri/zuri.glb`** - Imported Zuri's playable 3D character model from Quaternius "Animated Woman" on Poly Pizza.
- **`assets/3d/characters/kairo/Kairo.tscn`** and **`assets/3d/characters/zuri/Zuri.tscn`** - Godot wrapper scenes for the imported GLB models.
- **`assets/3d/ASSET_CREDITS.md`** - License/source ledger for imported 3D assets, including source URLs, license, download date, and in-game use.
- Source preview images for both models in their character folders for internal visual reference.

### Changed
- **`scripts/gameplay/Player3D.gd`** - Now loads the selected 3D character scene at runtime and hides the capsule/head placeholder when the model is available.
- **`scripts/gameplay/Player3D.gd`** - Added animation hooks for run, strafe left/right, slide/roll, collect/interact, hit, victory, and defeat using the imported Quaternius clip names.
- **`scripts/data/Constants.gd`** - Renamed the default 3D skin entries: `explorer` is now Kairo and `jungle_girl` is now Zuri.
- **`scripts/autoload/SaveManager.gd`** - Keeps both Kairo and Zuri unlocked by default, including for older save files that only had `explorer`.
- **`scripts/gameplay/LevelManager3D.gd`** - Coin/gem pickup now calls `Player3D.play_collect()` when available.
- **`scripts/ui/Game3D.gd`** - Finish trigger now plays the player's victory animation before freezing gameplay.
- **`MISSING_3D_ASSETS.md`** - Updated to mark the first two playable character GLBs as imported and to clarify the remaining animation/environment gaps.

### Validation
- Verified both character files are valid GLB 2.0 files.
- Verified both imported models include 24 animations and contain every animation clip currently referenced by `Player3D.gd`.
- Verified Godot-generated `.import` metadata and `.godot/imported/*.scn` files exist for both character GLBs.

### Not Yet Done
- Dedicated jump and land animation clips are still missing from these two free character GLBs; the physics jump works, but visual jump/land clips need a broader animation library or custom animation pass.
- Real 3D environment meshes are still missing; the jungle path, props, coins, gates, and obstacles mostly remain procedural placeholder geometry.
- Could not run a Godot headless scene test in this shell because no `godot` executable is available on PATH.

---

## [0.2.0] — 2026-06-18  *(Session 7 — 3D Pivot)*

### Added
- **`scenes/game3d/Game3D.tscn`** — Full 3D gameplay scene: `WorldEnvironment` (blue sky + jungle fog), two `DirectionalLight3D` nodes, `CharacterBody3D` player with capsule placeholder, third-person `Camera3D` on `CamPivot`, `LevelManager3D`, `InputHandler3D`, `HUD` CanvasLayer, and three overlay panels (PauseMenu, LevelComplete, GameOver).
- **`scenes/menus/LevelSelect.tscn`** — Level selection grid showing levels 1–3 with star rating and lock/unlock state.
- **`scripts/gameplay/Player3D.gd`** — `CharacterBody3D` lane runner: auto-forward movement, smooth X-lerp lane switching (3 lanes ±1.8m), jump with gravity, slide with duration timer, and obstacle hit detection via `get_slide_collision()` / StaticBody3D meta tag.
- **`scripts/gameplay/InputHandler3D.gd`** — Touch swipe detection (min 40px, max 0.5s) for left/right lane, jump, slide. Keyboard fallback: A/D lanes, W/Space jump, S slide.
- **`scripts/gameplay/LevelManager3D.gd`** — Procedurally builds a full 3D level from JSON: ground tiles, obstacle meshes (log/rock/spike/mud), coins and gems with `Area3D` pickup, flanking trees, and a temple finish gate with `Area3D` trigger.
- **`scripts/ui/Game3D.gd`** — Main 3D scene controller: loads level JSON, wires player/level signals, tracks win/lose state, calls `SaveManager.complete_level()`, sets star rating.
- **`scripts/ui/HUD3D.gd`** — CanvasLayer HUD with pause button, level number label, and live coin counter.
- **`scripts/ui/PauseMenu3D.gd`** — Pause overlay (`PROCESS_MODE_WHEN_PAUSED`): Resume, Restart, Main Menu.
- **`scripts/ui/LevelComplete3D.gd`** — Win overlay: shows stars and coins earned; Next Level, Replay, Map buttons.
- **`scripts/ui/GameOver3D.gd`** — Fail overlay: Retry and Map buttons.
- **`scripts/ui/LevelSelect.gd`** — Populates level grid from `SaveManager`; routes to `GameManager.go_to_gameplay_3d()`.
- **`data/levels3d/level3d_001.json`** — "Jungle Trail": 25 tiles, 7 obstacles, 16 coins + 1 gem.
- **`data/levels3d/level3d_002.json`** — "Temple Ruins": 33 tiles, 13 obstacles, 22 coins + 2 gems.
- **`data/levels3d/level3d_003.json`** — "Ancient Depths": 40 tiles, 20 obstacles, 23 coins + 2 gems.
- **`MISSING_3D_ASSETS.md`** — Full asset gap catalogue (player model + animations, environment meshes, collectibles, audio) with integration notes for each placeholder.
- **`GameManager.go_to_gameplay_3d(level_id)`** — Navigates to `Game3D.tscn`; `restart_level()` updated to use it.
- **`GameManager.go_to_level_select()`** — Navigates to `LevelSelect.tscn`.

### Changed
- **`MainMenu.gd`** — Play and Continue Offline buttons now navigate to `LevelSelect.tscn` (was `LevelMap.tscn`).
- **`project.godot`** — Description updated to reflect 3D game.
- **`3D-transformation.md`** — All implemented tasks marked `[x]`; deferred items marked `[~]`.

### Fixed
- **`MainMenu.gd`** — Removed `btn_play.has_focus()` check from `_position_hits_play_button()`. Godot auto-focuses the first button on scene load; the focus check was silently consuming every click on the screen and preventing any button from showing a pressed state or firing its signal.

### Architecture
- Levels are JSON-driven (`data/levels3d/`); obstacle and coin layout requires no code changes to add levels.
- All placeholder geometry (BoxMesh, CylinderMesh, SphereMesh) is swappable — `LevelManager3D` methods are the single integration point for real 3D assets.
- Star rating: 1 star = finish, 2 stars = ≥50% coins collected, 3 stars = all coins collected.
- Obstacle death: `StaticBody3D` nodes tagged with `meta("obstacle")` — detected in `Player3D._physics_process()` via `get_slide_collision()`.

### Not Yet Done
- Real 3D player model + animations (placeholder: capsule + sphere)
- Real environment meshes (placeholder: colored BoxMesh / CylinderMesh)
- Coin spin animation
- River gap collision logic
- Distance/score counter in HUD
- On-screen swipe button fallback (keyboard works for desktop)
- Android build and device test

---

## [0.1.2] — 2026-06-18  *(Session 6 — Button Navigation Fix)*

### Added
- Three new Main Menu buttons wired: Shop (`Shop.tscn`), Continue Offline (`LevelMap.tscn`), Daily Challenge (`DailyChallenge.tscn`).
- `scenes/menus/DailyChallenge.tscn` + `scripts/ui/DailyChallenge.gd` — placeholder screen with Back button.

### Fixed
- **`GameplayScreen.tscn`** — Added `process_mode = 2` (`PROCESS_MODE_WHEN_PAUSED`) to PauseMenu node. Godot 4.6 blocks `_gui_input` on PAUSABLE nodes when `get_tree().paused = true`; this made every PauseMenu button dead.
- **`PauseMenu.gd`** — Added `get_tree().paused = false` before `change_scene_to_file` in `_on_settings()` so Settings loads with the tree unpaused.
- **`EventBus.gd`** — Added `@warning_ignore("unused_signal")` before all signal declarations.
- **`GameManager.gd`** — Renamed `level_id` → `_level_id` in `_on_level_completed()` to clear unused-parameter warning.
- **Main Menu VBox** — Expanded from 180px to 400px (`offset_top = -180, offset_bottom = 220`) to fit 6 buttons without clipping.

---

## [0.1.1] — 2026-06-17  *(Session 5 — Missing UI Assets)*

### Added
- Six transparent HUD/UI icons in `assets/ui/icons/`: pause, restart, hint, coin, key, and star.
- Two portrait backgrounds in `assets/backgrounds/`: `bg_gameplay.png` and `bg_main_menu.png`.
- Commercial-use OFL fonts in `assets/fonts/`: `title_font.ttf` (Cinzel) and `body_font.ttf` (Inter), plus `FONT_LICENSES.md`.
- `UIStyle.gd` helper for shared UI fonts and icon sizing.

### Changed
- HUD pause, hint, and restart buttons now use icons instead of text-only/default controls.
- HUD and level-map coin/key/star counters now use the new icon assets.
- Main menu now uses `bg_main_menu.png`; gameplay now uses `bg_gameplay.png` behind the grid.
- Menu, HUD, settings, shop, login, level map, level complete, pause, and game-over UI now apply the shared font styling.
- `MISSING_ASSETS.md`, `TASKS.md`, and `checkpoint.md` updated to reflect the completed asset work.

### Validation
- Verified all new PNG dimensions and transparent icon corners.
- Verified both TTF font headers.
- Static `res://` reference scan reports `0` missing references.
- Godot 4.6.3 headless project and MainMenu scene load checks passed.

### Fixed
- Fixed Main Menu Play button not navigating after UI asset integration by converting `StringName` node names to `String` before calling `to_lower()` in `UIStyle.gd`.
- Set runtime-created background and counter icon `TextureRect` nodes to `MOUSE_FILTER_IGNORE` so they cannot intercept button clicks.
- Hardened the Play button path by also listening to `button_down`, guarding duplicate navigation, and deferring a direct `LevelMap.tscn` scene change from `MainMenu.gd`.
- Verified with Godot 4.6.3 headless: simulated Play button press changes to `res://scenes/level_map/LevelMap.tscn`.
- Added `[NAV]` diagnostic logs for Splash -> MainMenu -> Play click -> LevelMap navigation so the Godot Output panel shows whether the button receives input and whether scene changes succeed.
- Added root-level MainMenu input diagnostics and Play hit-test fallback using raw event position, viewport mouse position, scaled position, hovered state, and focus state.

## [0.1.0] — 2026-06-17  *(Session 1 — Initial Build)*

### Added
- Full Godot 4 project skeleton (project.godot, 480×854 portrait mobile)
- Autoload singletons: `GameManager`, `SaveManager`, `AudioManager`, `EventBus`
- `Constants.gd` — tile types, world definitions, skin/trail catalog, economy values
- `LevelLoader.gd` — JSON-based level loading
- `Grid.gd` — tile grid rendering, player movement, win/lose detection
- `Player.gd` — smooth tile-by-tile movement with tween, skin support
- `InputHandler.gd` — swipe detection + keyboard fallback (WASD/arrows)
- Tile scripts: `BaseTile`, `CoinTile`, `GemTile`, `FruitTile`, `KeyTile`, `GateTile`,
  `ExitTile`, `SpikeTile`, `SnakeTile`, `RiverTile`, `BridgeTile`, `MudTile`,
  `VineTile`, `SwitchTile`
- UI scripts: `SplashScreen`, `MainMenu`, `LevelMap`, `HUD`, `PauseMenu`,
  `LevelComplete`, `GameOver`, `Settings`, `Shop`, `LoginPrompt`, `GameplayScreen`
- All `.tscn` scene files with layout nodes and script references
- 20 level JSON files (Worlds 1–2, levels 1–20):
  - World 1 (Jungle Path, levels 1–10): coins, gems, fruit, basic movement
  - World 2 (Hidden Gates, levels 11–20): keys, gates, spikes, snakes introduced
- `SaveManager`: JSON local save, settings, hints, skins, coins, gems, stars
- `GameManager`: state machine, coin/key/gem tracking, star calculation
- `AudioManager`: SFX + music bus wiring with starter WAV assets
- `EventBus`: full signal dictionary for decoupled communication
- Starter PNG art pack for gameplay tiles, player skins, icon, and splash image
- `README.md`, `TASKS.md`, `CHANGELOG.md`, `KNOWN_ISSUES.md`,
  `LEVEL_DESIGN.md`, `PLAYSTORE_CHECKLIST.md`
- `checkpoint.md` — session handoff document

### Architecture Decisions
- Levels are fully data-driven JSON — no code change needed to add levels
- All gameplay signals routed through `EventBus` (no direct cross-scene references)
- Gameplay tiles and player skins use `Sprite2D` art with `ColorRect` fallback
- Save conflict rule: keep higher progress (SaveManager)
- Login is soft-prompt only — never blocks gameplay
- Guest mode fully functional offline

### Not Yet Done
- Production-quality commissioned art pass
- Production-quality audio pass
- Levels 21–50 (Worlds 3–5)
- Firebase/Supabase backend
- Android export & testing
- Daily challenge system
- Friend challenge and leaderboard
