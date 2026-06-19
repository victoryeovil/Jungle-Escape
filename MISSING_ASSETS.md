# Missing Assets List — Jungle Escape: Lost Path
*Last updated: 2026-06-17 (Session 5)*

Assets already present are NOT listed here. See `CHANGELOG.md` for what exists.

---

## 🔴 Critical — Game looks unfinished without these

### Fonts
`title_font.ttf` and `body_font.ttf` now exist in `assets/fonts/` and are wired through `UIStyle.gd`.

| File | Location | Purpose |
|------|----------|---------|
| `mono_font.ttf` | `assets/fonts/` | Optional move/coin counter font if fixed-width counters are needed later |

---

### HUD Icons
The requested HUD icon set now exists in `assets/ui/icons/`:
`icon_pause.png`, `icon_restart.png`, `icon_hint.png`, `icon_coin.png`, `icon_key.png`, `icon_star.png`.

| File | Location | Size | Purpose |
|------|----------|------|---------|
| `icon_moves.png` | `assets/ui/icons/` | 128×128 | Optional move counter icon |
| `icon_star_full.png` | `assets/ui/icons/` | 128×128 | Optional separate filled star rating icon |
| `icon_star_empty.png` | `assets/ui/icons/` | 128×128 | Optional separate empty star rating icon |

---

### Gameplay Backgrounds
`bg_gameplay.png` and `bg_main_menu.png` now exist in `assets/backgrounds/` and are wired into gameplay and main menu.

| File | Location | Size | Purpose |
|------|----------|------|---------|
| `bg_levelmap.png` | `assets/backgrounds/` | 720×1280 | Optional level selection screen background |

---

## 🟡 Important — Needed before Play Store submission

### UI Panels & Buttons
| File | Location | Size | Purpose |
|------|----------|------|---------|
| `panel_popup.png` | `assets/sprites/ui/` | 9-slice | Level complete / Game over popup background |
| `btn_primary.png` | `assets/sprites/ui/` | 9-slice | Main action button (Play, Next, Retry) |
| `btn_secondary.png` | `assets/sprites/ui/` | 9-slice | Secondary button (Map, Settings) |
| `btn_danger.png` | `assets/sprites/ui/` | 9-slice | Destructive button (Reset, Quit) |
| `icon_lock.png` | `assets/sprites/ui/` | 64×64 | Locked level indicator on Level Map |
| `icon_gem.png` | `assets/sprites/ui/` | 48×48 | Gem counter in Shop / HUD |

### World Map
| File | Location | Purpose |
|------|----------|---------|
| `world_1_banner.png` | `assets/sprites/ui/` | World 1 header on Level Map ("Jungle Path") |
| `world_2_banner.png` | `assets/sprites/ui/` | World 2 header ("Hidden Gates") |
| `world_3_banner.png` | `assets/sprites/ui/` | World 3 header ("Snake Temple") — locked |

---

## 🟢 Nice to Have — Polish and retention

### Player Animations
| File | Location | Purpose |
|------|----------|---------|
| `explorer_idle.png` | `assets/sprites/characters/` | 4-frame idle animation spritesheet |
| `explorer_walk.png` | `assets/sprites/characters/` | 4-frame walk animation spritesheet |
| `explorer_celebrate.png` | `assets/sprites/characters/` | 2-frame celebrate anim (level complete) |

> Each other skin also needs idle/walk sheets eventually.

### Tile Animations
| File | Location | Purpose |
|------|----------|---------|
| `coin_spin.png` | `assets/sprites/tiles/` | 4-frame coin spin spritesheet |
| `exit_glow.png` | `assets/sprites/tiles/` | 4-frame exit portal pulse |
| `gate_open.png` | `assets/sprites/tiles/` | 3-frame gate opening animation |

### Particle Effects (Godot `.tres` resources — no PNG needed)
| Resource | Purpose |
|----------|---------|
| `fx_coin_collect.tres` | Gold burst when coin picked up |
| `fx_level_complete.tres` | Confetti/stars explosion |
| `fx_gate_open.tres` | Dust puff when gate opens |
| `fx_teleport.tres` | Green shimmer for vine teleport |
| `fx_damage.tres` | Red flash when hitting a trap |

### Teaser / Social UI
| File | Location | Purpose |
|------|----------|---------|
| `teaser_lock_overlay.png` | `assets/sprites/ui/` | Darkened overlay on teaser preview levels |
| `badge_login.png` | `assets/sprites/ui/` | "Log in to unlock" badge shown in menus |
| `badge_challenge.png` | `assets/sprites/ui/` | Friend challenge notification badge |

---

## 📋 What Already Exists (for reference)

### Tile Sprites ✅
`floor.png, wall.png, river.png, bridge.png, coin.png, gem.png, key.png, gate.png, exit.png, spike.png, snake.png, mud.png, vine.png, switch.png, switch_active.png, fruit.png, chest.png, rock.png`

### Character Sprites ✅
`explorer.png, jungle_girl.png, monkey.png, robot.png, treasure.png, tribal.png, golden.png`

### UI ✅
`icon.png (app icon), splash.png (boot splash)`
`assets/ui/icons/icon_pause.png, icon_restart.png, icon_hint.png, icon_coin.png, icon_key.png, icon_star.png`
`assets/backgrounds/bg_gameplay.png, bg_main_menu.png`
`assets/fonts/title_font.ttf, body_font.ttf`

### Sounds ✅ (23 files)
`coin, gem, key, fruit, gate_open, locked, exit, damage, snake, splash, wood_step, mud, switch, vine_teleport, button, bump, level_complete, game_over, stars_1, stars_2, stars_3, music_menu, music_gameplay`

---

## How to Create Missing Assets

**Free sources:**
- **Kenney.nl** — Jungle Pack, UI Pack, Particle Pack, Fonts (CC0)
- **OpenGameArt.org** — search "jungle tiles", "mobile UI"
- **Google Fonts** — Nunito, Fredoka One, Press Start 2P (OFL licence)
- **itch.io** — many free game asset packs

**Minimum viable set to look polished:**
1. `body_font.ttf` and `title_font.ttf` — done
2. `bg_main_menu.png` and `bg_gameplay.png` — done
3. `icon_star.png` — done
4. `icon_pause.png`, `icon_restart.png`, `icon_hint.png` — done
