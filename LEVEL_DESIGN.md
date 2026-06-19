# LEVEL DESIGN DOCUMENT — Jungle Escape: Lost Path

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
