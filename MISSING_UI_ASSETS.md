# Missing UI Assets — Jungle Escape: Lost Path

This file tracks image, icon, and texture assets required by the UI layer, including remaining missing items and newly filled items.
Unchecked assets are currently replaced by procedural `ColorRect` / `Label` / `StyleBoxFlat` rendering in GDScript.
Replace them progressively; the procedural fallback remains functional until each asset is imported.

## Lives System

- [ ] Heart/life icon
- [ ] Empty heart icon
- [ ] Lives refill popup background
- [ ] Revive popup background
- [ ] Life timer icon
- [ ] Rewarded ad life icon

Source shortlist: **Quaternius · Kenney · Poly Pizza · OpenGameArt**  
License rule: CC0 preferred. CC-BY acceptable with credit in `ASSET_LICENSES.md`. No GPL or SA.

---

## Priority 1 — Map Background (HIGH IMPACT)

- [x] `res://assets/backgrounds/bg_jungle_map.png`
  User-provided illustrated jungle expedition map imported from `C:\Users\dell\Downloads\map.png`.
  Source dimensions: 941x1672. Used directly by `LevelSelect.gd` as the full-screen reference map art.

## Filled Full-Screen UI Art Plates

- [x] `res://assets/backgrounds/bg_home_building.png`
  User-provided Build Your Home screen art imported from `C:\Users\dell\Downloads\home.png`.
  Source dimensions: 941x1672. Used directly by `HomeBuilding.gd` with transparent controls layered above it.
- [x] `res://assets/backgrounds/bg_choose_explorer.png`
  User-provided Choose Explorer screen art imported from `C:\Users\dell\Downloads\build.png`.
  Source dimensions: 941x1672. Used directly by `Shop.gd` with transparent controls layered above it.

## Priority 2 — Level Markers (HIGH IMPACT)

- [ ] `res://assets/ui/map/markers/marker_completed.png` — gold star glow, 96×96
- [ ] `res://assets/ui/map/markers/marker_current.png` — bright pulsing, 96×96
- [ ] `res://assets/ui/map/markers/marker_locked.png` — dark muted with lock, 96×96
- [ ] `res://assets/ui/map/markers/marker_story.png` — scroll/relic glow, 96×96
- [ ] `res://assets/ui/map/markers/marker_shoes_required.png` — sandy border + shoe, 96×96  
  Source: Kenney UI Pack Adventure or Kenney Game Icons (CC0 confirmed).

## Priority 3 — Resource & Upgrade Icons (MEDIUM IMPACT)

- [ ] `res://assets/ui/icons/icon_bricks.png` — 32×32
- [ ] `res://assets/ui/icons/icon_wood.png` — 32×32
- [ ] `res://assets/ui/icons/icon_food.png` — 32×32
- [ ] `res://assets/ui/icons/icon_relic_key.png` — 32×32
- [ ] `res://assets/ui/icons/icon_sunstone_shard.png` — 32×32
- [ ] `res://assets/ui/icons/icon_map_piece.png` — 32×32
- [ ] `res://assets/ui/icons/icon_tiles.png` — 32×32
- [ ] `res://assets/ui/icons/icon_windows.png` — 32×32
- [ ] `res://assets/ui/icons/icon_tools.png` — 32×32  
  Source: Kenney Game Icons / Kenney Game Icons Expansion (CC0 confirmed).

## Priority 4 — Sand Shoes Upgrade Icon (MEDIUM IMPACT)

- [ ] `res://assets/ui/upgrades/sand_shoes_icon.png` — 64×64  
  Stylized shoe or boot on sandy background.

## Priority 5 — Map Landmarks (MEDIUM IMPACT)

- [ ] `res://assets/ui/map/landmarks/landmark_camp.png` — tent + fire, 80×80
- [ ] `res://assets/ui/map/landmarks/landmark_bridge.png` — wooden bridge, 100×60
- [ ] `res://assets/ui/map/landmarks/landmark_temple.png` — stone gate + sun, 100×80
- [ ] `res://assets/ui/map/landmarks/landmark_wildlands.png` — acacia + elephant, 100×80

## Priority 6 — Map Effects (LOW IMPACT — polish)

- [ ] `res://assets/ui/map/effects/fog_overlay.png` — misty fog, 480×120, semi-transparent
- [ ] `res://assets/ui/map/effects/path_texture.png` — dirt texture tile for path

## Priority 7 — Home Building Stage Images (LOW IMPACT)

- [ ] `res://assets/ui/home/home_stage_1.png` — empty land, 280×200
- [ ] `res://assets/ui/home/home_stage_2.png` — foundation, 280×200
- [ ] `res://assets/ui/home/home_stage_3.png` — walls, 280×200
- [ ] `res://assets/ui/home/home_stage_4.png` — roof, 280×200
- [ ] `res://assets/ui/home/home_stage_5.png` — doors/windows, 280×200
- [ ] `res://assets/ui/home/home_stage_6.png` — complete home, 280×200

---

---

## 1. Jungle Map Background

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Jungle expedition map background | `.png` 941x1672 source | `res://assets/backgrounds/bg_jungle_map.png` | Present. Full-screen user-provided reference art used by `LevelSelect.gd`; procedural map remains fallback if the asset is absent. |
| Fog/mist overlay | `.png` 480×180 | `res://assets/backgrounds/bg_fog_overlay.png` | Transparent white-grey vignette for the locked wildlands zone at the top of the map. Alpha channel required. |
| Map paper texture | `.png` | `res://assets/backgrounds/bg_map_paper.png` | Optional aged-parchment texture to sit behind the level map. |

---

## 2. Level Marker Icons (Map Nodes)

One badge icon per level zone style. Used as background on each level Button node.

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Jungle badge marker | `.png` 88×88 | `res://assets/ui/markers/marker_jungle.png` | Green moss-stone rounded badge. Levels 1–2. |
| River badge marker | `.png` 88×88 | `res://assets/ui/markers/marker_river.png` | Blue-grey stone badge with water edge. Level 3. |
| Ruins badge marker | `.png` 88×88 | `res://assets/ui/markers/marker_ruins.png` | Brown carved-stone badge. Levels 4–5. |
| Wildlands badge marker | `.png` 88×88 | `res://assets/ui/markers/marker_wildlands.png` | Warm sandy badge. Level 6. |
| Locked marker overlay | `.png` 88×88 | `res://assets/ui/markers/marker_locked.png` | Dark overlay with padlock silhouette. Applied on top of any zone badge. |
| Star icons filled/empty | `.png` 24×24 | `res://assets/ui/icons/star_filled.png`, `star_empty.png` | Gold star / empty star for level completion display. |

---

## 3. Landmark Icons (Camp, Temple)

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Start Camp icon | `.png` 80×64 | `res://assets/ui/landmarks/landmark_camp.png` | Tent with campfire, flag on pole. Warm colours. |
| Temple of the First Sun icon | `.png` 80×64 | `res://assets/ui/landmarks/landmark_temple.png` | Stone temple gate with sun glyph glow. |
| River of Echoes label flag | `.png` | `res://assets/ui/landmarks/landmark_river.png` | Small banner or tab overlay for the river strip. |
| Ancient Ruins indicator | `.png` | `res://assets/ui/landmarks/landmark_ruins.png` | Crumbling pillar silhouette used as zone separator. |

---

## 4. Winding Trail

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Dirt trail texture strip | `.png` tileable | `res://assets/ui/map/trail_dirt.png` | Used to texture the `draw_polyline` path on the map. Tileable horizontal dirt/pebble. |
| Trail edge texture | `.png` tileable | `res://assets/ui/map/trail_edge.png` | Grass/earth border for either side of the path. |

---

## 5. Preview Panel

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Preview panel background | `.png` 480×272 | `res://assets/ui/panels/panel_preview.png` | Dark jungle-textured card. Currently procedural dark-green `ColorRect`. |
| Divider vine decoration | `.png` | `res://assets/ui/panels/divider_vine.png` | Horizontal decorative separator inside the level preview card. |
| "Start Expedition" button style | `.png` 9-patch | `res://assets/ui/buttons/btn_start.png` | Golden-green adventure button with stone border. |

---

## 6. Sand Shoes Popup

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Sand Shoes icon | `.png` 64×64 | `res://assets/ui/upgrades/sand_shoes_icon.png` | Dusty/sandy boot illustration. Warm sandy tones. |
| Popup background texture | `.png` 420×296 | `res://assets/ui/panels/panel_sand_popup.png` | Sandy earthy card texture. Currently procedural. |

---

## 7. Wildlands Unlock Screen (WildlandsUnlock.tscn)

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Savanna background | `.png` 480×854 | `res://assets/backgrounds/bg_wildlands_unlock.png` | Full-screen warm savanna scene: sky gradient, acacia trees, distant elephant silhouettes. |
| Elephant silhouette | `.png` | `res://assets/ui/wildlife/elephant_silhouette.png` | Single large elephant, dusty grey silhouette for story panel. |
| Warthog silhouette | `.png` | `res://assets/ui/wildlife/warthog_silhouette.png` | Small warthog side-view silhouette. |
| Dust/sand particle texture | `.png` 16×16 | `res://assets/ui/vfx/particle_sand.png` | Single sand grain for GPUParticles2D or procedural float. |

---

## 8. HUD and In-Game Overlay Icons

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Coin icon | `.png` 32×32 | `res://assets/ui/icons/icon_coin.png` | Gold spinning coin front-face. |
| Gem icon | `.png` 32×32 | `res://assets/ui/icons/icon_gem.png` | Blue faceted gem. |
| Food icon | `.png` 32×32 | `res://assets/ui/icons/icon_food.png` | Canned food / fruit icon. |
| Relic Key icon | `.png` 32×32 | `res://assets/ui/icons/icon_relic_key.png` | Carved ancient key with amber gem head. |
| Sunstone Shard icon | `.png` 32×32 | `res://assets/ui/icons/icon_sunstone_shard.png` | Glowing amber shard. |
| Map Piece icon | `.png` 32×32 | `res://assets/ui/icons/icon_map_piece.png` | Torn parchment fragment. |
| Bricks icon | `.png` 32×32 | `res://assets/ui/icons/icon_bricks.png` | Stack of red/brown bricks. |
| Wood icon | `.png` 32×32 | `res://assets/ui/icons/icon_wood.png` | Two planks of wood. |
| Tiles icon | `.png` 32×32 | `res://assets/ui/icons/icon_tiles.png` | Terracotta roof tiles. |
| Windows icon | `.png` 32×32 | `res://assets/ui/icons/icon_windows.png` | Small house window frame. |
| Tools icon | `.png` 32×32 | `res://assets/ui/icons/icon_tools.png` | Wrench or hammer. |

---

## 9. Home Building UI

| Asset | Format | Target path | Notes |
| --- | --- | --- | --- |
| Home Stage 0 (empty land) | `.png` 320×240 | `res://assets/ui/home/stage_0_land.png` | Bare sandy plot, no structure. |
| Home Stage 1 (flag / land claimed) | `.png` 320×240 | `res://assets/ui/home/stage_1_flag.png` | Plot with a single marker flag. |
| Home Stage 2 (foundation) | `.png` 320×240 | `res://assets/ui/home/stage_2_foundation.png` | Stone foundation slab laid. |
| Home Stage 3 (walls) | `.png` 320×240 | `res://assets/ui/home/stage_3_walls.png` | Brick walls, open top. |
| Home Stage 4 (roof & tiles) | `.png` 320×240 | `res://assets/ui/home/stage_4_roof.png` | Tiled roof fitted. |
| Home Stage 5 (windows) | `.png` 320×240 | `res://assets/ui/home/stage_5_windows.png` | Windows added to walls. |
| Home Stage 6 (complete) | `.png` 320×240 | `res://assets/ui/home/stage_6_complete.png` | Finished home with door, garden, flag. |

---

## Integration Steps

1. Place each asset at the `res://` path listed.
2. Done for `bg_jungle_map.png`: `LevelSelect.gd` now loads the art and draws it full-screen, with transparent hit areas over the embedded buttons and markers.
3. In `_add_marker()`, use `TextureButton` with `normal_texture = marker_[zone].png` instead of `StyleBoxFlat`.
4. In `_build_camp()` and `_build_temple_icon()`, use `TextureRect` nodes with landmark PNGs.
5. In `WildlandsUnlock.gd`, swap `_build_background()` `ColorRect` blocks with `bg_wildlands_unlock.png` in a full-screen `TextureRect`.
6. In `_build_sand_shoes_popup()`, use `sand_shoes_icon.png` in an `TextureRect` instead of the emoji `Label`.
7. Verify all textures import as `2D Lossless` (PNG) in Godot import settings.
8. Test on Android for memory: combined map PNGs should stay under 8 MB uncompressed.
