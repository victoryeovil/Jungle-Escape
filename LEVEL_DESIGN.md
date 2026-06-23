# LEVEL DESIGN DOCUMENT — Jungle Escape: Lost Path

## 3D Runner Path System - Levels 1-20

The active 3D runner levels live at `data/levels3d/level3d_NNN.json`. Each level now includes a `path_modules` array. The runtime reads these modules in `LevelManager3D.gd` and converts them into curved row transforms, path widths, surfaces, gameplay modes, route signs, junction triggers, and mode-specific graphics.

### Supported Path Modules

`straight_short`, `straight_long`, `gentle_curve_left`, `gentle_curve_right`, `wide_curve_left`, `wide_curve_right`, `s_curve`, `narrow_passage`, `bridge_crossing`, `water_slide_entry`, `water_slide_curve`, `water_slide_drop`, `boat_entry_dock`, `boat_river_straight`, `boat_river_curve`, `boat_rapids`, `ruins_corridor`, `sand_dune_curve`, `mud_path`, `tree_root_jump_section`, `animal_chase_lane`, `animal_escape_section`, `junction_two_way`, `junction_three_way`, and `finish_gate_approach`.

### Runtime Modes

- `run`: normal lane switching, jump, slide, coins, resources, and obstacles.
- `tracking`: slower path reading with footprints and trail clues.
- `chase`: faster observation chase sections with an animal visible ahead.
- `escape`: high-speed survival pressure with camera shake and warning signs.
- `water_slide`: blue channel path, splash effects, water rocks, floating logs, and a lower camera.
- `boat`: canoe visual, river path, reeds, docks, rapids, crocodile danger zones, and a pulled-back camera.

### Junction Input Rule

Normal sections keep controls simple: left/right move lanes, up jumps, down slides. Junction trigger zones change the meaning briefly: left chooses the left route, right chooses the right route, and up chooses the center route when present. The chosen route spawns an immediate reward trail and HUD feedback.

### Level 1-20 Identities

1. Jungle Trail Entrance - curved tutorial trail, simple bridge, log and branch basics.
2. Deep Forest Bend - S-curve, narrow trees, first 2-way safe/reward split.
3. River of Echoes - muddy river bank, bridge crossing, first tracking-flavored mud section.
4. Ancient Ruins Corridor - narrow stone corridors and ruin wall pressure.
5. Temple Approach - 3-way temple route choice: coin, safe, or relic route.
6. Wildlands of Peace - sand, wide clearings, narrow sandy passage, peaceful wildlife.
7. First Clearing - home-material clearing with material-vs-coin split.
8. Foundation Run - construction supply trail with brick/tool shortcut choice.
9. Timber Trail - S-curve forest route, roots, logs, and wood supplies.
10. Lost Paw Trail - paw-print tracking and dog-token route choice.
11. Rabbit Tracks - first chase mode with 3-way rabbit/safe/clue split.
12. Water Slide Trail - water-slide entry, curves, drop, water tokens and fish token.
13. Park Guide Path - guide/observation route with safe wildlife markers.
14. Warthog Watch - tracking and safe-distance observation through mud and shrubs.
15. Market River Dock - market path into first boat tutorial.
16. Antelope Trail - fast chase through wide sand with hoofprint route decisions.
17. Rapids Run - full boat mode, river fork, crocodile zones, whirlpool, river relic.
18. Hound of the Hidden Trail - dog-guided tracking, false path, relic and map choices.
19. Boar Escape - survival escape mode through mud, thorns, planks, and safe finish.
20. Treasure Beneath the Baobab - combined chase, water slide, treasure junction, ruins, and boat bend.

### Design Rules For 3D Levels

1. Every 3D level must include at least one curve and at least two path widths.
2. Junctions must show signs and route arrows before the trigger zone.
3. Animal encounters use tracking, observation, chase, or escape; the player does not attack animals.
4. Water-slide and boat sections must use their own surface, camera, HUD prompt, and visible mode graphics.
5. Later levels should combine earlier mechanics rather than only adding more obstacles.

## Grid Format

Each level is a JSON file at `data/levels/level_NNN.json`.

```json
{
  "level_id": 1,
  "world": "Jungle Path",
  "name": "Level Display Name",
  "move_limit": 18,
  "perfect_moves": 12,
  "grid": [
    "WWWWWW",
    "WP...W",
    "W.C..W",
    "W..K.W",
    "W..GEW",
    "WWWWWW"
  ],
  "legend": { ... },
  "hint": "Optional hint shown when player uses a hint token."
}
```

**move_limit:** 0 = unlimited. Any positive value caps moves (over-limit → 1 star only).  
**perfect_moves:** Completing within this count earns 3 stars.  
Between perfect_moves and move_limit = 2 stars. At move_limit = 1 star.

## Tile Legend

| Char | Tile       | Effect                                   |
|------|------------|------------------------------------------|
| W    | Wall       | Impassable                               |
| .    | Floor      | Normal passable tile                     |
| P    | Player     | Player start position                    |
| C    | Coin       | +1 coin, disappears on pickup            |
| M    | Gem        | +1 gem (rare), disappears                |
| F    | Fruit      | +2 coins, disappears                     |
| K    | Key        | Adds 1 key to inventory, disappears      |
| G    | Gate       | Blocks passage; needs 1 key to open      |
| E    | Exit       | Completes the level                      |
| S    | Spike      | Instant game over                        |
| N    | Snake      | Instant game over                        |
| R    | River      | Instant game over (no bridge)            |
| B    | Bridge     | Safe floor over river                    |
| U    | Mud        | Passable; costs +1 extra move            |
| X    | Switch     | Opens linked gate (see switch_id)        |
| V    | Vine       | Teleports player to paired vine tile     |
| T    | Chest      | Bonus reward (future use)                |

## World Progression

### World 1 — Jungle Path (Levels 1–10)
**Theme:** Simple open grids, learn swiping, collect coins.  
**New mechanics:** Coins, Gems, Fruit, Move Limit (introduced level 6).  
**Rule:** No hazards in levels 1–5. Mild maze complexity.

### World 2 — Hidden Gates (Levels 11–20)
**Theme:** Locked areas, scarce keys, tight move budgets.  
**New mechanics:** Keys, Gates, Spikes (level 16), Snakes (level 19).  
**Rule:** At least one key/gate sequence per level. Move limit always active.

### World 3 — Snake Temple (Levels 21–30) — TO BUILD
**Theme:** Danger everywhere; optional treasure routes with real risk.  
**New mechanics:** Multiple snakes, spike fields, optional gem routes.  
**Rule:** Player must choose safe path vs. risky high-reward path.

### World 4 — River Ruins (Levels 31–40) — TO BUILD
**Theme:** Rivers, bridges, mud, switches.  
**New mechanics:** River tiles, Bridges, Mud (double move cost), Switches.  
**Rule:** At least one river crossing using a bridge per level.

### World 5 — Lost Cave (Levels 41–50) — TO BUILD
**Theme:** Complex, non-linear, multi-mechanic puzzles.  
**New mechanics:** Vine teleporters, moving rocks (future), friend challenge levels.  
**Rule:** Two vine pairs minimum. Hardest difficulty; hints expected.

## Design Rules
1. Level 1 must be completable by anyone in under 30 seconds.
2. Each 5-level group introduces or combines a mechanic.
3. Every level must be solvable without hints.
4. No level should require luck — every danger is visible in advance.
5. Coins/gems should always be reachable (never blocked behind unsolvable puzzles).
6. Test that move_limit allows at least one valid solution.
7. Alternate "easy" and "hard" levels — don't stack difficulty.
8. Add a hint string that describes the key insight, not just "reach the exit."

## Future Level Additions
- Add levels 21–50 following the world rules above.
- Each level file: `level_021.json` … `level_050.json`.
- After 50 levels, consider weekly puzzle content via remote level config.
