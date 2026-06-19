# 3D Asset Manifest — Jungle Escape: Lost Path

Status key: ✅ Available/imported · 🔧 Procedural placeholder (functional, not final) · ❌ Missing (blocks visual polish or feature) · Generated (original) Project-authored runtime GLB/resource

This file is the production asset manifest. `res://` maps to the project root.  
Every new import must have a corresponding entry in `ASSET_LICENSES.md`.

Generated assets were created by `tools/generate_missing_3d_assets.py`. They are original low-poly project assets, not third-party downloads. Godot still needs to import them in-editor before `.import` metadata exists.

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
| Shared explorer rig | ✅ Embedded | `.glb` | `res://assets/3d/characters/shared/` | Quaternius universal humanoid rig |
| Kairo character thumbnail | ❌ Missing | `.png` | `res://assets/3d/characters/kairo/kairo_thumb.png` | Shop / profile UI |
| Zuri character thumbnail | ❌ Missing | `.png` | `res://assets/3d/characters/zuri/zuri_thumb.png` | Shop / profile UI |

### Kairo — Design Brief
Young African jungle explorer · lean, athletic · short dark hair · khaki/olive shirt, utility belt, cargo shorts · light boots and compact backpack · readable at third-person portrait camera distance.

### Zuri — Design Brief
Young African jungle adventurer · athletic, agile · tied-back hair or braided ponytail · practical fitted adventure top, satchel or harness, trek pants · boots and compact backpack · confident, intelligent pathfinder feel.

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

Coins have a functional procedural placeholder. All others need both a 3D GLB (in-lane pickup mesh) and a 2D icon PNG (HUD, shop, level complete screen).

| Collectable | ID | 3D GLB Status | Icon PNG Status | 3D target path | Icon target path |
| --- | --- | --- | --- | --- | --- |
| **Coin** | `coins` | Generated (original) | ✅ Emoji 🪙 | `res://assets/3d/collectibles/coin.glb` | — |
| **Gem** | `gems` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/gem.glb` | `res://assets/ui/icons/icon_gem.png` |
| **Bricks** | `bricks` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/brick.glb` | `res://assets/ui/icons/icon_bricks.png` |
| **Wood** | `wood` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/wood.glb` | `res://assets/ui/icons/icon_wood.png` |
| **Tiles** | `tiles` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/tile.glb` | `res://assets/ui/icons/icon_tiles.png` |
| **Windows** | `windows` | ❌ UI only | ❌ Missing | — | `res://assets/ui/icons/icon_windows.png` |
| **Food** | `food` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/food.glb` | `res://assets/ui/icons/icon_food.png` |
| **Tools** | `tools` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/tools.glb` | `res://assets/ui/icons/icon_tools.png` |
| **Relic Key** | `relic_keys` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/relic_key.glb` | `res://assets/ui/icons/icon_relic_key.png` |
| **Sunstone Shard** | `sunstone_shards` | Generated (original) | ❌ Missing | `res://assets/3d/collectibles/sunstone_shard.glb` | `res://assets/ui/icons/icon_sunstone_shard.png` |
| **Map Piece** | `map_pieces` | ❌ UI only | ❌ Missing | — | `res://assets/ui/icons/icon_map_piece.png` |

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
| **Sand Shoes icon** | ❌ Missing | `.png` 64×64 | `res://assets/ui/upgrades/sand_shoes_icon.png` | Shown in Shop, popup, confirmation. Dusty/worn boot. |
| Sand Shoes 3D prop | Generated (original) | `.glb` | `res://assets/3d/upgrades/sand_shoes.glb` | Optional equip visual on player feet in Level 6. |

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

---

## Priority 13 — Audio Gaps

| Asset | Status | Format | Target path |
| --- | --- | --- | --- |
| Jungle ambience loop | ❌ Missing | `.ogg` | `res://assets/sounds/jungle_ambience.ogg` |
| Runner footstep set | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/footstep_dirt_*.ogg` |
| Jump whoosh | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/jump.ogg` |
| Slide swoosh | ❌ Missing | `.wav`/`.ogg` | `res://assets/sounds/slide.ogg` |
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
