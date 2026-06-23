# Agent Prompt — Introduce Lives System After Level 3 for Retention and Future Ads

## Main Objective

Introduce a **Lives / Energy System** after **Level 3**.

The first three levels should remain free and easy so the player can learn the game without pressure. After Level 3, the game should introduce lives as part of the survival journey.

This system will later support rewarded ads, but ads do not need to be implemented immediately.

---

# When Lives Start

Lives must only begin after the player completes Level 3.

## Reason

Levels 1–3 are the beginner introduction:

```text
Level 1: Basic running
Level 2: Curves and obstacles
Level 3: River of Echoes introduction
```

After Level 3, the jungle becomes more dangerous, so the player now needs lives.

---

# Story Introduction After Level 3

After completing Level 3, show this story message:

```text
The River of Echoes has tested your courage.

From here, the Lost Path becomes more dangerous. Ancient ruins, wild trails, deep forests, and hidden traps await.

You now have Expedition Lives. Lose a life when you fail a run, but recover them over time, earn them through rewards, or continue your journey with help from the expedition camp.
```

---

# Lives System Rules

## Starting Lives

After Level 3, give the player:

```text
5 lives maximum
```

## When a Life Is Lost

The player loses 1 life when:

```text
player hits a major obstacle
player falls into water
player fails a chase
player crashes during boat mode
player fails a survival escape
player runs out of time in a challenge
```

## When a Life Is Not Lost

Do not remove a life when:

```text
player pauses
player exits level before starting
game crashes
player returns to menu
player is in tutorial levels 1–3
```

---

# Life Recovery

Lives should recover naturally.

Recommended system:

```text
1 life regenerates every 15 minutes
maximum lives: 5
```

If the player has no lives, show:

```text
No Lives Left

Your explorer needs to rest before continuing the Lost Path.
```

Options:

```text
Wait for lives to recover
Use coins to refill
Use gems to refill
Watch rewarded ad for +1 life later
Return to camp/home
```

---

# Future Ads Hook

Rewarded ads should be planned but not forced yet.

## Future rewarded ad options

Later, ads can be used for:

```text
Watch ad to gain +1 life
Watch ad to revive once
Watch ad to double rewards
Watch ad to speed up life recovery
Watch ad to retry a failed level
```

## Important Rule

Ads must feel optional and rewarding, not annoying.

Do not show forced ads after every failure.

---

# Suggested Life Costs

## Refill with coins

```text
1 life = 50 coins
Full refill = 200 coins
```

## Refill with gems

```text
1 life = 1 gem
Full refill = 4 gems
```

These values can be adjusted later for balancing.

---

# UI Requirements

Add lives to the HUD after Level 3.

## HUD Display

Show:

```text
Heart icon x current lives
```

Example:

```text
❤️ 5/5
```

## Main Menu

After Level 3, show lives near coins and gems:

```text
Coins | Gems | Lives
```

## Level Select / Jungle Map

Before starting a level after Level 3, check lives.

If lives are available:

```text
Start Expedition
```

If no lives:

```text
No Lives Left
Recover lives to continue.
```

---

# Required Function Logic

Add a clean function for checking if the player can start a level.

```gdscript
func can_start_level(level_id: int) -> bool:
	if level_id <= 3:
		return true

	if player_stats.lives <= 0:
		show_no_lives_popup()
		return false

	return true
```

---

# Losing a Life

```gdscript
func lose_life() -> void:
	if current_level_id <= 3:
		return

	if player_stats.lives > 0:
		player_stats.lives -= 1
		save_progress()
		update_lives_ui()
```

---

# Life Regeneration

Create a simple time-based regeneration system.

```gdscript
func regenerate_lives() -> void:
	var max_lives = 5
	var regen_minutes = 15

	if player_stats.lives >= max_lives:
		return

	var now = Time.get_unix_time_from_system()
	var elapsed_seconds = now - player_stats.last_life_regen_time
	var lives_to_add = int(elapsed_seconds / (regen_minutes * 60))

	if lives_to_add > 0:
		player_stats.lives = min(max_lives, player_stats.lives + lives_to_add)
		player_stats.last_life_regen_time = now
		save_progress()
		update_lives_ui()
```

---

# No Lives Popup

Create a polished popup.

## Text

```text
No Lives Left

The jungle is dangerous. Rest at camp or recover a life to continue your expedition.
```

## Buttons

```text
Use 50 Coins
Use 1 Gem
Watch Ad for +1 Life
Return to Camp
```

If ads are not implemented yet, disable the ad button and show:

```text
Reward ads coming soon.
```

---

# Revive System

Later, when the player fails a level, show:

```text
Continue Run?

Use 1 life to retry from checkpoint, or return to the map.
```

Future ad option:

```text
Watch ad to revive once.
```

For now, implement the UI hook even if ads are not active.

---

# Balancing Rules

The lives system must not frustrate new players.

Use these rules:

```text
No lives required for Levels 1–3
Lives start only after Level 3
Maximum lives: 5
Life regeneration: 15 minutes
Give +2 bonus lives when system is first introduced
Allow replay of completed levels if lives are available
Do not drain lives unfairly from crashes or menu exits
```

---

# Story Naming

Use story-friendly wording.

Instead of just:

```text
Lives
```

Use:

```text
Expedition Lives
```

Instead of:

```text
Energy
```

Use:

```text
Explorer Energy
```

Preferred term:

```text
Expedition Lives
```

---

# Required Assets

Update or create:

```text
res://MISSING_UI_ASSETS.md
```

Add:

```md
## Lives System
- Heart/life icon
- Empty heart icon
- Lives refill popup background
- Revive popup background
- Life timer icon
- Rewarded ad life icon
```

---

# Required Files to Update

## Update `CHANGELOG.md`

Append:

```md
## [Unreleased] - Expedition Lives System

### Added
- Added Expedition Lives system after Level 3.
- Added 5 maximum lives for post-Level 3 gameplay.
- Added life loss on failed runs after Level 3.
- Added time-based life regeneration.
- Added no-lives popup.
- Added future rewarded ad hooks for gaining lives, revives, and reward doubling.
- Added lives display for HUD, main menu, and map screen.

### Changed
- Levels 1 to 3 remain free tutorial levels without lives.
- Post-Level 3 gameplay now has stronger survival progression.

### Notes
- Ads do not need to be implemented immediately.
- Rewarded ads should be optional and should not feel forced.
```

---

## Update `checkpoint.md`

Add:

```md
## Current Monetization / Retention Focus
The game now introduces Expedition Lives after Level 3 to support survival tension, retention, and future rewarded ads.

## Completed / In Progress
- Lives system requested after Level 3.
- Life regeneration requested.
- No-lives popup requested.
- Future rewarded ad hooks requested.
- Lives UI requested.

## Still Needed
- Implement lives save data.
- Add heart/life UI icons.
- Add life regeneration timer.
- Add no-lives popup.
- Add revive popup.
- Add rewarded ad placeholder hooks.
- Balance life loss and refill costs.

## Next Recommended Step
Implement the lives system without real ads first, then add rewarded ads later once the game is polished.
```

---

# Completion Conditions

This task is complete only when:

* Levels 1–3 do not require lives.
* Lives are introduced after Level 3.
* Player starts with 5 lives.
* Failed runs after Level 3 remove 1 life.
* Lives regenerate over time.
* No-lives popup works.
* Lives are saved locally.
* Lives display appears in HUD/menu/map.
* Rewarded ad hooks exist for future ad integration.
* `CHANGELOG.md` is updated.
* `checkpoint.md` is updated.
* Missing UI assets are documented.

---

# Important Design Rule

Lives must make the jungle feel more dangerous, not make the player feel punished.

The player should feel:

```text
The Lost Path is becoming dangerous. I need to survive carefully.
```

Not:

```text
The game is blocking me unfairly.
```
