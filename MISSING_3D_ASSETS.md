# Missing 3D Assets - Jungle Escape: Lost Path

Current state: the 3D runner is functional, the first two playable character GLBs are imported, and Level 1 now has a tested procedural low-poly jungle art pass in `LevelManager3D.gd`. The game no longer relies on a flat green field for Level 1, but final imported GLB environment packs are still needed before Play Store screenshots or public testing.

This file is the production asset manifest for the Godot project. `res://` maps to this project root.

## Priority 0 - Asset Pipeline Setup

| Missing item | Target path | Notes |
| --- | --- | --- |
| Environment asset folder structure | `res://assets/3d/environment/`, `res://assets/3d/obstacles/`, `res://assets/3d/collectibles/`, `res://assets/3d/wildlife/`, `res://assets/3d/vfx/`, `res://assets/3d/materials/` | Character folders exist. Add these folders when replacing procedural meshes with imported GLB kits. |
| Root asset license ledger | `res://ASSET_LICENSES.md` | Created. Keep it updated for every imported third-party asset. |
| 3D asset credit ledger | `res://assets/3d/ASSET_CREDITS.md` | Exists for imported characters. Continue to track author, source URL, license, download date, changes, and in-game use. |
| Shared material palette | `res://assets/3d/materials/` | Jungle greens, dirt browns, mossy stone, gold, water, danger accent, torch light. |
| Godot import presets | Project import settings | Use `.glb`, texture compression, correct scale, loop flags for animation clips. |

## Priority 1 - Playable Explorers

| Asset | Format | Target path | Source priority | Where used |
| --- | --- | --- | --- | --- |
| Kairo playable explorer | `.glb` | `res://assets/3d/characters/kairo/kairo.glb` | Imported from Quaternius / Poly Pizza | `explorer` skin, default `Game3D.tscn` player model |
| Zuri playable explorer | `.glb` | `res://assets/3d/characters/zuri/zuri.glb` | Imported from Quaternius / Poly Pizza | `jungle_girl` skin, selectable through existing Shop skin flow |
| Shared explorer rig | `.glb` or embedded | `res://assets/3d/characters/shared/` | Quaternius universal humanoid rig | Animation retargeting |
| Kairo character thumbnail | `.png` | `res://assets/3d/characters/kairo/kairo_thumb.png` | Render from final model | Shop/profile/selection UI |
| Zuri character thumbnail | `.png` | `res://assets/3d/characters/zuri/zuri_thumb.png` | Render from final model | Shop/profile/selection UI |

### Kairo Requirements

- Young jungle explorer
- Lean athletic build
- Short dark hair
- Confident, heroic, agile silhouette
- Khaki/olive shirt, utility belt, cargo shorts or fitted trousers
- Light boots and compact backpack
- Readable from third-person portrait camera

### Zuri Requirements

- Young jungle adventurer
- Athletic agile build
- Tied-back hair or braided ponytail
- Practical fitted adventure top
- Satchel or harness, trek pants or shorts
- Boots and compact backpack
- Confident, intelligent pathfinder feel

## Priority 2 - Animation Library

Use one shared humanoid animation library for both avatars.

| Required motion | Format | Target clip name | Source priority | Godot use |
| --- | --- | --- | --- | --- |
| Idle | embedded or `.glb` | `idle` | Quaternius Universal Animation Library | Menus/ready state |
| Run forward | embedded or `.glb` | `run_forward` | Quaternius | `Player3D.State.RUN` |
| Strafe left | embedded or `.glb` | `strafe_left` | Quaternius directional locomotion | lane change left |
| Strafe right | embedded or `.glb` | `strafe_right` | Quaternius directional locomotion or mirrored left | lane change right |
| Jump | embedded or `.glb` | `jump` | Quaternius | `Player3D.jump()` |
| Land | embedded or `.glb` | `land` | Quaternius or custom | floor contact after jump |
| Slide | embedded or `.glb` | `slide` | Quaternius crawl/slide if suitable; custom if not | `Player3D.slide()` |
| Collect | embedded or `.glb` | `collect` | Quaternius emote/reach or custom additive | coin/gem pickup |
| Stumble/hit | embedded or `.glb` | `hit` | Quaternius hit/stumble/death set | obstacle contact |
| Victory | embedded or `.glb` | `victory` | Quaternius emote | finish gate |
| Defeat | embedded or `.glb` | `defeat` | Quaternius death/fall | game over |

Current animation wiring: `Player3D.gd` now plays imported character animations for run, left/right strafe, slide/roll, collect/interact, hit, victory, and defeat where the GLB provides matching clips. A dedicated jump and land clip still need to be sourced from a broader animation library or authored later.

## Priority 3 - Core Jungle Environment Kit

| Asset | Format | Target path | Replacement for |
| --- | --- | --- | --- |
| Final dirt path straight segment | `.glb` | `res://assets/3d/environment/path/dirt_path_straight.glb` | Procedural dirt path in `_spawn_ground()` |
| Final dirt path edge/grass blend | `.glb` or material | `res://assets/3d/environment/path/` | Procedural grass strips and path details |
| Final grass clump set | `.glb` | `res://assets/3d/environment/foliage/grass_clumps.glb` | Procedural grass clumps in `_grass_clump()` |
| Final fern set | `.glb` | `res://assets/3d/environment/foliage/ferns.glb` | Procedural ferns in `_fern()` |
| Final bush set | `.glb` | `res://assets/3d/environment/foliage/bushes.glb` | Procedural bushes in `_bush()` |
| Final vine set | `.glb` | `res://assets/3d/environment/foliage/vines.glb` | Procedural vines in `_vine()` |
| Final palm tree set | `.glb` | `res://assets/3d/environment/trees/palms.glb` | Procedural palms in `_palm_tree()` |
| Final jungle tree set | `.glb` | `res://assets/3d/environment/trees/jungle_trees.glb` | Procedural trees in `_jungle_tree()` |
| Final background tree cluster | `.glb` | `res://assets/3d/environment/trees/tree_cluster_bg.glb` | Procedural side trees exist; final distant clusters still needed |
| Final rock cluster set | `.glb` | `res://assets/3d/environment/rocks/` | Procedural rock clusters and obstacle rocks |
| Mossy stone material | `.tres` / textures | `res://assets/3d/materials/mossy_stone.tres` | Procedural mossy ruin/gate color blocks |

## Priority 4 - Level-Specific Dressing

| Level | Missing assets | Notes |
| --- | --- | --- |
| Level 1 - Jungle Trail Entrance | Welcoming palms, bright grass, simple logs, coin-line dressing, small mossy gate | Baseline screenshot quality level. |
| Level 2 - Deeper Forest | Dense trees, hanging vines, thick bushes, roots, darker foliage variants, side monkeys/birds | Must feel denser without hiding obstacles. |
| Level 3 - River Crossing | River water strips, bridge pieces, water-edge rocks, reeds, mud material, frog/butterfly ambience | Requires real bridge and river gap visuals. |
| Level 4 - Ancient Jungle Ruins | Mossy stone path, pillars, broken walls, archways, stairs, temple spikes, carved stone props | `data/levels3d/level3d_004.json` exists. |
| Level 5 - Temple Approach | Large gates, torches, statues, rolling boulder, treasure altar/portal, richer coin/gem placement | `data/levels3d/level3d_005.json` exists. |
| Level 6 - Wildlands of Peace | Sandy dirt path, savanna grass edges, open-sky atmosphere, sand dune dressing, distant wildlife silhouettes, finish altar | `data/levels3d/level3d_006.json` exists. Sandy theme in `LevelManager3D` sets warm terrain colors. |

## Priority 5 - Obstacles and Gameplay Props

| Asset | Format | Target path | Current placeholder |
| --- | --- | --- | --- |
| Final fallen log obstacle | `.glb` | `res://assets/3d/obstacles/fallen_log.glb` | Procedural cylindrical jump log |
| Final single-lane rock obstacle | `.glb` | `res://assets/3d/obstacles/rock_obstacle.glb` | Procedural low-poly rock cluster |
| Final spike trap | `.glb` | `res://assets/3d/obstacles/spike_trap.glb` | Procedural temple stakes |
| Mud patch | `.glb` or material decal | `res://assets/3d/obstacles/mud_patch.glb` | Flat brown BoxMesh |
| River gap kit | `.glb` | `res://assets/3d/obstacles/river_gap/` | `_remove_ground_at()` stub |
| Wooden bridge segment | `.glb` | `res://assets/3d/environment/bridges/wood_bridge.glb` | Missing |
| Broken bridge segment | `.glb` | `res://assets/3d/environment/bridges/broken_bridge.glb` | Missing |
| Rolling boulder | `.glb` | `res://assets/3d/obstacles/rolling_boulder.glb` | Missing |
| Final slide-under barrier/vine | `.glb` | `res://assets/3d/obstacles/slide_barrier.glb` | Procedural low branch exists and Level 1 uses it |
| Temple pressure plate | `.glb` | `res://assets/3d/obstacles/pressure_plate.glb` | Missing |

## Priority 6 - Finish Gates, Portals, and Rewards

| Asset | Format | Target path | Current placeholder |
| --- | --- | --- | --- |
| Final Level 1 jungle gate | `.glb` | `res://assets/3d/goals/jungle_gate.glb` | Procedural mossy stone temple gate with torches and glow |
| Level 2 vine ruin arch | `.glb` | `res://assets/3d/goals/vine_ruin_arch.glb` | Gold BoxMesh posts/bar |
| Level 3 bridge-end marker | `.glb` | `res://assets/3d/goals/river_gate.glb` | Gold BoxMesh posts/bar |
| Level 4 temple doorway | `.glb` | `res://assets/3d/goals/temple_doorway.glb` | Missing |
| Level 5 glowing temple portal | `.glb` + VFX | `res://assets/3d/goals/temple_portal.glb` | Missing |
| Treasure chest | `.glb` | `res://assets/3d/rewards/treasure_chest.glb` | Missing |
| Reward altar/relic | `.glb` | `res://assets/3d/rewards/relic_altar.glb` | Missing |

## Priority 7 - Collectibles

| Asset | Format | Target path | Current placeholder |
| --- | --- | --- | --- |
| Final gold coin | `.glb` | `res://assets/3d/collectibles/coin.glb` | Procedural rotating/bobbing coin cylinder |
| Final blue gem | `.glb` | `res://assets/3d/collectibles/gem.glb` | Procedural rotating/bobbing gem |
| Pickup sparkle | `GPUParticles3D` / scene | `res://assets/3d/vfx/pickup_sparkle.tscn` | Missing |
| Coin line marker variant | `.glb` or material | `res://assets/3d/collectibles/coin_line_marker.glb` | Missing |

## Priority 8 - Wildlife

| Asset | Format | Target path | Use |
| --- | --- | --- | --- |
| Final parrot/bird | `.glb` with loop animation | `res://assets/3d/wildlife/bird.glb` | Procedural parrot flyover exists for Level 1 ambience |
| Final butterfly | `.glb` or particle | `res://assets/3d/wildlife/butterfly.glb` | Procedural butterflies exist for Level 1 ambience |
| Monkey | `.glb` with idle loop | `res://assets/3d/wildlife/monkey.glb` | Side dressing Levels 1–2 |
| Frog | `.glb` with idle/jump | `res://assets/3d/wildlife/frog.glb` | River edge ambience Level 3 |
| Snake | `.glb` with idle/strike | `res://assets/3d/wildlife/snake.glb` | Side dressing or hazard |
| **Elephant** | `.glb` with slow walk loop | `res://assets/3d/wildlife/elephant.glb` | **Level 6 Wildlands — background, non-hazard, peaceful coexistence story** |
| **Warthog** | `.glb` with trot/idle | `res://assets/3d/wildlife/warthog.glb` | **Level 6 Wildlands — side-path wanderer, peaceful** |
| **Weaver bird / sparrow** | `.glb` or particle flock | `res://assets/3d/wildlife/weaver_bird.glb` | Level 6 distant sky flock |

Wildlife must not overload gameplay lanes. Keep it outside the path unless it is a deliberate hazard with clear telegraphing.
Level 6 wildlife is strictly non-hazard. The "Wildlands of Peace" story requires animals and people to share the path peacefully.

## Priority 9 - VFX and Environmental Motion

| Asset/effect | Format | Target path | Notes |
| --- | --- | --- | --- |
| Foliage sway | shader or script | `res://assets/3d/vfx/foliage_sway.gdshader` | Subtle, cheap, reusable. |
| Water material | `.tres` / shader | `res://assets/3d/materials/water_stylized.tres` | Scroll UVs or simple sine motion. |
| Torch flame | `GPUParticles3D` / mesh animation | `res://assets/3d/vfx/torch_flame.tscn` | Use sparingly; avoid many dynamic lights. |
| Finish glow | `GPUParticles3D` / mesh | `res://assets/3d/vfx/finish_glow.tscn` | Portal/gate reward effect. |
| Dust puffs | `GPUParticles3D` | `res://assets/3d/vfx/dust_puff.tscn` | Jump/land/slide/rolling boulder. |
| Hit burst | `GPUParticles3D` | `res://assets/3d/vfx/hit_burst.tscn` | Obstacle feedback. |

## Priority 9b - Upgrade Item Models

These items are awarded or purchased by the player and may appear in HUD, shop UI, or as 3D props.

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| **Sand Shoes** icon/3D prop | `.png` or `.glb` | `res://assets/ui/upgrades/sand_shoes_icon.png` | Shown in Shop, Sand Shoes popup, upgrade confirmation. Sandy/worn boot texture. |
| Bricks collectible | `.glb` or `.png` icon | `res://assets/3d/collectibles/brick.glb` | Resource pickup for Home Building system |
| Wood collectible | `.glb` or `.png` icon | `res://assets/3d/collectibles/wood.glb` | Resource pickup |
| Tile collectible | `.glb` or `.png` icon | `res://assets/3d/collectibles/tile.glb` | Resource pickup |
| Window collectible | `.png` icon | `res://assets/ui/collectibles/window_icon.png` | UI only; small item |
| Food collectible | `.glb` or `.png` icon | `res://assets/3d/collectibles/food.glb` | Canned/packaged food prop |
| Tools collectible | `.glb` or `.png` icon | `res://assets/3d/collectibles/tools.glb` | Wrench/tool prop |
| Relic Key | `.glb` or `.png` icon | `res://assets/3d/collectibles/relic_key.glb` | Ancient key with carved handle |
| Sunstone Shard | `.glb` or `.png` icon | `res://assets/3d/collectibles/sunstone_shard.glb` | Glowing amber crystal shard |
| Map Piece | `.png` icon | `res://assets/ui/collectibles/map_piece_icon.png` | Torn parchment fragment |

## Priority 9c - Home Building Stages

The First Land / Home Building system has 6 build stages. UI mockups show a simple house silhouette filling in over 6 stages. Final art optional for v1; procedural or 2D illustration acceptable first.

| Stage | Name | Key visual element | Target path |
| --- | --- | --- | --- |
| 0 | Empty Land | Bare sandy plot | `res://assets/ui/home/stage_0_land.png` |
| 1 | Buy Land | Plot marker / flag | `res://assets/ui/home/stage_1_flag.png` |
| 2 | Foundation | Stone/brick slab | `res://assets/ui/home/stage_2_foundation.png` |
| 3 | Walls | Low walls, no roof | `res://assets/ui/home/stage_3_walls.png` |
| 4 | Roof & Tiles | Tiled roof added | `res://assets/ui/home/stage_4_roof.png` |
| 5 | Windows | Windows in walls | `res://assets/ui/home/stage_5_windows.png` |
| 6 | Complete Home | Full house with door, windows, garden | `res://assets/ui/home/stage_6_complete.png` |

## Priority 10 - UI and Store Visual Support

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Character select renders | `.png` | `res://assets/ui/characters/` | Kairo and Zuri full-body renders. |
| Level card renders | `.png` | `res://assets/ui/level_cards/` | One card per 6 levels (Level 6 sandy style). |
| Play Store screenshots | `.png` | external/exported | Capture only after placeholder geometry is gone. |
| Feature graphic art | `.png` 1024x500 | external/exported | Use final 3D characters and jungle/temple scene. |

## Priority 11 - Audio Gaps

Existing starter sounds can remain for prototype testing, but final 3D runner polish needs:

| Asset | Format | Target path |
| --- | --- | --- |
| Jungle ambience loop | `.ogg` | `res://assets/sounds/jungle_ambience.ogg` |
| Runner footstep set | `.wav`/`.ogg` | `res://assets/sounds/footstep_dirt_*.ogg` |
| Jump whoosh | `.wav`/`.ogg` | `res://assets/sounds/jump.ogg` |
| Slide swoosh | `.wav`/`.ogg` | `res://assets/sounds/slide.ogg` |
| Coin pickup polish | `.wav`/`.ogg` | `res://assets/sounds/coin.ogg` |
| Gem pickup | `.wav`/`.ogg` | `res://assets/sounds/gem.ogg` |
| Hit/stumble | `.wav`/`.ogg` | `res://assets/sounds/hit.ogg` |
| Victory fanfare | `.wav`/`.ogg` | `res://assets/sounds/level_complete.ogg` |
| Defeat sting | `.wav`/`.ogg` | `res://assets/sounds/game_over.ogg` |

## Source Shortlist

Use these first:

- Quaternius: low-poly characters, Universal Base Characters, Universal Animation Library, nature, RPG/treasure, survival props, simple animals. Prefer CC0 packs.
- Kenney: Nature Kit, Platformer Kit, Modular Dungeon Kit, UI/audio support. Asset pages are CC0.
- Poly Pizza: extra low-poly props, trees, and animals when each model license is verified and credited.
- OpenGameArt: last resort only. Verify each individual asset license. Do not import unclear, GPL, LGPL, CC-BY-SA, or store-conflicting assets without approval.

## Integration Checklist

1. Import final models under `res://assets/3d/`.
2. Create `PackedScene` wrappers where collision, animation, and metadata are needed.
3. Replace the capsule/sphere player mesh in `Game3D.tscn` with Kairo or the selected avatar.
4. Add `AnimationPlayer` and `AnimationTree` references to `Player3D.gd`.
5. Replace `LevelManager3D._spawn_ground()` path BoxMesh with dirt/stone/bridge packed scenes.
6. Replace `_tree()` with instanced tree and foliage scenes.
7. Replace `_box_obstacle()` calls with obstacle packed scenes that preserve `StaticBody3D` and `meta("obstacle")`.
8. Replace `_spawn_coin()` SphereMesh with coin/gem scenes while keeping the `Area3D` pickup logic.
9. Replace `_spawn_finish()` BoxMesh gate with biome-specific finish gate scenes.
10. Level JSONs for Levels 1–6 all exist. `TOTAL_LEVELS = 6` is set in `scripts/ui/LevelSelect.gd`.
11. Verify on Android hardware after each dense dressing pass.

## License Checklist

Every imported third-party asset must have:

- Source URL
- Author/creator name
- License name
- Download date
- Local file path
- Modified/not modified note
- Attribution text if required

If a license is unclear, do not ship the asset.
