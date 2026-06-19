# Agent Prompt — Explorer Unlocks, Character Preview, and Special Powers System

## Main Objective

Add a proper **Explorer Unlock and Power System** to **Jungle Escape: Lost Path**.

The player must be able to:

* unlock new explorers
* preview explorers before buying or equipping
* see each explorer’s special powers
* equip explorers
* upgrade explorer powers
* understand why each explorer is useful
* feel motivated to collect resources and continue playing

This system must make skins feel valuable, not just cosmetic pictures.

---

# Current Problem

The current skins/shop screen is too simple.

It shows character names, but the player does not clearly feel:

* what each explorer looks like
* why they should unlock them
* what power each explorer has
* what benefits the explorer gives
* how the explorer fits into the story
* how the explorer helps in different levels

The new system must make explorers feel exciting and useful.

---

# New Feature: Explorer Gallery

Create an **Explorer Gallery** screen where the player can view all explorers.

Suggested scene:

```text
res://scenes/ExplorerGallery.tscn
```

The screen should include:

* large 3D character preview
* explorer name
* explorer story role
* unlock requirement
* special power
* power level
* equip button
* unlock/buy button
* upgrade power button
* locked/unlocked/equipped states

The player must be able to rotate or preview the explorer visually.

---

# Explorer Preview Requirement

When the player taps an explorer, show a full preview panel.

## Required preview details

Each explorer preview must show:

```text
Explorer Name
3D model preview
Short story description
Special power
Power level
Unlock requirement
Equip / Buy / Upgrade button
```

## Preview behavior

The 3D character preview should:

* show the full explorer
* use idle animation
* optionally rotate slowly
* allow left/right rotation if possible
* show outfit clearly
* feel polished and exciting

Do not show only small icons.

---

# Explorer Unlock States

Every explorer must support these states:

```text
locked
available_to_unlock
unlocked
equipped
upgrade_available
max_power
```

## Locked

The player cannot use the explorer yet.

Show:

```text
Locked
Complete requirement to unlock this explorer.
```

## Available to Unlock

The player has enough resources.

Show:

```text
Unlock Explorer
```

## Unlocked

The player owns the explorer but has not equipped them.

Show:

```text
Equip
```

## Equipped

The explorer is currently active.

Show:

```text
Equipped
```

## Upgrade Available

The explorer has a power that can be upgraded.

Show:

```text
Upgrade Power
```

---

# New Explorer Powers

Add special powers that give each explorer a unique gameplay advantage.

The powers must be useful, but not unfair. The player should still need skill.

---

## Power 1 — Coin Magnet

### Description

Attracts nearby coins toward the player.

### Gameplay effect

Coins within a small radius move toward the player automatically.

### Upgrade levels

```text
Level 1: small magnet radius
Level 2: medium magnet radius
Level 3: large magnet radius
```

### Suggested explorer

```text
Treasure Hunter
```

### UI text

```text
Coin Magnet
Pulls nearby coins toward you while running.
```

---

## Power 2 — Gem Sense

### Description

Highlights rare gems and hidden collectibles.

### Gameplay effect

Rare items glow when the player is near them.

### Upgrade levels

```text
Level 1: highlights gems nearby
Level 2: highlights gems and relic keys
Level 3: highlights gems, relic keys, and Sunstone Shards
```

### Suggested explorer

```text
Zuri
```

### UI text

```text
Gem Sense
Reveals hidden treasures along the Lost Path.
```

---

## Power 3 — Sand Step

### Description

Improves movement on sand terrain.

### Gameplay effect

Reduces sand slowdown and improves jump timing on sandy paths.

### Upgrade levels

```text
Level 1: reduced sand slowdown
Level 2: no sand slowdown
Level 3: longer sand jump distance
```

### Suggested explorer

```text
Wildlands Scout
```

### UI text

```text
Sand Step
Move smoothly through sandy paths and jump farther across sandy gaps.
```

---

## Power 4 — Animal Calm

### Description

Helps the explorer move peacefully around animals.

### Gameplay effect

Peaceful animals stay calm nearby. Some wildlife hazards give the player more reaction time.

### Upgrade levels

```text
Level 1: peaceful animals do not startle
Level 2: snakes react slower
Level 3: animal hazards give extra warning
```

### Suggested explorer

```text
Tribal Adventurer
```

### UI text

```text
Animal Calm
Move with respect through wildlife areas and gain more reaction time near animals.
```

Important: this power must promote respect for animals, not control or harm.

---

## Power 5 — Shield Charm

### Description

Protects the player once from a hit.

### Gameplay effect

The first obstacle hit in a level is blocked once.

### Upgrade levels

```text
Level 1: one shield every 3 runs
Level 2: one shield every 2 runs
Level 3: one shield every run
```

### Suggested explorer

```text
Temple Guardian
```

### UI text

```text
Shield Charm
Blocks one mistake and lets you continue the expedition.
```

---

## Power 6 — Double Supplies

### Description

Increases chance of collecting building resources.

### Gameplay effect

Bricks, wood, tiles, food, and tools have a chance to double after pickup.

### Upgrade levels

```text
Level 1: 10% chance
Level 2: 20% chance
Level 3: 30% chance
```

### Suggested explorer

```text
Camp Builder
```

### UI text

```text
Double Supplies
Chance to double building materials collected during treasure hunts.
```

---

## Power 7 — Map Reader

### Description

Helps unlock hidden paths and map pieces.

### Gameplay effect

Increases the chance of finding map pieces and hidden routes.

### Upgrade levels

```text
Level 1: small map piece bonus
Level 2: medium map piece bonus
Level 3: unlocks hidden trail hints
```

### Suggested explorer

```text
Kairo
```

### UI text

```text
Map Reader
Find map pieces faster and reveal hidden parts of the Lost Path.
```

---

# Suggested Explorer List

Create or update the explorer list with these characters.

## 1. Kairo — Default Explorer

### Unlock

Unlocked from start.

### Power

Map Reader

### Story role

A brave explorer following his grandfather’s lost journal.

### Description

```text
Kairo follows the Lost Path with courage and instinct. His knowledge of old maps helps reveal hidden routes through the jungle.
```

---

## 2. Zuri — Default / Early Unlock

### Unlock

Unlocked from start or after Level 2.

### Power

Gem Sense

### Story role

A skilled pathfinder connected to nature.

### Description

```text
Zuri reads the jungle better than anyone. She can sense rare treasures and hidden signs along the path.
```

---

## 3. Treasure Hunter

### Unlock

Cost: 500 coins or complete Level 5.

### Power

Coin Magnet

### Description

```text
A skilled collector who never misses treasure. Nearby coins are drawn toward this explorer during a run.
```

---

## 4. Wildlands Scout

### Unlock

Buy Sand Shoes and complete Level 6.

### Power

Sand Step

### Description

```text
A scout trained for dry paths and open wildlands. Moves better on sandy terrain and jumps across sandy gaps with confidence.
```

---

## 5. Tribal Adventurer

### Unlock

Collect 3 Animal Discovery Badges.

### Power

Animal Calm

### Description

```text
A respectful adventurer who understands the rhythm of wildlife. Animals nearby stay calmer, giving safer movement through living jungle spaces.
```

---

## 6. Camp Builder

### Unlock

Collect 20 bricks, 10 wood, and 5 tools.

### Power

Double Supplies

### Description

```text
A practical explorer focused on building a safe expedition home. Has a chance to double building materials during treasure hunts.
```

---

## 7. Temple Guardian

### Unlock

Collect 5 Sunstone Shards.

### Power

Shield Charm

### Description

```text
An ancient guardian outfit awakened by Sunstone energy. Protects the player from one mistake during dangerous runs.
```

---

# Explorer Unlock Requirements

Unlock requirements should use in-game progression and resources.

Examples:

```text
Complete Level 5
Collect 500 coins
Collect 5 gems
Collect 3 Animal Discovery Badges
Buy Sand Shoes
Collect 20 bricks
Collect 5 Sunstone Shards
Complete Daily Expedition 3 times
```

Do not make the system feel like a forced paywall.

Players must be able to unlock explorers through gameplay.

---

# Power Upgrade System

Each explorer power should have upgrade levels.

Suggested maximum:

```text
Power Level 1
Power Level 2
Power Level 3
```

## Upgrade cost examples

```text
Level 1 -> Level 2: 200 coins + 2 gems
Level 2 -> Level 3: 500 coins + 5 gems + special resource
```

Special resources can include:

```text
sunstone_shards
map_pieces
animal_badges
tools
relic_keys
```

---

# Inventory Integration

Update the inventory system to track:

```text
owned_explorers
equipped_explorer
explorer_power_levels
```

Example data structure:

```gdscript
var owned_explorers = {
	"kairo": true,
	"zuri": true,
	"treasure_hunter": false,
	"wildlands_scout": false,
	"tribal_adventurer": false,
	"camp_builder": false,
	"temple_guardian": false
}

var equipped_explorer = "kairo"

var explorer_power_levels = {
	"kairo": 1,
	"zuri": 1,
	"treasure_hunter": 0,
	"wildlands_scout": 0,
	"tribal_adventurer": 0,
	"camp_builder": 0,
	"temple_guardian": 0
}
```

---

# Gameplay Power Hooks

Add a clean power system that activates based on the equipped explorer.

Example:

```gdscript
func apply_explorer_power(explorer_id: String) -> void:
	match explorer_id:
		"kairo":
			enable_map_reader()
		"zuri":
			enable_gem_sense()
		"treasure_hunter":
			enable_coin_magnet()
		"wildlands_scout":
			enable_sand_step()
		"tribal_adventurer":
			enable_animal_calm()
		"camp_builder":
			enable_double_supplies()
		"temple_guardian":
			enable_shield_charm()
```

---

# Coin Magnet Function Example

Implement a coin magnet power for the Treasure Hunter.

```gdscript
func apply_coin_magnet(delta: float) -> void:
	if equipped_explorer != "treasure_hunter":
		return

	var power_level = explorer_power_levels.get("treasure_hunter", 1)
	var magnet_radius = 3.0 + float(power_level) * 1.5

	for coin in get_tree().get_nodes_in_group("collectibles_coin"):
		var distance = player.global_position.distance_to(coin.global_position)
		if distance <= magnet_radius:
			coin.global_position = coin.global_position.move_toward(
				player.global_position,
				delta * 8.0
			)
```

---

# Gem Sense Function Example

```gdscript
func apply_gem_sense() -> void:
	if equipped_explorer != "zuri":
		return

	var power_level = explorer_power_levels.get("zuri", 1)

	for collectible in get_tree().get_nodes_in_group("rare_collectibles"):
		var distance = player.global_position.distance_to(collectible.global_position)

		if distance <= 8.0 + power_level * 2.0:
			collectible.show_highlight()
```

---

# Sand Step Function Example

```gdscript
func apply_sand_step(terrain_type: String) -> void:
	if terrain_type != "sand":
		return

	if equipped_explorer == "wildlands_scout":
		var power_level = explorer_power_levels.get("wildlands_scout", 1)

		if power_level == 1:
			player.set_speed_modifier(0.8)
		elif power_level == 2:
			player.set_speed_modifier(1.0)
		elif power_level >= 3:
			player.set_speed_modifier(1.0)
			player.set_jump_modifier(1.2)
	else:
		player.set_speed_modifier(0.45)
```

---

# Explorer Gallery UI Layout

Design the Explorer Gallery as a premium jungle-themed screen.

## Top area

```text
← Back
Explorer Gallery
Coins / Gems
```

## Center area

```text
Large 3D Explorer Preview
Explorer Name
Power Badge
```

## Lower area

```text
Story Description
Special Power Description
Unlock Requirement
Equip / Unlock / Upgrade Button
```

## Side or bottom carousel

```text
Kairo | Zuri | Treasure Hunter | Wildlands Scout | Tribal Adventurer | Camp Builder | Temple Guardian
```

---

# Visual Style

The Explorer Gallery should feel like an expedition camp.

Add:

* jungle background
* campfire glow
* explorer crates
* hanging map
* animal silhouettes
* moving butterflies/birds
* character standing on a small platform
* soft lighting
* polished buttons

It must not look like a plain green list.

---

# Map Integration

Add explorer unlock markers to the jungle map.

Examples:

```text
Complete Level 5 to unlock Treasure Hunter
Complete Level 6 to unlock Wildlands Scout
Collect Animal Badges to unlock Tribal Adventurer
Collect Sunstone Shards to unlock Temple Guardian
```

The map should tease future explorers.

Example locked node message:

```text
A new explorer is waiting at the Wildlands Camp. Complete Level 6 to meet them.
```

---

# Shop Integration

The shop should include tabs:

```text
Explorers
Upgrades
Resources
Skins
```

The Explorer tab should open the same preview system or link to Explorer Gallery.

---

# Story Integration

Explorer unlocks must feel part of the story.

Examples:

```text
A new explorer has joined the expedition.
```

```text
The Wildlands Scout offers to guide you through sandy paths.
```

```text
The Temple Guardian outfit awakens as the Sunstone Shards glow.
```

```text
The Camp Builder can help turn your land into a true expedition home.
```

---

# Required Files to Update

## Update `CHANGELOG.md`

Append:

```md
## [Unreleased] - Explorer Unlocks and Powers Update

### Added
- Added Explorer Gallery concept with large character preview.
- Added unlockable explorers with unique story roles.
- Added special explorer powers including Coin Magnet, Gem Sense, Sand Step, Animal Calm, Shield Charm, Double Supplies, and Map Reader.
- Added explorer power upgrade levels.
- Added explorer preview, equip, unlock, and upgrade states.
- Added gameplay hooks for equipped explorer powers.
- Added map and shop integration for explorer unlocks.

### Changed
- Expanded skins from cosmetic-only items into meaningful explorers with gameplay advantages.
- Improved player motivation to collect resources, complete levels, and unlock new characters.

### Notes
- Explorer powers must support gameplay without making the game unfair.
- Explorers should be unlockable through in-game progress and resources.
```

---

## Update `checkpoint.md`

Add or update:

```md
## Current Explorer System Focus
The game now requires an Explorer Gallery where players can preview, unlock, equip, and upgrade explorers with special powers.

## Completed / In Progress
- Explorer unlock system requested.
- Explorer preview system requested.
- Unique explorer powers requested.
- Coin Magnet, Gem Sense, Sand Step, Animal Calm, Shield Charm, Double Supplies, and Map Reader requested.
- Explorer Gallery UI direction requested.
- Shop and map integration requested.

## Still Needed
- Build `ExplorerGallery.tscn`.
- Add large 3D preview support.
- Add explorer unlock data.
- Add equipped explorer save data.
- Add explorer power upgrade data.
- Implement Coin Magnet.
- Implement Gem Sense.
- Implement Sand Step.
- Implement Animal Calm.
- Implement Shield Charm.
- Implement Double Supplies.
- Connect Explorer Gallery to Shop and Map.
- Add missing explorer models/animations if needed.

## Next Recommended Step
Build the Explorer Gallery first, then implement the equipped explorer data, then add Coin Magnet as the first working power.
```

---

# Missing Assets Update

Update or create:

```text
res://MISSING_3D_ASSETS.md
```

Add:

```md
## Explorers
- Treasure Hunter 3D model
- Wildlands Scout 3D model
- Tribal Adventurer 3D model
- Camp Builder 3D model
- Temple Guardian 3D model

## Explorer Animations
- Idle preview animation
- Run animation
- Jump animation
- Slide animation
- Victory animation
- Hit/stumble animation

## Power Effects
- Coin Magnet visual effect
- Gem Sense highlight effect
- Sand Step dust effect
- Animal Calm aura effect
- Shield Charm effect
- Double Supplies pickup effect
- Map Reader reveal effect

## UI
- Explorer Gallery background
- Power badge icons
- Unlock button
- Equip button
- Upgrade button
- Power level indicators
```

---

# Completion Conditions

This task is complete only when:

* Explorer Gallery exists
* players can preview explorers visually
* players can see each explorer’s power
* players can unlock explorers
* players can equip explorers
* equipped explorer is saved
* at least one power works in gameplay
* Coin Magnet works for Treasure Hunter
* explorer unlock requirements are visible
* shop or map links to explorer unlocks
* `CHANGELOG.md` is updated
* `checkpoint.md` is updated
* missing explorer assets are listed clearly

---

# Important Design Rule

Explorers must feel like part of the expedition.

The player should think:

```text
I want to unlock this explorer because they look cool and help me survive the next part of the jungle.
```

Not:

```text
This is just another flat skin list.
```
