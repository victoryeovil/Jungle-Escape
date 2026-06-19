# Pivot Project to 3D — Jungle Escape: Lost Path

## Objective

The project must be pivoted from a flat 2D box/grid presentation into a **3D mobile jungle game**.

The current prototype is visually too static and too box-like.
The new version must feel like a **real game people would want to play on Google Play**.

The game should become a **3D jungle runner / action-adventure mobile game** with visible movement, real environment presence, and strong visual appeal.

---

# New Game Direction

## Core Experience

Create a **3D jungle adventure game** where the player controls an explorer character running through jungle environments, collecting coins, avoiding obstacles, and progressing through levels.

The game must immediately communicate:

* adventure
* movement
* jungle exploration
* excitement
* progression
* replayability

This should no longer feel like a puzzle board or colored tile system.

---

# Recommended Scope

## Best Scope for MVP

Build a **simple 3D third-person runner/adventure** rather than a complex open world.

### Recommended MVP style:

* **third-person camera**
* character constantly moving forward OR moving through a guided path
* player can:

  * move left/right
  * jump
  * dodge/avoid obstacles
  * collect coins
  * reach the end gate / finish area

This gives the game life while still keeping it manageable.

---

# Preferred Style

## Visual Style

Use a **stylized low-poly 3D jungle look**.

The style should be:

* visually appealing
* clean
* modern
* lightweight for mobile
* not childish
* not hyper-realistic
* not overly blocky
* not empty

### Environment feel:

* jungle path
* ruins
* rocks
* trees
* vines
* bridges
* rivers
* temple gates
* foliage
* soft lighting
* slight mystery/adventure mood

---

# Gameplay Model

## Core Loop

Player starts level → runs through jungle → collects coins → avoids traps/obstacles → reaches finish gate → unlocks next level.

## Progression Features

Include:

* multiple levels
* increasing difficulty
* coin collection
* score
* simple skins/unlockables later
* teaser content for later levels
* login advantages
* offline support
* friend challenge hooks later

---

# Controls

## Mobile Controls

Use simple mobile-friendly controls.

### Recommended control scheme:

* swipe left/right = move lanes or dodge sideways
* swipe up = jump
* swipe down = slide / duck
* tap = optional interaction if needed

Alternative:

* on-screen buttons if swipe feels unreliable

The control system must be responsive and intuitive.

---

# Technical Implementation in Godot 4

## Engine Direction

Use **Godot 4 3D**, not 2D.

### Core node types to use:

* `Node3D`
* `CharacterBody3D`
* `Camera3D`
* `DirectionalLight3D`
* `WorldEnvironment`
* `MeshInstance3D`
* `StaticBody3D`
* `CollisionShape3D`
* `Area3D`
* `AnimationPlayer` / `AnimationTree`
* `AudioStreamPlayer`

---

# Required Scene Structure

Create or refactor the game around these scenes:

```text
res://scenes/SplashScreen.tscn
res://scenes/MainMenu.tscn
res://scenes/LevelSelect.tscn
res://scenes/Game3D.tscn
res://scenes/Shop.tscn
res://scenes/Settings.tscn
res://scenes/LoginScreen.tscn
res://scenes/LevelComplete.tscn
res://scenes/GameOver.tscn
```

## Main gameplay scene

The main playable 3D scene should be:

```text
res://scenes/Game3D.tscn
```

---

# Main Gameplay Requirements

## 1. Player Character

The player must be a visible 3D explorer character.

### Requirements:

* third-person view
* idle animation
* running animation
* jump animation if possible
* hit/fail reaction if possible
* clearly visible on mobile
* must feel like the hero of the game

The player must **not** be represented by a square, flat sprite, or abstract marker.

---

## 2. Camera

Use a **third-person chase camera**.

### Requirements:

* camera follows behind the player
* camera angle clearly shows path ahead
* camera movement feels smooth
* camera should be stable enough for mobile play
* slight polish (smoothing or spring arm feel) is preferred

---

## 3. Environment

Build an actual 3D jungle level.

### Include:

* ground path
* grass / jungle floor
* rocks
* trees
* vines
* bushes
* ruins / temple pieces
* coins along the route
* obstacles on the route
* finish gate or temple exit

### Avoid:

* empty test environments
* plain cubes as final visuals
* flat debug-style scenes

---

## 4. Obstacles

Use real 3D obstacles.

### Examples:

* fallen logs
* rocks
* spikes
* swinging trap
* snake area
* broken bridge section
* mud patch
* river gap

The obstacles must feel like part of the jungle world.

---

## 5. Collectibles

Use coins and optional gems.

### Requirements:

* visible, attractive 3D collectible objects
* spin or animate slightly
* clear pickup feedback
* coin counter updates in HUD

---

## 6. Finish / Goal

Each level must have a visible end goal.

### Example:

* temple gate
* glowing jungle portal
* ancient ruin doorway
* treasure altar

The end point must feel rewarding.

---

# Level Design Direction

## MVP Levels

Create at least **3 playable 3D levels** first.

### Example progression:

* **Level 1:** simple path, coins, a few obstacles
* **Level 2:** more turns, more jumps, more hazards
* **Level 3:** harder route, more collectibles, tighter timing

Then expand to more levels later.

## Level style

Levels can be:

* linear jungle paths
* guided temple-run style segments
* corridor-like routes through jungle ruins

Do not attempt a large open world for MVP.

---

# Art Direction

## Recommended art style

Use:

* low-poly 3D jungle assets
* stylized but polished
* not childish
* not goofy
* not too dark
* not hyper-detailed

This is the safest and most achievable style for mobile and Godot.

---

# UI Direction

Keep the UI minimal and clean.

## HUD should include:

* pause button
* level number
* coin count
* score or distance
* restart button if needed

## Main menu should include:

* Start Game
* Level Select
* Shop
* Settings
* Login
* Continue Offline

Buttons must navigate correctly.

---

# Offline and Login Requirements

## Offline-first behavior

The game must still be playable offline.

### Offline mode:

* play available levels
* collect coins locally
* save basic progress locally
* allow guest play

## Logged-in advantages

If logged in, enable:

* cloud save
* progress sync
* unlock sync across devices
* leaderboards later
* friend challenges later
* invite rewards later

---

# Social / Retention Features

These can begin as placeholders but must be planned.

## Teaser systems

Add hooks such as:

* locked future levels
* “login to sync progress”
* “invite friends to challenge your score”
* “beat your friend’s best run”
* “daily jungle challenge”
* “new explorer skins coming soon”

These should encourage return play without blocking the core game.

---

# Performance Requirements

Because this is for Google Play mobile deployment:

* optimize for Android
* keep geometry lightweight
* keep texture sizes reasonable
* avoid overcomplicated shaders
* use low-poly / efficient models
* maintain smooth play on normal phones
* do not overload the scene with unnecessary objects

---

# Minimum Technical Features for MVP

The MVP is complete only when the following work:

* splash screen opens
* main menu works
* buttons navigate properly
* level select opens
* 3D game scene loads
* visible 3D explorer character exists
* character runs or moves visibly
* third-person camera follows the player
* jungle environment is present
* coins can be collected
* obstacles can be avoided or hit
* level can be completed
* next level progression works
* restart works
* pause works
* game over works
* level complete screen works
* offline play works locally
* mobile portrait or landscape choice is consistent

---

# Implementation Tasks

## Status Key
- `[x]` Done
- `[ ]` Not started
- `[~]` Partially done / needs update

---

## Phase 1 — Project Setup

- [x] Convert `project.godot` to 3D: renderer already set to `mobile`, viewport 480×854, portrait locked
- [~] Remove 2D-only autoload scripts that are puzzle-specific (`Grid.gd`, `LevelLoader.gd` — archived, not deleted)
- [x] Keep reusable autoloads: `GameManager.gd`, `SaveManager.gd`, `AudioManager.gd`, `EventBus.gd`
- [x] Keep reusable UI scripts: `Settings.gd`, `Shop.gd`, `LoginPrompt.gd`, `Profile.gd`, `DailyChallenge.gd`
- [x] Create `res://MISSING_3D_ASSETS.md` listing every 3D asset needed

---

## Phase 2 — Scene Structure

Replace/create scenes to match the required layout:

| Scene | Status | Notes |
|-------|--------|-------|
| `scenes/SplashScreen.tscn` | `[~]` | Exists — branding still 2D style; functional |
| `scenes/MainMenu.tscn` | `[x]` | Play/Continue Offline now route to LevelSelect |
| `scenes/menus/LevelSelect.tscn` | `[x]` | Created — 3-level grid with lock/unlock state |
| `scenes/game3d/Game3D.tscn` | `[x]` | Created — full 3D scene with player, camera, level, HUD, overlays |
| `scenes/Shop.tscn` | `[x]` | Exists — reused as-is |
| `scenes/Settings.tscn` | `[x]` | Exists — reused as-is |
| `scenes/LoginPrompt.tscn` | `[x]` | Exists — reused as-is |
| LevelComplete (in Game3D) | `[x]` | LevelComplete3D.gd + overlay in Game3D.tscn |
| GameOver (in Game3D) | `[x]` | GameOver3D.gd + overlay in Game3D.tscn |

---

## Phase 3 — Core 3D Infrastructure

### Player Character
- [x] Create `scripts/gameplay/Player3D.gd` extending `CharacterBody3D`
- [x] Add visible 3D explorer mesh (CapsuleMesh body + SphereMesh head placeholder)
- [x] Implement lane-based movement (left / center / right lanes) via smooth X lerp
- [x] Implement forward auto-movement (constant −Z velocity)
- [x] Implement jump with gravity
- [x] Implement slide/duck (state + duration timer)
- [~] AnimationPlayer states — placeholder; wire real animations when model arrives
- [x] Character visible on portrait screen (capsule + head clearly readable)

### Camera
- [x] `Camera3D` on `CamPivot` node, offset 4.5m behind / 2.5m above player
- [x] Camera pivot Z tracks player position in `_process`
- [x] Turn-aware heading: `target_xz = -_move_fwd * 4.5`; snaps instantly on turn (threshold > 2.45 m), lerps at `delta*8` otherwise
- [x] Camera rotation formula corrected: `atan2(-to_player.x, -to_player.z)` (fixes backward-facing camera on turns)
- [x] Locked portrait angle (transform baked, no drift)
- [~] SpringArm collision avoidance — deferred until real environment added

### Physics & Collision
- [x] `CapsuleShape3D` on player (`CollisionShape3D` centered at y=0.9)
- [x] `StaticBody3D` + `CollisionShape3D` on all ground and obstacle meshes
- [x] `Area3D` for coins and finish gate detection
- [~] Physics layer assignment — deferred (default layers functional for MVP)

---

## Phase 4 — Controls

- [x] Create `scripts/gameplay/InputHandler3D.gd`
- [x] Detect swipe left → move to left lane (or trigger turn if in turn zone)
- [x] Detect swipe right → move to right lane (or trigger turn if in turn zone)
- [x] Detect swipe up → trigger jump
- [x] Detect swipe down → trigger slide
- [x] Swipe threshold: min 40px, max 0.5s window
- [x] Keyboard fallback: A/D lanes, W/Space jump, S slide (desktop testing)
- [x] Turn zone: any swipe (left OR right) triggers the queued turn in `_turn_zone_dir` — player never needs to guess which side to swipe
- [~] On-screen button fallback — deferred; keyboard covers desktop testing

---

## Phase 5 — Environment

### Base Level Scene
- [x] Levels built procedurally in `LevelManager3D.gd` — no separate Level1.tscn needed
- [x] `WorldEnvironment` with blue sky + jungle fog in `Game3D.tscn`
- [x] Two `DirectionalLight3D` nodes: sun (warm angled) + fill light
- [x] Ground path — BoxMesh segments per tile, 3 tiles wide, full level length
- [~] Lane markers — no explicit guides; lanes are implicit (visual upgrade later)

### Environment Dressing
- [x] Jungle trees (trunk CylinderMesh + foliage SphereMesh) auto-placed on sides
- [x] Rocks — BoxMesh obstacle, grey color
- [~] Vines / foliage — deferred; placeholder geometry fills the space
- [~] Ruins / temple pieces — deferred; level 3 uses same geometry, different seed
- [~] Bridges / river gaps — obstacle type "gap" stubbed; full logic deferred
- [x] No empty scenes — trees flank every 2nd tile on both sides

### Obstacles (per level)
- [x] Fallen log — full-lane wide BoxMesh; player must jump
- [x] Rock cluster — single-lane BoxMesh; player must dodge
- [x] Spike trap — short flat red BoxMesh; player must dodge or jump
- [x] Mud patch — wide flat area stub (visual only, no slow yet)
- [~] River gap — stub in `_remove_ground_at`; collision logic deferred
- [~] Swinging trap — deferred
- [~] Snake area — deferred

### Collectibles
- [x] 3D coin mesh — SphereMesh gold with `Area3D`
- [~] Spin animation — deferred (can add `rotate_y` in LevelManager _process)
- [x] Coin pickup: `GameManager.collect_coin()`, HUD counter updates, SFX emitted
- [x] Gem collectible — SphereMesh blue, triggers `collect_gem()`

### Finish Gate
- [x] Temple gate: two post BoxMesh + crossbar BoxMesh (gold color)
- [x] `Area3D` trigger at gate: `body_entered` → `finish_reached` signal
- [x] On enter: player stops, LevelComplete overlay shown, tree paused

---

## Phase 6 — Gameplay Systems

- [x] `LevelManager3D.gd` — builds level from JSON data, spawns all geometry
- [x] Coin/score tracking via existing `GameManager` + `SaveManager`
- [x] Death detection — `StaticBody3D` tagged "obstacle" → `Player3D.die()` → Game Over overlay
- [x] Restart flow — GameOver BtnRetry → `GameManager.go_to_gameplay_3d()`
- [x] Level progression — LevelComplete BtnNext → `SaveManager.complete_level()` → next level
- [x] Star rating — 1 star (finish), 2 stars (≥50% coins), 3 stars (all coins)
- [x] Pause system — HUD BtnPause → `GameManager.pause_game()` → PauseMenu3D overlay (PROCESS_WHEN_PAUSED)

---

## Phase 7 — HUD & UI

### In-Game HUD (3D scene overlay via `CanvasLayer`)
- [x] Pause button (top-left, BtnPause)
- [x] Level number label (top-center, LblLevel)
- [x] Coin counter (LblCoins, updates on `coin_collected` signal)
- [x] Turn direction prompt (`LblTurnPrompt`) — large yellow label at bottom of screen shows "◀ TURN LEFT" or "TURN RIGHT ▶" when player enters a turn zone; hides on exit
- [~] Distance / score counter — deferred
- [x] Restart accessible via PauseMenu BtnRestart

### Menu Navigation
- [x] `SplashScreen` → `MainMenu` (auto after 2–3 s — existing SplashScreen.gd unchanged)
- [x] `MainMenu` → `LevelSelect` via Play button
- [x] `MainMenu` → `Shop`, `Settings`, `LoginPrompt`, `DailyChallenge` — all working
- [x] `LevelSelect` → `Game3D` (loads chosen level via `GameManager.go_to_gameplay_3d`)
- [x] `Game3D` → `LevelComplete` overlay on finish
- [x] `Game3D` → `GameOver` overlay on fail
- [x] `LevelComplete` → next level or `LevelSelect`
- [x] `GameOver` → retry or `LevelSelect`
- [x] All back buttons return to correct previous screen

---

## Phase 8 — Levels Content

- [x] **Level 1** — "Jungle Trail": 26 tiles, straight run, 7 obstacles — tutorial, no turn
- [x] **Level 2** — "Deep Forest": 33 tiles, 13 obstacles, **LEFT turn at row 20** (dir=-1)
- [x] **Level 3** — "River of Echoes": 40 tiles, 20 obstacles, **RIGHT turn at row 18** (dir=1)
- [x] **Level 4** — "Ancient Ruins": 45 tiles, 28 obstacles, **LEFT turn at row 22** (dir=-1)
- [x] **Level 5** — "Temple Approach": 50 tiles, 34 obstacles, **RIGHT turn at row 25** (dir=1)

All turn levels have: 3-tile approach cleared of obstacles, 3-tile exit cleared, two glowing floor arrows as cues, log-jam dam at far edge, full-screen HUD turn prompt.

---

## Phase 9 — Offline / Save / Login

- [x] Local save: current level, coins, stars per level — `SaveManager.gd` unchanged and working
- [x] Offline play: guest mode fully playable, no network required
- [x] Login prompt: shown after every 5 levels (existing `GameManager.should_show_login_prompt()`)
- [x] Logged-in state: stub placeholder (`is_logged_in` flag, pending real auth backend)

---

## Phase 10 — Performance & Polish

- [ ] Run on Android emulator or device — maintain 60 FPS on mid-tier phone
- [ ] All meshes under 5k triangles each
- [ ] Textures max 512×512 or 1024×1024
- [ ] No uncompressed PNG textures in 3D scenes — use Godot-imported compressed
- [ ] No memory leaks from unfreed level instances (use `queue_free()` on scene unload)
- [ ] Audio plays correctly: background music loops, SFX on coins/obstacles/menu buttons
- [ ] Portrait orientation locked — no accidental landscape rotation
- [ ] Review draw calls — keep below 200 per frame for mobile

---

## MVP Completion Checklist

The 3D pivot is ship-ready only when ALL of these pass:

- [x] Splash screen opens and transitions to Main Menu
- [x] All Main Menu buttons navigate to correct screens
- [x] Level Select shows levels 1–3 with lock/unlock state
- [x] Game3D scene loads and shows a 3D environment (no empty cube scene)
- [x] Player character is a visible 3D explorer (capsule placeholder — not a flat sprite)
- [x] Player runs forward automatically
- [x] Swipe controls move player between lanes and jump
- [x] Path turns work (Temple Run style): yellow arrow cues → HUD prompt → any swipe executes turn → character faces new direction → camera snaps behind instantly
- [x] Camera follows player in third-person view, stays behind on any heading
- [x] Coins can be collected (counter updates in HUD)
- [x] Obstacles can be hit (triggers Game Over) or avoided
- [x] Finish gate ends the level (shows LevelComplete screen)
- [x] LevelComplete shows stars earned and navigates forward
- [x] GameOver allows retry
- [x] Pause works and unpauses correctly
- [x] Settings (volume, vibration) saves and applies
- [x] Game runs offline with no crash
- [x] Progress saves between sessions
- [~] No visible placeholder cubes — colored geometry used; real assets still needed
- [x] At least 3 complete playable levels
- [~] Play Store screenshots — functional; art pass needed for final appeal

---

# Important Design Rule

The game must look like something a user would actually download.

It must not feel like:

* a prototype board
* a debug scene
* empty test cubes
* boxes pretending to be a jungle

It must feel like:

* a real 3D jungle mobile game
* a running adventure
* something visually alive

---

# Strong Recommendation

If full free-movement 3D becomes too complex, implement a **lane-based 3D runner** first.

That means:

* player automatically moves forward
* player switches left/center/right lanes
* player jumps obstacles
* player slides under barriers
* player collects coins
* player reaches finish

This is much easier to complete than a full 3D exploration system and still looks exciting.

---

# Asset Direction

If suitable 3D assets are missing, create a file:

```text
res://MISSING_3D_ASSETS.md
```

List missing items such as:

* explorer 3D model
* run animation
* jump animation
* jungle trees
* rocks
* ruins
* coins
* finish gate
* spikes
* logs
* HUD icons if needed

Do not hide missing asset gaps.

---

# Completion Conditions

This pivot is complete only when:

* the project is truly using 3D gameplay
* the player is a visible 3D explorer
* the camera is third-person
* the environment feels like a jungle
* movement is visible and satisfying
* the game no longer feels like a flat box puzzle
* at least 3 playable levels exist
* navigation works across menu screens
* the game is attractive enough for Play Store screenshots
* the experience looks like a real game, not a prototype
