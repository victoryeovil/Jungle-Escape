# TASKS — Jungle Escape: Lost Path

Legend: ✅ Done | 🔄 In Progress | ⬜ Pending | ❌ Blocked

---

## Phase 1 — Prototype (COMPLETE ✅)
- ✅ Godot 4 project created
- ✅ Directory structure established
- ✅ project.godot configured (480×854 portrait, mobile renderer)
- ✅ All autoload singletons: GameManager, SaveManager, AudioManager, EventBus
- ✅ Constants.gd with tile types, skins, trails, economy values
- ✅ Grid system: loads JSON levels, spawns tiles, handles movement
- ✅ Player: animated tile movement, skin support
- ✅ InputHandler: swipe detection + keyboard fallback
- ✅ LevelLoader: reads JSON level files
- ✅ All tile scripts: Floor, Wall, Coin, Gem, Key, Gate, Exit, Spike, Snake, River, Bridge, Mud, Switch, Vine, Fruit
- ✅ 5 test levels created (levels 1–5)

## Phase 2 — MVP Gameplay (COMPLETE ✅)
- ✅ 20 playable levels (Worlds 1–2, levels 1–20)
- ✅ Coins, keys, gates, spikes, snakes all implemented
- ✅ Stars (1–3) calculated and saved per level
- ✅ Local save system (JSON file via SaveManager)
- ✅ Guest mode — no login required

## Phase 3 — Game Feel (⬜ NEXT)
- ✅ Replace ColorRect placeholders with starter Sprite2D art
- ⬜ Add tile animations (idle wobble for collectibles, pulse on exit)
- ⬜ Add particle effects: coin collect, gate open, level complete
- ✅ Add sound effects (SFX files → AudioManager._sfx_map)
- ✅ Add background music tracks (→ AudioManager._music_map)
- 🔄 Polish UI: fonts, colours, button styles, animations (fonts, icons, and backgrounds done; animations pending)
- ✅ Add HUD/UI icons (pause, restart, hint, coin, key, star)
- ✅ Add UI fonts (`title_font.ttf`, `body_font.ttf`) with license notes
- ✅ Add gameplay and main menu background images
- ✅ Add app icon (res://assets/sprites/ui/icon.png — 1024×1024 PNG)
- ✅ Add splash image (res://assets/sprites/ui/splash.png)
- ✅ Shop scene: skin preview images
- ⬜ Level complete: star pop animation

## Phase 4 — Retention Features (⬜ PENDING)
- ⬜ Daily challenge system (level_daily.json, cached offline)
- ⬜ Teaser level / teaser overlay for locked worlds
- ⬜ Friend invite: OS share sheet via OS.shell_open()
- ⬜ Challenge code generator and share text
- ⬜ Leaderboard placeholder screen
- ⬜ Profile screen (logged-in user view)
- ⬜ Firebase / Supabase auth integration
- ⬜ Cloud save sync (SaveManager.add_pending_sync → server endpoint)
- ⬜ Daily reward popup
- ⬜ Referral code system

## Phase 5 — Android Testing (⬜ PENDING)
- ⬜ Install Android SDK + JDK
- ⬜ Configure Android export preset in Godot editor
- ⬜ Set app package name: com.yourname.jungleescape
- ⬜ Generate debug APK and install on test device
- ⬜ Test swipe controls on real device
- ⬜ Test offline mode (airplane mode)
- ⬜ Test progress save/restore
- ⬜ Test screen scaling on multiple resolutions
- ⬜ Fix any crashes discovered
- ⬜ Performance profiling on mid-range device

## Phase 6 — Play Store (⬜ PENDING)
- ⬜ Create Play Console developer account
- ⬜ App icon: 512×512 PNG
- ⬜ Feature graphic: 1024×500 PNG
- ⬜ Screenshots: at least 2 phone screenshots
- ⬜ Short description (max 80 chars)
- ⬜ Full description
- ⬜ Privacy policy URL
- ⬜ Set target SDK to 34+
- ⬜ Sign APK/AAB with release keystore
- ⬜ Generate AAB (Android App Bundle) for Play Store
- ⬜ Upload to internal testing track
- ⬜ Test internal release on device
- ⬜ Submit for review

---

## Phase 3D — 3D Gameplay (IN PROGRESS 🔄)

### Core 3D Systems ✅
- ✅ `Player3D.gd` — CharacterBody3D, 3-lane auto-runner, jump, slide, obstacle death
- ✅ `LevelManager3D.gd` — procedural level builder from JSON (ground, trees, obstacles, coins, finish)
- ✅ `InputHandler3D.gd` — swipe detection + keyboard fallback
- ✅ `Game3D.gd` — scene controller, signal wiring, win/lose state
- ✅ `HUD3D.gd` — pause, level label, coin counter, turn direction prompt
- ✅ Kairo + Zuri GLB characters imported and selectable
- ✅ Animation hooks: run, strafe L/R, slide/roll, hit, victory, defeat

### Turn System ✅
- ✅ Cursor-based segment dictionaries (`_seg_pos/fwd/right`) for multi-direction paths
- ✅ `_spawn_turn_zones()` — Area3D trigger, two glowing floor arrows, log-jam dam barrier
- ✅ Queued-turn system — swipe queues turn, executes automatically at corner (within 3 m)
- ✅ Any swipe direction in turn zone triggers correct turn (no need to guess left vs right)
- ✅ HUD "TURN LEFT / TURN RIGHT" prompt shown on entering zone
- ✅ Character `rotation.y` updated in `_execute_turn` so mesh faces new direction
- ✅ Camera heading follows `_move_fwd`; snaps instantly on turn
- ✅ Obstacle clear zone: `[tr-3 … tr+3]` around every corner on every level
- ✅ Levels 2–5 all have one turn each; Level 1 is a straight tutorial

### 5 Playable Levels ✅
- ✅ Level 1 — Jungle Trail (tutorial, straight)
- ✅ Level 2 — Deep Forest (LEFT turn row 20)
- ✅ Level 3 — River of Echoes (RIGHT turn row 18)
- ✅ Level 4 — Ancient Ruins (LEFT turn row 22)
- ✅ Level 5 — Temple Approach (RIGHT turn row 25)

### Pending 3D Tasks ⬜
- ⬜ Multiple turns per level (needs cursor + turn_rows iteration tested with 2 sequential turns)
- ⬜ HUD distance/score counter
- ⬜ On-screen swipe button fallback for players with touch-swipe issues
- ⬜ Jump/land animation clips (not in free character GLBs)
- ⬜ River gap gameplay (Level 3 design spec) — ground removal + bridge/jump logic
- ⬜ Android export + device test
- ⬜ Performance profiling on mid-range phone

---

## Phase 3D-Map — Jungle Expedition Map (✅ COMPLETE)

### Core Map Done ✅
- ✅ Level select redesigned from plain button grid → full jungle expedition map
- ✅ Winding dirt trail drawn procedurally via `_draw()` polyline (shadow + edge + centre + highlight)
- ✅ Layered jungle background (5 distinct zone backgrounds: sandy wildlands, ruins band, river, jungle body, jungle entrance)
- ✅ River of Echoes section with water band, shimmer, bank edges, bridge, floating label
- ✅ Fog zone at top for locked/wildlands area
- ✅ Start Camp landmark (tent, flag pole, label)
- ✅ Temple of the First Sun icon (gate pillars, golden glow, label)
- ✅ Level markers (Levels 1–6): fully circular badge buttons at path positions with chapter colour, name, stars
- ✅ Current-level marker pulses gold (looping Tween)
- ✅ Level 6 Sand Shoes gate: marker shows 👟 icon, tapping opens Sand Shoes popup
- ✅ Sand Shoes popup with Buy button, resource cost display, inline failure feedback
- ✅ Level preview panel: chapter, name, stars, story desc, rewards, Start + Close buttons
- ✅ Coins display in header
- ✅ Zone watermark labels
- ✅ Elephant + warthog silhouettes in wildlands zone
- ✅ Acacia savanna trees in wildlands zone
- ✅ Objective strip at bottom
- ✅ Header bar with title + back button
- ✅ Back button dismisses popup/preview before returning to menu
- ✅ Deterministic tree layout via seeded RNG

### Map Polish ⬜ (Future)
- ⬜ Jungle map background PNG (`res://assets/backgrounds/bg_jungle_map.png`) to replace procedural ColorRects
- ⬜ Slide-up tween animation for level preview panel
- ⬜ Fog shimmer / particle overlay on locked zone
- ⬜ Sunstone Shard + Map Piece icons in preview panel rewards
- ⬜ Chapter progress indicator (Shards: 2/5, Map Pieces: 1/3)
- ⬜ Ambient life on map screen (birds flying, butterflies near river)
- ⬜ Chapter gate unlock animation
- ⬜ Map reveal path animation when a new level unlocks
- ⬜ Daily Expedition marker on map

---

## Phase 3D-Wildlands — Level 6 & Progression System (🔄 IN PROGRESS)

### Core Wildlands Done ✅
- ✅ `data/levels3d/level3d_006.json` — "Wildlands of Peace" (40 rows, 1 turn, 11 obstacles, 24 collectibles)
- ✅ `LevelManager3D._setup_theme()` Level 6 — sandy warm colours, `"surface": "sand"`
- ✅ `Constants.RESOURCES` — 9 resource types (bricks, wood, tiles, windows, food, tools, relic_keys, sunstone_shards, map_pieces)
- ✅ `Constants.UPGRADES` — Sand Shoes upgrade (100 coins + 2 Food + 1 Relic Key)
- ✅ `Constants.HOME_STAGES` — 6-stage home building progression
- ✅ `Constants.WILDLIFE_TIPS` — 5 educational wildlife messages
- ✅ `SaveManager` resource API — `get_resource`, `add_resource`, `spend_resource`, `get_all_resources`
- ✅ `SaveManager` upgrade API — `has_upgrade`, `unlock_upgrade`, `buy_upgrade`
- ✅ `SaveManager` home API — `get_home_stage`, `set_home_stage`
- ✅ `GameManager.go_to_wildlands_unlock()`
- ✅ `LevelComplete3D._on_next()` — routes to WildlandsUnlock after Level 5 if shoes not owned
- ✅ `WildlandsUnlock.gd` + `WildlandsUnlock.tscn` — 3-panel story screen with savanna background, wildlife silhouettes, sand particles, panel navigation
- ✅ `MISSING_UI_ASSETS.md` — full manifest of all needed UI/map/icon assets
- ✅ `MISSING_3D_ASSETS.md` — updated with Level 6 dressing, wildlife, upgrade items, home stages

### Now Complete ✅
- ✅ Sand terrain physics — `Player3D`: speed ×0.45, jump blocked, `sand_blocked` signal emitted
- ✅ `EventBus.resource_collected` signal + `GameManager.collect_resource()`
- ✅ Resource drops at level finish — `Game3D._award_level_resources()` per-level drop table
- ✅ Resource HUD — `HUD3D` sand warning toast + Level 6 resource bar (food, bricks, wood, sunstone)
- ✅ Level 6 atmosphere — `Game3D._level_atmosphere()` case 6 (warm sandy sky, low fog, bright sun)
- ✅ Level 6 3D dressing — `_spawn_wildlands_dressing()`, acacia trees, dry grass, sandy rocks
- ✅ Wildlife silhouettes — `_elephant_silhouette()`, `_warthog_silhouette()` in LevelManager3D
- ✅ River gap kill zone — `Area3D` in `_remove_ground_at()` triggers `die()` on player entry
- ✅ `UpgradeShop.gd` + `UpgradeShop.tscn` — full shop with affordability check, resource inventory
- ✅ `HomeBuilding.gd` + `HomeBuilding.tscn` — 6-stage build UI with locked/built/current states
- ✅ `GameManager.go_to_upgrade_shop()` + `go_to_home_building()` navigation
- ✅ LevelSelect sand popup — "Open Upgrade Shop" link button added
- ✅ WildlandsUnlock last panel — "Build Your Home" button added
- ✅ `LevelComplete3D.show_result()` — resource reward icon row displayed after level finish
- ✅ `LevelComplete3D._story_message()` — Level 6 message added

### Still Pending ⬜
- ⬜ Sand Shoes icon PNG at `res://assets/ui/upgrades/sand_shoes_icon.png`
- ⬜ Resource icon PNGs in `res://assets/ui/icons/`
- ⬜ Home building stage images in `res://assets/ui/home/`
- ⬜ Jump/land animation clips for Player3D
- ⬜ Android export + device test for Level 6

---
Last updated: 2026-06-19
