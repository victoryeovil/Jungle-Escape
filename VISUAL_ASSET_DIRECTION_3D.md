# Visual and Asset Direction - Jungle Escape: Lost Path

## Target

`Jungle Escape: Lost Path` should read as a premium casual 3D mobile jungle runner: colorful, polished, adventurous, readable at portrait phone size, and light enough for Android. The look should be low-poly stylized 3D with shaped silhouettes, warm lighting, saturated jungle colors, and constant environmental motion.

The target is not a voxel/block game, not a flat prototype, and not a hyper-realistic survival game. It should sit closer to a clean indie adventure runner: bold forms, hand-painted or flat-color materials, clear gameplay silhouettes, and enough world dressing to make each run feel alive.

## Visual Pillars

| Pillar | Direction |
| --- | --- |
| Hero-readable | Kairo and Zuri must be visible from a chase camera, with clear hair, backpack, boots, belt, and action silhouette. |
| Lush but mobile-safe | Dense jungle should be built from repeated low-poly clusters, impostor-like back dressing, and simple shader/material work. |
| Motion-rich | Player animation, coin spin, foliage sway, water movement, birds, butterflies, torches, and obstacle anticipation should make the scene feel alive. |
| Adventure tone | Ruins, mossy stone, bridges, gates, treasure, and warm sun/fog should suggest mystery without becoming dark or realistic. |
| Gameplay clarity | Collectibles must pop, obstacles must be readable early, and decorative wildlife must stay outside the playable lane unless it is a deliberate hazard. |

## Scale and Camera

Use the existing runner scale as the baseline:

| Item | Target |
| --- | --- |
| Avatar height | 1.65m to 1.8m |
| Lane width | 1.8m, matching `Player3D.LANES` |
| Tile depth | 3.0m, matching `LevelManager3D.TILE_Z` |
| Path width | 5.4m total for 3 lanes |
| Camera | Third-person chase, slightly above and behind, showing the next 15m to 25m of path |
| Orientation | Portrait mobile first, 480x854 base project size |

Assets should be authored around Godot meters. Set pivots at ground contact for props, center-bottom for characters, and logical hinge/center points for animated hazards.

## Required 3D Asset Set

### Playable Characters

| Asset | Need |
| --- | --- |
| Kairo explorer model | Male young jungle explorer, lean athletic, short dark hair, khaki/olive explorer outfit, utility belt, boots, small backpack. |
| Zuri explorer model | Female young jungle adventurer, athletic, tied-back hair or braided ponytail, fitted adventure outfit, satchel/harness, boots, compact backpack. |
| Shared humanoid rig | Compatible with Godot 4 `Skeleton3D`, retargetable to one animation library. |
| Character material set | Warm skin tones, dark hair options, khaki/olive/tan outfit colors, accent colors for each avatar. |
| Character icons | Portrait/shop thumbnails rendered from the final 3D models. |

### Environment

| Asset | Need |
| --- | --- |
| Dirt path segments | Straight, slight curve illusion, cracked/muddy variants, bridge approach pieces. |
| Grass and jungle floor | Low grass clumps, ground cover, leaf litter, moss patches. |
| Trees | Palms, broad jungle trees, stylized canopy trees, background tree clusters. |
| Foliage | Ferns, bushes, vines, hanging leaves, small plants, flower accents. |
| Rocks | Small rocks, large lane-blocking rocks, mossy stone clusters. |
| Fallen logs | Jump obstacles, side dressing, bridge supports. |
| Water | River strips, water edge stones, simple animated material or UV movement. |
| Bridges | Wooden bridge lane segments, broken bridge variants, rope/rail posts. |
| Ruins | Mossy blocks, pillars, stairs, archways, broken walls, carvings, statues. |
| Gates/portals | Level finish gates, temple approach gates, glowing portal core. |
| Torches | Static torch model plus flame VFX/light variant. |
| Treasure props | Coins, gems, chest, relic, reward altar. |

### Obstacles and Interactives

| Asset | Gameplay read |
| --- | --- |
| Fallen log | Horizontal full-width jump obstacle. |
| Rock cluster | Single-lane dodge obstacle. |
| Spike trap | Low sharp hazard, red/bone/stone accent for danger. |
| Mud patch | Lane-wide slow or slide-risk surface, glossy dark brown. |
| River gap | Missing-ground jump section with visible water below. |
| Rolling boulder | Level 5 rolling obstacle, telegraphed by shadow/dust. |
| Hanging vine/barrier | Slide-under or dodge obstacle. |
| Temple pressure plate | Later interaction or visual trigger. |

### Wildlife

Decorative wildlife should be small, looped, and cheap:

| Wildlife | Use |
| --- | --- |
| Birds/parrots | Fly across background, perch on ruins or branches. |
| Butterflies | Low-cost particle or tiny mesh loops near foliage. |
| Monkeys | Side dressing animation, never blocking lanes unless designed as an obstacle. |
| Frogs | River edge ambiance. |
| Snakes | Decorative side snake or hazard variant with clear warning pose. |

## Free Sources to Use First

| Priority | Source | Use | License handling |
| --- | --- | --- | --- |
| 1 | Quaternius - https://quaternius.com | Characters, animation library, nature packs, RPG/treasure props, simple animals. | Prefer CC0 packs and keep the downloaded license file. |
| 2 | Kenney - https://kenney.nl/assets | Nature kit, platformer props, dungeon/ruin pieces, UI/audio support. | Kenney asset pages are CC0; keep per-pack license files. |
| 3 | Poly Pizza - https://poly.pizza | Extra low-poly trees, props, animals, ruins when style matches. | Verify each model's Creative Commons license at download time and record author/source. |
| 4 | OpenGameArt - https://opengameart.org | Only fill gaps that Quaternius/Kenney/Poly Pizza cannot cover. | Use only clearly verified assets. Avoid unclear, GPL, LGPL, CC-BY-SA, or store-problematic licenses unless explicitly approved. |

Create `res://assets/3d/ASSET_CREDITS.md` when real downloads are added. Each entry should include asset name, author, source URL, license, download date, modifications, and in-game use.

## Avatar Selection and Generation Plan

### Preferred Path

1. Start from Quaternius Universal Base Characters or compatible Quaternius animated human packs.
2. Keep both characters on the same humanoid skeleton so they can share the same animation set.
3. Customize materials and simple mesh accessories in Blender:
   - Kairo: short dark hair, olive/khaki shirt, utility belt, cargo shorts or slim trousers, light boots, compact backpack.
   - Zuri: tied-back or braided ponytail, fitted adventure top, harness/satchel, trek pants or shorts, boots, compact backpack.
4. Export each avatar as `.glb` with one mesh hierarchy, one `Skeleton3D`, and named animation clips or an external shared animation library.
5. Import into Godot as:
   - `res://assets/3d/characters/kairo/kairo.glb`
   - `res://assets/3d/characters/zuri/zuri.glb`
   - `res://assets/3d/characters/shared/explorer_animations.glb`

### If No Exact Free Avatar Exists

Create Kairo and Zuri from free base meshes plus custom CC0/simple modeled accessories:

| Component | Method |
| --- | --- |
| Hair | Use existing low-poly hair pieces or model simple stylized hair meshes in Blender. |
| Backpack/satchel | Model from boxes/cylinders with bevels, export as part of character mesh. |
| Outfit | Use material zones rather than high-detail cloth geometry. |
| Silhouette | Emphasize boots, belt, backpack, hair shape, and shoulders so the avatar reads at phone size. |
| Texture | Prefer flat colors or 512px/1024px atlas; avoid noisy PBR detail. |

## Animation Plan

Use Quaternius Universal Animation Library first because it is built around a universal humanoid rig and has Godot-compatible exports. Retarget Kairo and Zuri to the same skeleton and drive clips through `AnimationPlayer` plus `AnimationTree`.

| Motion | Use in game | Target feel | Godot state/event |
| --- | --- | --- | --- |
| Idle | Menus, character select, pause/ready state | Subtle breathing, confident stance | `idle` |
| Run forward | Default runner movement | Snappy, heroic, readable arm swing | `Player3D.State.RUN` |
| Strafe left | Lane switch left | Fast side step with body lean | lane change trigger |
| Strafe right | Lane switch right | Mirrored side step with body lean | lane change trigger |
| Jump | Swipe up | Clear takeoff, tucked knees, forward energy | `jump()` |
| Land | Return to ground | Short compression/recovery | floor contact after jump |
| Slide | Swipe down | Low agile slide under hazards | `slide()` |
| Collect | Coin/gem pickup flourish | Small reach or shoulder pop, not too long | pickup event overlay/additive |
| Hit reaction | Obstacle contact | Stumble backward/side, quick fail read | `die()` pre-game-over |
| Victory | Finish gate | Confident celebration, short loop | finish reached |
| Defeat | Game over | Fall/kneel or exhausted pose | `State.DEAD` |

Animation rules:

- Keep locomotion loop lengths short and responsive.
- Use animation blending so lane switching does not snap the upper body.
- Use root motion only if it is deliberately integrated; the current controller moves the player through code.
- For slide and jump, tune collision shape changes separately from the visual animation.
- If an exact slide or collect clip is missing, author a small custom animation in Blender instead of forcing a mismatched clip.

## Environment Plan by Level

### Level 1 - Jungle Trail Entrance

Visual tone: welcoming, bright, readable.

Assets:

- Dirt path with soft grass edges
- Palms and broad jungle trees spaced wide
- Ferns, bushes, small rocks
- Simple fallen logs and single rocks
- Coin lines centered and gently offset
- Light bird/butterfly ambient motion
- Finish: small mossy gate or simple jungle arch

Implementation note: replace the current Level 1 placeholder trees, rocks, logs, coins, and gate first. This is the Play Store screenshot baseline.

### Level 2 - Deeper Forest

Visual tone: denser, more enclosed, more movement in the background.

Assets:

- Taller tree clusters and layered foliage
- Hanging vines and bigger bushes
- Mossy rocks and roots near lane edges
- More single-lane dodge obstacles
- Coin arcs that guide lane switching
- Monkeys/birds as side dressing
- Finish: vine-covered ruin arch

Gameplay read: obstacles must remain high contrast against darker foliage.

### Level 3 - River Crossing

Visual tone: water, bridges, mud, faster visual rhythm.

Assets:

- River strips crossing under the path
- Wooden bridge segments and broken bridge variants
- Mud patches with glossy material
- Water-edge rocks and reeds
- Frogs, butterflies, and small splashes
- Jump section indicators
- Finish: bridge-end stone marker or river ruin gate

Implementation note: `LevelManager3D._remove_ground_at()` needs real gap visuals and a kill zone before river jumps feel production-ready.

### Level 4 - Ancient Jungle Ruins

Visual tone: mossy stone, tighter pathing, adventure danger.

Assets:

- Stone floor/path variants
- Broken pillars, walls, stairs, arch pieces
- Spike traps, pressure plates, carved stones
- Vines over stone, moss decals/mesh patches
- Torch stands or glowing fireflies
- Snakes as hazard/ambient variant
- Finish: carved temple doorway

Content note: create `data/levels3d/level3d_004.json` and increase `LevelSelect.TOTAL_LEVELS`.

### Level 5 - Temple Approach

Visual tone: highest reward and tension for the first world.

Assets:

- Large temple gate, statues, torch rows
- Richer gold coin placement and gem rewards
- Rolling boulder obstacle
- Stronger finish portal or treasure altar
- Denser ruin silhouettes outside the path
- Warm light, torch VFX, subtle dust
- Optional parrot flyover or monkey side animation at start

Content note: create `data/levels3d/level3d_005.json` and build a stronger completion scene/screenshot moment.

## Motion and Life Pass

The world should move even when gameplay logic is simple:

- Coins rotate and bob.
- Ferns/bushes use a cheap sine sway script or shader.
- Water uses scrolling UVs or a simple animated material.
- Birds/parrots fly on spline-like paths outside the lanes.
- Butterflies can be GPU particles or tiny repeated meshes.
- Torches flicker using light energy noise plus flame mesh/particle.
- Obstacles get anticipation where possible: rolling boulder shadow, spike warning color, bridge gap edge markers.

## Technical Targets for Godot 4 Android

| Area | Target |
| --- | --- |
| Format | Prefer `.glb` for models and animations. |
| Character triangles | 8k to 13k triangles per playable avatar is acceptable because only one is active. Lower if possible. |
| Prop triangles | 100 to 1,500 triangles for most props; large hero gates can be higher if instanced sparingly. |
| Textures | 512px for small props, 1024px for characters/hero props, atlased when practical. |
| Materials | Prefer flat/stylized `StandardMaterial3D`; avoid heavy transparent overdraw. |
| Collision | Use simplified primitive collision, not render mesh collision. |
| Draw calls | Reuse materials and packed scenes; instance repeated foliage. |
| Lighting | One warm sun, soft fill, fog/world color. Avoid many real-time lights. |
| Import | Disable unused animations, compress textures, verify scale, set loop flags. |

## Integration Points

| Current file | What changes when assets arrive |
| --- | --- |
| `scenes/game3d/Game3D.tscn` | Replace capsule placeholder with `Kairo` or selected avatar scene. |
| `scripts/gameplay/Player3D.gd` | Add `AnimationPlayer`/`AnimationTree` state calls for run, jump, slide, hit, victory, defeat. |
| `scripts/gameplay/LevelManager3D.gd` | Replace `_box_obstacle()`, `_tree()`, `_spawn_coin()`, `_spawn_finish()`, and ground creation with packed scenes. |
| `data/levels3d/*.json` | Extend level data with biome/theme tags and add levels 4 and 5. |
| `scripts/ui/LevelSelect.gd` | Increase `TOTAL_LEVELS` after level 4/5 JSON files are created. |
| `assets/3d/ASSET_CREDITS.md` | Track all third-party asset licenses and modifications. |

## Quality Bar

Before calling the art pass complete:

- A screenshot of Level 1 must show Kairo or Zuri clearly, a dirt jungle path, trees/foliage on both sides, coins, an obstacle, and depth ahead.
- Level 3 must visibly read as a river/bridge level within 3 seconds.
- Level 4 must visibly read as ruins, not just green jungle with grey rocks.
- Level 5 must feel like a temple approach with stronger reward framing.
- At least one male and one female avatar must be selectable or ready to wire into selection.
- No production screenshot should expose primitive cube/capsule placeholders.
- All used third-party assets must have a recorded source and license.
