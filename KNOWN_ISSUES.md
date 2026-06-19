# KNOWN ISSUES — Jungle Escape: Lost Path

## Active Issues (3D Gameplay)

### KI-011 — Multiple turns per level not tested
**Severity:** Low (all current levels have one turn each)
**Status:** Pending
Adding a second turn to a single level requires the cursor iterator in `_parse_turns` to handle consecutive rotations. The code supports it structurally but no level has been created with two turns yet.
**Fix:** Add a test JSON with `"turns": [{"row":10,"dir":-1},{"row":25,"dir":1}]` and play through to validate geometry continuity and trigger zone independence.

### KI-012 — Jump/land animation clips missing
**Severity:** Low (physics jump works correctly)
**Status:** Pending Phase 3D
The Quaternius Kairo and Zuri GLBs do not include dedicated jump/land clips.
**Fix:** Source Quaternius Universal Animation Library or record custom clips in Blender, then wire into `Player3D._update_character_animation()`.

### KI-013 — Android export not yet configured
**Severity:** High (cannot produce APK)
**Status:** Pending Phase 5
Supersedes KI-007 — same root issue, now for the 3D scene.
**Fix:** Open Godot editor → Project → Export → Add Android → configure SDK paths, package name, keystore.

---

## Active Issues (2D — Archived)

### KI-003 — Login is simulated
**Severity:** Medium (for social features only)  
**Status:** Pending Phase 4  
`LoginPrompt.gd` calls `_simulate_login()` — no real Firebase/Supabase call.  
**Fix:** Integrate `godot-firebase` plugin or Supabase REST API. Wire `EventBus.login_completed`.

### KI-004 — Cloud save is not implemented
**Severity:** Low (local save works fully)  
**Status:** Pending Phase 4  
`SaveManager.add_pending_sync()` queues actions but nothing uploads them.  
**Fix:** Add a sync worker that reads `get_pending_sync()` and POSTs to the backend on reconnect.

### KI-005 — Levels 21–50 do not exist
**Severity:** Low (MVP is levels 1–20)  
**Status:** Pending Phase 3/4  
Worlds 3 (Snake Temple), 4 (River Ruins), and 5 (Lost Cave) have no JSON level files.  
**Fix:** Design and write `level_021.json` through `level_050.json`.

### KI-007 — Android export preset not configured
**Severity:** High (cannot build APK without it)  
**Status:** Pending Phase 5  
`export_presets.cfg` is absent. Android SDK + JDK must be installed.  
**Fix:** Open Godot editor → Project → Export → Add Android → configure SDK paths, package name, sign with keystore.

### KI-009 — Level 5 grid has a malformed row
**Severity:** Fixed in Session 2  
**Status:** ✅ Resolved — row corrected to `"W.W.WWWWW"`

---

## Resolved Issues

### 3D Gameplay — Session 13–14
- **3D-001** — Void gap at level 2 turn: wall placed 4.65 m past tile centre left 3.15 m of air. Fixed: replaced wall with log-jam dam at exact tile far edge (1.5 m past centre). ✅
- **3D-002** — No room to turn: trigger zone only 6 m. Fixed: widened to 12 m (4 tiles) with queued-turn system so player can swipe 3 tiles early. ✅
- **3D-003** — Player turns right automatically: `right_comp` without baseline used world-absolute Z (≈60) as target, dragging player back up the old path. Fixed: `_right_comp_baseline = corner_pos.dot(new_move_right)` makes all lane targets relative to the new path segment. ✅
- **3D-004** — Rock at row 22 kills player 1 tile after turn: obstacle clear zone ended at `tr`. Fixed: extended to `tr+3` (3 clear tiles on exit side). ✅
- **3D-005** — Camera faces backward after turn: `atan2(to_player.x, -to_player.z)` had wrong sign on X (invisible on straight paths where X=0). Fixed: `atan2(-to_player.x, -to_player.z)`. ✅
- **3D-006** — Camera too slow after turn: `delta*4.0` lerp took 0.25 s. Fixed: instant snap when offset > 2.45 m, then `delta*8` lerp. ✅
- **3D-007** — Character runs sideways after turn: `_execute_turn` changed heading vectors but never rotated the node. Fixed: `rotation.y = atan2(-_move_fwd.x, -_move_fwd.z)` in `_execute_turn`; `rotation.y = 0` in `reset()`. ✅
- **3D-008** — Levels 3 and 5 (right turns) never triggered: `move_lane` required `direction == _turn_zone_dir`, so a left swipe on a right-turn level just changed lanes. Fixed: any swipe in turn zone queues `_turn_zone_dir` regardless of swipe direction. ✅

### 2D Game — Sessions 1–6
- KI-001 — Starter `Sprite2D` tile and player art added under `assets/sprites/`; `ColorRect` remains only as a fallback.
- KI-002 — Starter SFX and music WAV files added under `assets/sounds/` and preloaded in `AudioManager`.
- KI-006 — `assets/sprites/ui/icon.png` and `assets/sprites/ui/splash.png` added.
- KI-008 — `get_tree().back()` replaced with proper `GameManager.go_to_menu()` / `restart_level()` in Settings.gd, Shop.gd, and LoginPrompt.gd (Session 4).
- KI-010 — `Grid._parse_switch_gates()` added; reads `"switch_gates"` from level JSON (Session 4).
- Profile.tscn — Created `scenes/menus/Profile.tscn` + `scripts/ui/Profile.gd` (Session 4).
