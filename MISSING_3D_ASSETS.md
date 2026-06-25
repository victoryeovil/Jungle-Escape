# 3D Asset Manifest — Jungle Escape: Lost Path

Status key: ✅ Available/imported · 🔧 Procedural placeholder (functional, not final) · ❌ Missing (blocks visual polish or feature) · Generated (original) Project-authored runtime GLB/resource

This file is the production asset manifest. `res://` maps to the project root.  
Every new import must have a corresponding entry in `ASSET_LICENSES.md`.

Generated assets were created by `tools/generate_missing_3d_assets.py`, `tools/generate_playable_characters.py`, `tools/generate_mode_equipment.py`, and `tools/generate_track_assets.py`. They are original low-poly project assets, not third-party downloads. The resource icon PNGs were generated specifically for this project and locally converted to transparent 32×32 RGBA assets.

---

## Path Modules - Survival Runner Update

| Asset | Status | Target path | Notes |
| --- | --- | --- | --- |
| 1-, 2-, and 3-lane curved trail modules | Generated (original, wired) | `res://assets/3d/environment/tracks/` | Curves select a lane-count-specific GLB and matching collision/lane topology. |
| Narrow jungle trail module | Generated (original, wired) | `res://assets/3d/environment/tracks/{dirt,grass}/track_*_1lane.glb` | Single-lane modules force the player to the centre trail. |
| Wide clearing module | Generated (original, wired) | `res://assets/3d/environment/tracks/*/track_*_3lane.glb` | Three-lane modules support chase and junction routes. |
| Bridge path module | Generated (original, wired) | `res://assets/3d/environment/tracks/wood/` | Planked variants include edge rails. |
| Ruins corridor module | Generated (original, wired) | `res://assets/3d/environment/tracks/stone/` | Stone paver variants support corridors and temple approaches. |
| Sand dune path module | Generated (original, wired) | `res://assets/3d/environment/tracks/sand/` | Sand variants include wind ridges and worn lane markings. |
| Mud trail module | Generated (original, wired) | `res://assets/3d/environment/tracks/mud/` | Mud variants include puddles and tracking-mode lane wear. |
| Grass trail and pressed-footstep response | Generated/runtime (wired) | `res://assets/3d/environment/tracks/grass/` / `LevelManager3D.gd` | Grass-track steps create alternating flattened marks that fade after 6.5 seconds. |
| Living vegetation wind | Runtime (wired) | `LevelManager3D.gd` | Grass, ferns, bushes, palms, jungle trees, dry grass, and acacias sway with per-level wind/gust settings. |

## Water Slide

| Asset | Status | Target path | Notes |
| --- | --- | --- | --- |
| Water slide channel model | Generated (original, wired) | `res://assets/3d/environment/tracks/water_slide/` | One-, two-, and three-lane blue channels with raised edges and water glints. |
| Water splash effect | Procedural placeholder (functional, not final) | `LevelManager3D.gd` / `Player3D.gd` | Splash meshes appear in slide rows and around the player. |
| Slide rocks | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | `water_rock` obstacle added. |
| Low vines | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Existing `branch` obstacle covers duck-under sections. |
| Water token collectible | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | `water_token` pickup renders as a blue drop. |

## Boat Mode

| Asset | Status | Target path | Notes |
| --- | --- | --- | --- |
| Canoe / boat model | Generated (original, wired) | `res://assets/3d/vehicles/canoe.glb` | Boat mode now loads the pointed expedition canoe scene; procedural geometry remains only as a load-failure fallback. |
| Boat safety outfit | Generated (original, wired) | `res://assets/3d/outfits/boat/boat_outfit.glb` | Modular life jacket, reflective straps, river pack, and water boots fitted over every selectable explorer. |
| River rapid track variants | Generated (original, wired) | `res://assets/3d/environment/tracks/boat/` | One-, two-, and three-lane river sections with banks and water glints. |
| Floating logs | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | `floating_log` obstacle added. |
| River rocks | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | `river_rock` / `water_rock` obstacle added. |
| Crocodile warning marker | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | `crocodile_zone` obstacle added as danger-zone visual. |
| Boat dock model | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Boat-entry modules add dock props. |

## Skating Mode

| Asset | Status | Target path | Notes |
| --- | --- | --- | --- |
| Protective skating outfit | Generated (original, wired) | `res://assets/3d/outfits/skating/skating_outfit.glb` | Helmet, harness, elbow/knee pads, and inline skates. `Player3D` accepts `skating`, `skate`, `skates`, and `roller_skating` mode names. |
| Skating path modules | Generated (original, wired) | `res://assets/3d/environment/tracks/skating/` / `level3d_015.json` | Lane-count-specific tracks use cyan dividers, violet edge lighting, signage, and skating mode triggers. |

## Tracking

| Asset | Status | Target path | Notes |
| --- | --- | --- | --- |
| Rabbit footprints | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Tracking and chase modes spawn footprint marks. |
| Paw prints | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Level 10 and 18 use tracking routes. |
| Hoofprints | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Level 16 uses chase/tracking footprint routes. |
| Broken branch clues | Missing final art | `res://assets/3d/tracking/` | Needed for final tracking polish. |
| Scent trail effect | Missing final art | `res://assets/3d/vfx/` | Needed for dog-guided route polish. |
| Animal observation marker | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Route signs and animal badge pickups cover current functionality. |

## Animals

| Asset | Status | Target path | Notes |
| --- | --- | --- | --- |
| Rabbit model and animation | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Chase encounter silhouette exists; final rig/animation missing. |
| Antelope model and animation | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Chase encounter silhouette exists; final rig/animation missing. |
| Warthog model and animation | Generated/procedural mix | `assets/3d/wildlife/warthog.glb` / `LevelManager3D.gd` | Decorative GLB fallback plus procedural silhouettes. |
| Boar model and chase animation | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Escape encounter silhouette exists; final rig/animation missing. |
| Crocodile model and idle animation | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Crocodile danger-zone visual exists; final model missing. |
| Monkey movement animation | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Existing monkey silhouettes and chase fallback. |

## UI / Effects

| Asset | Status | Target path | Notes |
| --- | --- | --- | --- |
| Junction arrow indicators | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Glowing route arrows are spawned at junctions. |
| Route signpost icons | Procedural placeholder (functional, not final) | `LevelManager3D.gd` | Label3D signposts show route labels. |
| Chase warning icon | Procedural placeholder (functional, not final) | `HUD3D.gd` / `LevelManager3D.gd` | HUD mode prompt and warning signs exist. |
| Tracking mode icon | Missing final art | `res://assets/ui/icons/` | HUD currently uses text only. |
| Boat mode icon | Missing final art | `res://assets/ui/icons/` | HUD currently uses text only. |
| Water slide mode icon | Missing final art | `res://assets/ui/icons/` | HUD currently uses text only. |

---

## Priority 0 — Asset Pipeline Setup

| Item | Status | Target path | Notes |
| --- | --- | --- | --- |
| Environment folder structure | ✅ Created | `res://assets/3d/environment/`, `obstacles/`, `collectibles/`, `wildlife/`, `vfx/`, `materials/` | Folders exist. |
| Root asset license ledger | ✅ Exists | `res://ASSET_LICENSES.md` | Keep updated for every imported third-party asset. |
| 3D asset credit ledger | ✅ Exists | `res://assets/3d/ASSET_CREDITS.md` | Track author, URL, license, download date, changes, in-game use. |
| Shared material palette | Generated (original) | `res://assets/3d/materials/` | `mossy_stone.tres`, `water_stylized.tres`, and generated GLB materials cover jungle greens, dirt browns, mossy stone, gold, water, danger red, torch light. |
| Godot import presets | ❌ Not configured | Project import settings | Use `.glb`, texture compression, correct scale, loop flags for animations. |

---

## Priority 1 — Playable Explorers

| Asset | Status | Format | Target path | Notes |
| --- | --- | --- | --- | --- |
| Kairo playable explorer | ✅ Imported | `.glb` | `res://assets/3d/characters/kairo/kairo.glb` | `explorer` skin, default player model |
| Zuri playable explorer | ✅ Imported | `.glb` | `res://assets/3d/characters/zuri/zuri.glb` | `jungle_girl` skin, selectable in Shop |
| Monkey playable explorer | Generated (original, animated) | `.glb` | `res://assets/3d/characters/monkey/monkey.glb` | `monkey` skin; original scout-vest design with nine gameplay animation clips |
| Robot Explorer | Generated (original, animated) | `.glb` | `res://assets/3d/characters/robot/robot.glb` | `robot` skin; original steel/cyan expedition robot with nine gameplay animation clips |
| Treasure Hunter | Generated (original, animated) | `.glb` | `res://assets/3d/characters/treasure/treasure.glb` | `treasure` skin; original hat, satchel, map-tube, and backpack design |
| Tribal Adventurer | Generated (original, animated) | `.glb` | `res://assets/3d/characters/tribal/tribal.glb` | `tribal` skin; original fictional woven-adventure design with Sunstone accents |
| Golden Explorer | Generated (original, animated) | `.glb` | `res://assets/3d/characters/golden/golden.glb` | `golden` skin; original gold/obsidian design with emissive Sunstone accents |
| Shared explorer rig | ✅ Embedded | `.glb` | `res://assets/3d/characters/shared/` | Quaternius universal humanoid rig |
| Kairo character thumbnail | ❌ Missing | `.png` | `res://assets/3d/characters/kairo/kairo_thumb.png` | Shop / profile UI |
| Zuri character thumbnail | ❌ Missing | `.png` | `res://assets/3d/characters/zuri/zuri_thumb.png` | Shop / profile UI |

### Character Source Previews

| Character | Status | Format | Local path |
| --- | --- | --- | --- |
| Kairo | ✅ Available | `.jpg` 1220×720 | `res://assets/3d/characters/kairo/kairo_source_preview.jpg` |
| Zuri | ✅ Available | `.jpg` 1220×720 | `res://assets/3d/characters/zuri/zuri_source_preview.jpg` |
| Monkey | ✅ Generated | `.png` 1220×720 | `res://assets/3d/characters/monkey/monkey_source_preview.png` |
| Robot Explorer | ✅ Generated | `.png` 1220×720 | `res://assets/3d/characters/robot/robot_source_preview.png` |
| Treasure Hunter | ✅ Generated | `.png` 1220×720 | `res://assets/3d/characters/treasure/treasure_source_preview.png` |
| Tribal Adventurer | ✅ Generated | `.png` 1220×720 | `res://assets/3d/characters/tribal/tribal_source_preview.png` |
| Golden Explorer | ✅ Generated | `.png` 1220×720 | `res://assets/3d/characters/golden/golden_source_preview.png` |

### Kairo — Design Brief
Young African jungle explorer · lean, athletic · short dark hair · khaki/olive shirt, utility belt, cargo shorts · light boots and compact backpack · readable at third-person portrait camera distance.

### Zuri — Design Brief
Young African jungle adventurer · athletic, agile · tied-back hair or braided ponytail · practical fitted adventure top, satchel or harness, trek pants · boots and compact backpack · confident, intelligent pathfinder feel.

### Modular Clothing Variants

All seven playable explorers now share mode-specific clothing overlays instead of duplicating full character GLBs.

| Variant | Status | Format | Target path | Runtime condition |
| --- | --- | --- | --- | --- |
| Reinforced upgrade outfit | Generated (original, wired) | `.glb` | `res://assets/3d/outfits/upgrade/upgrade_outfit.glb` | Shown during normal running when the Sand Shoes upgrade is owned. |
| Protective skating outfit | Generated (original, wired) | `.glb` | `res://assets/3d/outfits/skating/skating_outfit.glb` | Shown when movement mode resolves to `skating`. |
| River/boat outfit | Generated (original, wired) | `.glb` | `res://assets/3d/outfits/boat/boat_outfit.glb` | Shown automatically during boat mode. |

---

## Priority 2 — Animation Library

Shared humanoid animation library used by both Kairo and Zuri.

| Motion | Status | Clip name | Source | Godot use |
| --- | --- | --- | --- | --- |
| Idle | ✅ Wired | `idle` | Quaternius embedded | Menus / ready state |
| Run forward | ✅ Wired | `run_forward` | Quaternius embedded | `Player3D.State.RUN` |
| Strafe left | ✅ Wired | `strafe_left` | Quaternius embedded | Lane change left |
| Strafe right | ✅ Wired | `strafe_right` | Quaternius embedded | Lane change right |
| Slide / roll | ✅ Wired | `slide` | Quaternius embedded | `Player3D.slide()` |
| Collect / interact | ✅ Wired | `collect` | Quaternius embedded | Coin / gem pickup |
| Stumble / hit | ✅ Wired | `hit` | Quaternius embedded | Obstacle contact |
| Victory | ✅ Wired | `victory` | Quaternius embedded | Finish gate |
| Defeat | ✅ Wired | `defeat` | Quaternius embedded | Game over |
| **Jump** | ❌ Missing | `jump` | Quaternius Universal Animation Library or custom | `Player3D.jump()` |
| **Land** | ❌ Missing | `land` | Quaternius or custom | Floor contact after jump |

---

## Priority 3 — Core Jungle Environment Kit

All items below are currently replaced by procedural `BoxMesh` / `CylinderMesh` in `LevelManager3D.gd`.

| Asset | Status | Format | Target path | Replacement for |
| --- | --- | --- | --- | --- |
| Dirt path straight segment | Generated (original) | `.glb` | `res://assets/3d/environment/path/dirt_path_straight.glb` | Ready to replace `_spawn_ground()` BoxMesh |
| Dirt path edge / grass blend | Generated (original) | `.glb` | `res://assets/3d/environment/path/dirt_path_edge.glb` | Ready to replace procedural grass strips |
| Grass clump set | Generated (original) | `.glb` | `res://assets/3d/environment/foliage/grass_clumps.glb` | Ready to replace `_grass_clump()` |
| Fern set | Generated (original) | `.glb` | `res://assets/3d/environment/foliage/ferns.glb` | Ready to replace `_fern()` |
| Bush set | Generated (original) | `.glb` | `res://assets/3d/environment/foliage/bushes.glb` | Ready to replace `_bush()` |
| Vine set | Generated (original) | `.glb` | `res://assets/3d/environment/foliage/vines.glb` | Ready to replace `_vine()` |
| Palm tree set | Generated (original) | `.glb` | `res://assets/3d/environment/trees/palms.glb` | Ready to replace `_palm_tree()` |
| Jungle tree set | Generated (original) | `.glb` | `res://assets/3d/environment/trees/jungle_trees.glb` | Ready to replace `_jungle_tree()` |
| Background tree cluster | Generated (original) | `.glb` | `res://assets/3d/environment/trees/tree_cluster_bg.glb` | Side tree cluster kit |
| Rock cluster set | Generated (original) | `.glb` | `res://assets/3d/environment/rocks/rock_clusters.glb` | Ready to replace procedural rock clusters |
| Mossy stone material | Generated (original) | `.tres` / textures | `res://assets/3d/materials/mossy_stone.tres` | Generated reusable mossy ruin material |

---

## Priority 4 — Level-Specific Dressing

| Level | Status | Missing assets | Notes |
| --- | --- | --- | --- |
| Level 1 — Jungle Trail Entrance | Generated kit available; runtime procedural | Palms, bright grass, coin-line dressing, small mossy gate | GLB kits now exist; wire into `LevelManager3D` when replacing procedural spawns. |
| Level 2 — Deeper Forest | Generated kit available; runtime procedural | Dense trees, hanging vines, thick bushes, roots, darker foliage variants, side monkeys/birds | GLB kits now exist; wire into `LevelManager3D` when replacing procedural spawns. |
| Level 3 — River Crossing | Generated kit available; runtime procedural | River water strips, bridge pieces, water-edge rocks, reeds, mud material, frog/butterfly ambience | GLB kits now exist; wire into `LevelManager3D` when replacing procedural spawns. |
| Level 4 — Ancient Jungle Ruins | Generated kit available; runtime procedural | Mossy stone path, pillars, broken walls, archways, carved stone props | GLB kits now exist; wire into `LevelManager3D` when replacing procedural spawns. |
| Level 5 — Temple Approach | Generated kit available; runtime procedural | Large gates, torches, statues, rolling boulder, treasure altar | GLB kits now exist; wire into `LevelManager3D` when replacing procedural spawns. |
| Level 6 — Wildlands of Peace | Generated kit available; runtime procedural | Sandy dirt path, savanna grass, distant wildlife silhouettes, finish altar | GLB kits now exist; wire into `LevelManager3D` when replacing procedural spawns. |
| Level 7 — First Clearing | Runtime procedural created | Settlement posts, crates, campfires | Distinct warm settlement theme; row-aligned side dressing in `LevelManager3D.gd`. |
| Level 8 — Foundation Run | Runtime procedural created | Settlement posts, crates, campfires | Construction-settlement theme; supplies and posts follow variable-width trail rows. |
| Level 9 — Timber Trail | Runtime procedural created | Settlement posts, crates, campfires | Darker forest settlement theme with side supplies and campfires. |
| Level 10 — Lost Paw Trail | Runtime procedural created | Wildlife silhouettes, tall grass | Savanna-edge theme; wind-reactive tall grass and distant antelope silhouettes. |
| Level 11 — Rabbit Tracks | Runtime procedural created | Wildlife silhouettes, tall grass | Lush wildlife-valley theme; wind-reactive tall grass and safe-distance animal dressing. |
| Level 12 — Water Slide Trail | Runtime procedural created | Gorge walls, water spray | Wet gorge theme; moss wall slabs and spray puffs follow the water-slide rows. |
| Level 13 — Park Guide Path | Runtime procedural created | Wildlife silhouettes, tall grass | Bright guide-route theme; tall grass and background wildlife are kept outside active lanes. |
| Level 14 — Warthog Watch | Runtime procedural created | Market stalls, lanterns, reeds | Warm market/river-edge dressing with stall frames, lanterns, and wind-reactive reeds. |
| Level 15 — Market Skate & River Dock | Runtime procedural created | Market stalls, lanterns, reeds | Market-to-dock theme; side stalls, lanterns, reeds, skating/river transition dressing. |
| Level 16 — Antelope Trail | Runtime procedural created | Fallen logs, earth mounds | Dark escape-route theme; fallen logs and disturbed mounds placed along trail sides. |
| Level 17 — Rapids Run | Runtime procedural created | River boulders, mist | Rapids/boat theme; dark river boulders and mist wisps line the banks. |
| Level 18 — Hound of the Hidden Trail | Runtime procedural created | Glowing relic tablets | Purple-grey relic theme; emissive tablets are animated through the relic-glow pulse system. |
| Level 19 — Boar Escape | Runtime procedural created | Fallen logs, earth mounds | Red-brown panic-route theme; fallen logs and disturbed mounds support the escape mood. |
| Level 20 — Treasure Beneath the Baobab | Runtime procedural created | Baobab trunks, gold relics | Gold-amber finale theme; huge baobab trunks and pulsing gold relic glints. |

---

## Priority 5 — Obstacles and Gameplay Props

| Asset | Status | Format | Target path | Current placeholder |
| --- | --- | --- | --- | --- |
| Fallen log obstacle | Generated (original) | `.glb` | `res://assets/3d/obstacles/fallen_log.glb` | Low-poly jump log |
| Single-lane rock obstacle | Generated (original) | `.glb` | `res://assets/3d/obstacles/rock_obstacle.glb` | Low-poly rock cluster |
| Spike trap | Generated (original) | `.glb` | `res://assets/3d/obstacles/spike_trap.glb` | Temple stake trap |
| Mud patch | Generated (original) | `.glb` or decal | `res://assets/3d/obstacles/mud_patch.glb` | Low-poly mud patch |
| River gap kit | Generated (original) | `.glb` | `res://assets/3d/obstacles/river_gap/river_gap_kit.glb` | Water strip and banks for `_remove_ground_at()` visuals |
| Wooden bridge segment | Generated (original) | `.glb` | `res://assets/3d/environment/bridges/wood_bridge.glb` | Low-poly bridge segment |
| Broken bridge segment | Generated (original) | `.glb` | `res://assets/3d/environment/bridges/broken_bridge.glb` | Low-poly broken bridge segment |
| Rolling boulder | Generated (original) | `.glb` | `res://assets/3d/obstacles/rolling_boulder.glb` | Low-poly boulder |
| Slide-under barrier / vine | Generated (original) | `.glb` | `res://assets/3d/obstacles/slide_barrier.glb` | Low branch with hanging vines |
| Temple pressure plate | Generated (original) | `.glb` | `res://assets/3d/obstacles/pressure_plate.glb` | Low-poly stone pressure plate |
| Sand dune obstacle (Level 6) | Generated (original) | `.glb` | `res://assets/3d/obstacles/sand_dune.glb` | Low-poly sand dune |

---

## Priority 6 — Finish Gates, Portals, and Rewards

| Asset | Status | Format | Target path | Current placeholder |
| --- | --- | --- | --- | --- |
| Level 1 jungle gate | Generated (original) | `.glb` | `res://assets/3d/goals/jungle_gate.glb` | Low-poly mossy stone gate |
| Level 2 vine ruin arch | Generated (original) | `.glb` | `res://assets/3d/goals/vine_ruin_arch.glb` | Low-poly vine arch |
| Level 3 bridge-end marker | Generated (original) | `.glb` | `res://assets/3d/goals/river_gate.glb` | Low-poly river gate with glow |
| Level 4 temple doorway | Generated (original) | `.glb` | `res://assets/3d/goals/temple_doorway.glb` | Low-poly temple doorway |
| Level 5 glowing temple portal | Generated (original) | `.glb` + VFX | `res://assets/3d/goals/temple_portal.glb` | Low-poly portal, pair with `finish_glow.tscn` |
| Level 6 wildlands altar | Generated (original) | `.glb` | `res://assets/3d/goals/wildlands_altar.glb` | Low-poly sun altar |
| Treasure chest | Generated (original) | `.glb` | `res://assets/3d/rewards/treasure_chest.glb` | Low-poly reward chest |
| Relic altar | Generated (original) | `.glb` | `res://assets/3d/rewards/relic_altar.glb` | Low-poly relic altar with Sunstone |

---

## Priority 7 — Collectibles (In-game Pickups)

The collectible GLBs and all ten requested 2D resource icons are now present. Windows and map pieces remain intentionally UI-only because they are not spawned as in-lane pickups.

| Collectable | ID | 3D GLB Status | Icon PNG Status | 3D target path | Icon target path |
| --- | --- | --- | --- | --- | --- |
| **Coin** | `coins` | Generated (original) | ✅ Emoji 🪙 | `res://assets/3d/collectibles/coin.glb` | — |
| **Gem** | `gems` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/gem.glb` | `res://assets/ui/icons/icon_gem.png` |
| **Bricks** | `bricks` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/brick.glb` | `res://assets/ui/icons/icon_bricks.png` |
| **Wood** | `wood` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/wood.glb` | `res://assets/ui/icons/icon_wood.png` |
| **Tiles** | `tiles` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/tile.glb` | `res://assets/ui/icons/icon_tiles.png` |
| **Windows** | `windows` | ❌ UI only | ✅ Generated 32×32 RGBA | — | `res://assets/ui/icons/icon_windows.png` |
| **Food** | `food` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/food.glb` | `res://assets/ui/icons/icon_food.png` |
| **Tools** | `tools` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/tools.glb` | `res://assets/ui/icons/icon_tools.png` |
| **Relic Key** | `relic_keys` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/relic_key.glb` | `res://assets/ui/icons/icon_relic_key.png` |
| **Sunstone Shard** | `sunstone_shards` | Generated (original) | ✅ Generated 32×32 RGBA | `res://assets/3d/collectibles/sunstone_shard.glb` | `res://assets/ui/icons/icon_sunstone_shard.png` |
| **Map Piece** | `map_pieces` | ❌ UI only | ✅ Generated 32×32 RGBA | — | `res://assets/ui/icons/icon_map_piece.png` |

**Icon spec:** 32×32 PNG, transparent background, CC0 preferred.  
**3D spec:** Low-poly GLB, single mesh, no rig needed — uses existing `Area3D` pickup logic in `_spawn_coin()`.  
**Source suggestion:** Kenney Game Icons (CC0) for 2D icons; Quaternius Survival / RPG / Treasure packs for 3D props.

---

## Priority 8 — Wildlife

All wildlife is decorative / background. Level 6 "Wildlands of Peace" wildlife is strictly non-hazard.  
The Big 5 are the primary wildlife milestone for v1 release.

### The Big 5 (Priority 8A — Level 6 Wildlands)

| Animal | Status | Format | Target path | In-game role |
| --- | --- | --- | --- | --- |
| **African Elephant** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/elephant.glb` | Background wanderer, Level 6. Non-hazard. Animation loop still future polish. |
| **Lion** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/lion.glb` | Distant background, Level 6 wildlands. Never in the path. Animation loop still future polish. |
| **Leopard** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/leopard.glb` | Side dressing Level 6 / Level 4 ruins. Animation loop still future polish. |
| **Cape Buffalo** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/cape_buffalo.glb` | Background herd, Level 6. Non-hazard. Animation loop still future polish. |
| **White Rhinoceros** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/rhino.glb` | Background grazing, Level 6 wildlands. Animation loop still future polish. |

> **Design rule — Big 5 in Wildlands of Peace:**  
> All five animals are African wildlife encountered peacefully. They must never occupy a gameplay lane. Place them at distance (z > 4.0 from path centre) with a slow idle loop. This reinforces the game's educational message about human-wildlife coexistence.

### Supporting Wildlife (Priority 8B — Levels 1–6)

| Animal | Status | Format | Target path | In-game role |
| --- | --- | --- | --- | --- |
| **Warthog** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/warthog.glb` | Level 6 side-path wanderer. Animation loop still future polish. |
| **Parrot / Tropical Bird** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/bird.glb` | Levels 1–2 canopy ambience. Animation loop still future polish. |
| **Butterfly** | Generated (original static GLB) | `.glb` or particle | `res://assets/3d/wildlife/butterfly.glb` | Level 1–2 low flight ambience. |
| **Monkey** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/monkey.glb` | Side dressing, Levels 1–2. Animation loop still future polish. |
| **Frog** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/frog.glb` | River edge ambience, Level 3. Animation loop still future polish. |
| **Snake** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/snake.glb` | Side hazard or dressing, optional. Animation loop still future polish. |
| **Weaver Bird / Sparrow flock** | Generated (original static GLB) | `.glb` or particle flock | `res://assets/3d/wildlife/weaver_bird.glb` | Level 6 distant sky flock. Animation loop still future polish. |
| **Crocodile** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/crocodile.glb` | Level 3 river bank. Non-hazard background. Animation loop still future polish. |
| **Zebra** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/zebra.glb` | Level 6 wildlands herd. Animation loop still future polish. |
| **Giraffe** | Generated (original static GLB) | `.glb` | `res://assets/3d/wildlife/giraffe.glb` | Level 6 skyline silhouette. Animation loop still future polish. |

---

## Priority 9 — VFX and Environmental Motion

| Effect | Status | Format | Target path | Notes |
| --- | --- | --- | --- | --- |
| Foliage sway | Generated (original) | shader | `res://assets/3d/vfx/foliage_sway.gdshader` | Subtle, cheap, reusable on all foliage. |
| Runtime trail ring buffer | Generated (original, wired) | `MeshInstance3D` particles | `res://scripts/gameplay/Player3D.gd` | 10-node world-space ring buffer for leaf, firefly, sparkle, dust, and splash trails; older nodes fade and shrink. |
| Pressed grass trail marks | Generated (original, wired) | procedural meshes | `res://scripts/gameplay/LevelManager3D.gd` / `Player3D.gd` | Player footsteps stamp temporary flattened grass marks on grass surfaces. |
| Water material | Generated (original) | `.tres` / shader | `res://assets/3d/materials/water_stylized.tres` | Transparent stylized water material. |
| Torch flame | Generated (original) | `GPUParticles3D` | `res://assets/3d/vfx/torch_flame.tscn` | Level 5 temple torches. Use sparingly. |
| Finish glow | Generated (original) | `GPUParticles3D` | `res://assets/3d/vfx/finish_glow.tscn` | Portal / gate reward effect. |
| Coin pickup sparkle | Generated (original) | `GPUParticles3D` | `res://assets/3d/vfx/pickup_sparkle.tscn` | Pickup feedback. |
| Dust puffs | Generated (original) | `GPUParticles3D` | `res://assets/3d/vfx/dust_puff.tscn` | Jump / land / slide / sand trail. |
| Hit burst | Generated (original) | `GPUParticles3D` | `res://assets/3d/vfx/hit_burst.tscn` | Obstacle feedback. |
| Sand trail (Level 6) | Generated (original) | `GPUParticles3D` | `res://assets/3d/vfx/sand_trail.tscn` | Footstep dust on sandy surface. |

---

## Priority 10 — Upgrades and Shop Items

| Asset | Status | Format | Target path | Notes |
| --- | --- | --- | --- | --- |
| **Sand Shoes icon** | Generated (original, wired) | `.png` 32×32 RGBA | `res://assets/ui/icons/sand_shoes_icon.png` | Used by the Sand Shoes popup in `LevelSelect.gd`, with emoji fallback retained. |
| Sand Shoes 3D prop | Generated (original) | `.glb` | `res://assets/3d/upgrades/sand_shoes.glb` | Standalone shop/preview prop. |
| Equipped upgrade clothing | Generated (original, wired) | `.glb` | `res://assets/3d/outfits/upgrade/upgrade_outfit.glb` | Reinforced vest, utility gear, wrist guards, field pack, and sand boots shown on the active player after purchase. |

---

## Priority 11 — Home Building Stage Images

6-stage progression shown in `HomeBuilding.tscn`. Procedural fallback currently in place.

| Stage | Name | Status | Target path |
| --- | --- | --- | --- |
| 0 | Empty Land | ❌ Missing | `res://assets/ui/home/stage_0_land.png` |
| 1 | Buy Land (flag) | ❌ Missing | `res://assets/ui/home/stage_1_flag.png` |
| 2 | Foundation | ❌ Missing | `res://assets/ui/home/stage_2_foundation.png` |
| 3 | Walls | ❌ Missing | `res://assets/ui/home/stage_3_walls.png` |
| 4 | Roof & Tiles | ❌ Missing | `res://assets/ui/home/stage_4_roof.png` |
| 5 | Windows | ❌ Missing | `res://assets/ui/home/stage_5_windows.png` |
| 6 | Complete Home | ❌ Missing | `res://assets/ui/home/stage_6_complete.png` |

All images: 320×240 PNG. Style: simple stylized illustration showing progressive construction. African-inspired architecture (warm earth tones, tiled roof, open porch).

---

## Priority 12 — UI Visual Support

| Asset | Status | Format | Target path | Notes |
| --- | --- | --- | --- | --- |
| **Jungle Map background** | ❌ Missing | `.png` 480×854 | `res://assets/backgrounds/bg_jungle_map.png` | **HIGHEST UI PRIORITY.** Full-screen illustrated expedition map with 5 zones (wildlands → temple → ruins → river → jungle entrance). Replaces procedural ColorRect map in `LevelSelect.gd`. |
| Fog / mist overlay | ❌ Missing | `.png` 480×180 | `res://assets/backgrounds/bg_fog_overlay.png` | Semi-transparent overlay for locked wildlands zone. |
| Character select renders | ❌ Missing | `.png` | `res://assets/ui/characters/` | Kairo and Zuri full-body renders for Shop screen. |
| Level card renders | ❌ Missing | `.png` | `res://assets/ui/level_cards/` | One card per 6 levels for level select preview. |
| Play Store screenshots | ❌ Not yet | `.png` | external/exported | Capture only after placeholder geometry is replaced. |
| Feature graphic art | ❌ Not yet | `.png` 1024×500 | external/exported | Use final 3D characters and jungle / temple scene. |
| Water token icon | Generated (original, wired) | `.png` 32×32 RGBA | `res://assets/ui/icons/water_token_icon.png` | Wired through `Constants.RESOURCES` and `LevelComplete3D.gd`. |
| Fish token icon | Generated (original, wired) | `.png` 32×32 RGBA | `res://assets/ui/icons/fish_token_icon.png` | Wired through `Constants.RESOURCES` and `LevelComplete3D.gd`. |
| River relic icon | Generated (original, wired) | `.png` 32×32 RGBA | `res://assets/ui/icons/river_relic_icon.png` | Wired through `Constants.RESOURCES` and `LevelComplete3D.gd`. |
| Animal badge icon | Generated (original, wired) | `.png` 32×32 RGBA | `res://assets/ui/icons/animal_badge_icon.png` | Wired through `Constants.RESOURCES` and `LevelComplete3D.gd`. |
| Trade token icon | Generated (original, wired) | `.png` 32×32 RGBA | `res://assets/ui/icons/trade_token_icon.png` | Wired through `Constants.RESOURCES` and `LevelComplete3D.gd`. |

---

## Priority 13 — Audio Gaps

| Asset | Status | Format | Target path |
| --- | --- | --- | --- |
| Jungle ambience loop | ❌ Missing | `.ogg` | `res://assets/sounds/jungle_ambience.ogg` |
| Runner footstep set | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/footstep_dirt_*.ogg` |
| Jump whoosh | Generated (original, wired) | `.wav` 22050 Hz 16-bit PCM | `res://assets/sounds/jump.wav` |
| Slide swoosh | Generated (original, wired) | `.wav` 22050 Hz 16-bit PCM | `res://assets/sounds/slide.wav` |
| Land thud | Generated (original, wired) | `.wav` 22050 Hz 16-bit PCM | `res://assets/sounds/land.wav` |
| Coin pickup | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/coin.ogg` |
| Gem pickup | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/gem.ogg` |
| Hit / stumble | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/hit.ogg` |
| Victory fanfare | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/level_complete.ogg` |
| Defeat sting | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/game_over.ogg` |
| Wildlands ambience (savanna wind, distant birds) | ❌ Missing | `.ogg` | `res://assets/sounds/wildlands_ambience.ogg` |

---

## Source Shortlist

| Source | Best for | License |
| --- | --- | --- |
| Quaternius (quaternius.com) | Characters, animations, nature, animals, RPG/treasure props | CC0 |
| Kenney (kenney.nl) | Nature Kit, Platformer Kit, UI/audio, icons | CC0 |
| Poly Pizza (poly.pizza) | Extra low-poly props, trees, animals — verify each model license | Mixed (mostly CC0/CC-BY) |
| OpenGameArt (opengameart.org) | Last resort — verify each license; reject GPL/LGPL/CC-BY-SA | Mixed |

---

## Integration Checklist

1. Import model under `res://assets/3d/` at the listed path.
2. Create a `PackedScene` wrapper when collision, animation, or metadata is needed.
3. Replace `LevelManager3D` procedural spawn call with `preload()` + `instantiate()`.
4. Keep the existing `Area3D` / signal structure — don't change pickup logic.
5. Verify performance on Android after each dense dressing pass.
6. Log every asset in `ASSET_LICENSES.md` before committing.

---

## License Rules

Every imported third-party asset must have:
- Source URL · Author/creator · License name · Download date · Local path · Modified/unmodified note · Attribution text if required.

Do not ship assets with GPL, LGPL, CC-BY-SA, or unclear licenses.
