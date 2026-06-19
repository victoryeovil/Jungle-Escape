# Agent Prompt — Upgrade Jungle Map Graphics and Source Better Map Assets

## Main Objective

Upgrade the current **Jungle Map / Level Select screen** so it looks like a polished expedition map, not a flat pixel prototype.

The current map has improved structure, but it still looks too simple, blocky, and low-detail. The map must now look like a proper **jungle adventure map** showing the player’s journey from camp into deeper jungle zones, rivers, ruins, temple gates, and the Wildlands of Peace.

The map should feel like:

> “I am following the Lost Path into the jungle.”

Not:

> “I am looking at a basic test screen.”

---

# Current Problems to Fix

The current screen has these issues:

* map background looks too flat and pixel-like
* jungle areas look like blocks instead of natural terrain
* text is too small and crowded in some areas
* landmarks are not visually strong enough
* Level 6 / Wildlands area is cramped at the top
* river looks like a simple rectangle instead of a natural river
* path direction is not clear enough
* the map does not yet feel premium or Play Store-ready
* the map does not strongly show the story of the Temple of the First Sun, Sunstone Heart, and Lost Path

---

# Asset Sources to Use

Use free/commercial-safe assets only.

## Recommended Sources

Search and download suitable assets from:

```text
Quaternius
Kenney
Poly Pizza
OpenGameArt
```

## Priority

Use sources in this order:

```text
1. Quaternius — low-poly jungle/nature/ruins/animals/characters
2. Kenney — UI icons, markers, buttons, simple game assets
3. Poly Pizza — extra trees, animals, props, ruins, stones
4. OpenGameArt — only when the license is clearly verified
```

## Important Licensing Rule

For every downloaded asset, update:

```text
res://ASSET_LICENSES.md
```

Each entry must include:

```md
Asset name:
Source:
Author:
License:
Download link:
Used for:
Notes:
```

Do not use assets with unclear licensing.

---

# Exact Search Queries / Commands for the Agent

Use these search terms when looking for better map and jungle graphics:

```text
Quaternius stylized nature megakit
Quaternius jungle low poly assets
Quaternius trees bushes rocks low poly
Quaternius ruins temple low poly
Quaternius animals low poly
Quaternius universal animation library Godot
Kenney jungle assets
Kenney UI icons game assets
Kenney map icons
Kenney low poly nature
Poly Pizza low poly jungle tree
Poly Pizza low poly palm tree
Poly Pizza low poly elephant
Poly Pizza low poly warthog
Poly Pizza low poly parrot
Poly Pizza low poly monkey
Poly Pizza low poly temple ruins
Poly Pizza low poly bridge
OpenGameArt jungle map
OpenGameArt adventure map UI
OpenGameArt parchment map
OpenGameArt jungle tiles
```

If using a web-capable agent, run searches like:

```text
Search: "Quaternius stylized nature megakit"
Search: "Kenney map icons free game assets"
Search: "Poly Pizza low poly jungle tree"
Search: "Poly Pizza low poly animals elephant warthog parrot"
Search: "OpenGameArt jungle map UI"
```

---

# Required Map Visual Direction

The level select screen must become a **vertical illustrated jungle expedition map**.

## Map Style

The map should be:

* polished
* adventurous
* readable
* mobile portrait-friendly
* stylized
* slightly mysterious
* not childish
* not pixel-blocky
* not plain green
* not overly dark

## Recommended Map Resolution

Create or source a high-quality map background:

```text
720x1280 minimum
1440x2560 preferred if performance allows
PNG format
```

Save as:

```text
res://assets/backgrounds/bg_jungle_map.png
```

---

# Map Layout Description

The map should show a journey from the bottom to the top.

## Bottom Area — Expedition Camp

At the bottom, show:

* small explorer camp
* tent
* campfire
* crates
* map table
* starting flag
* “Camp” label

This is where the player begins.

## Lower Jungle — Level 1 and Level 2

Show:

* bright jungle trail
* trees
* butterflies
* birds
* soft sunlight
* simple path markers

Level nodes:

```text
Level 1 — Jungle Trail
Level 2 — Deep Forest
```

## Middle Area — River of Echoes

Replace the straight blue rectangle with a natural river.

The river should include:

* curved water flow
* bridge crossing
* reeds
* rocks
* water shimmer
* frogs or birds nearby

Level node:

```text
Level 3 — River of Echoes
```

## Upper Middle — Ancient Ruins

Show:

* moss-covered ruins
* broken pillars
* stone arch
* glowing symbols
* vines
* darker jungle shadows

Level nodes:

```text
Level 4 — Ancient Ruins
Level 5 — Temple Approach
```

## Top Area — Temple and Wildlands

The top must not be crowded.

Show two clear zones:

### Temple of the First Sun

* large ancient gate
* golden glow
* sun symbol
* stone stairs
* mysterious energy

### Wildlands of Peace

* sandy path
* warm sunlight
* acacia-style trees
* elephant silhouettes in distance
* warthogs roaming safely
* first land/home marker

Level node:

```text
Level 6 — Wildlands of Peace
```

---

# Winding Lost Path

Add a clear winding trail through the whole map.

The path should:

* begin at the camp
* move through Level 1 and Level 2
* cross the River of Echoes
* pass through the Ancient Ruins
* reach the Temple Approach
* reveal the Wildlands of Peace after Level 5

The path must not be straight.

Use:

* curved trail
* broken bridge
* stone stepping path
* gate transitions
* fogged locked sections
* glowing markers for story levels

---

# Level Markers

Replace plain text/button-style level nodes with real map markers.

## Marker Styles

Use:

* stone markers
* wooden signs
* camp flags
* glowing relic stones
* ancient sun symbols
* treasure markers

## Marker States

Each level marker must support:

```text
current
completed
locked
story level
treasure hunt level
requires upgrade
```

## Examples

### Completed

* golden glow
* visible stars
* clear level number

### Current

* pulsing glow
* brighter marker
* small arrow or flag

### Locked

* fog overlay
* chain/lock icon
* muted color

### Requires Sand Shoes

* small Sand Shoes icon
* sandy path warning

---

# Better Text Layout

Improve readability.

## Rules

* do not place labels on top of each other
* avoid tiny text
* use clear title sizes
* avoid crowding the top section
* show only essential text on the map
* use preview panels for detailed descriptions

## Map Labels

Use short labels:

```text
Camp
Jungle Trail
Deep Forest
River of Echoes
Ancient Ruins
Temple Gate
Wildlands
```

Do not write long story text directly on the map.

---

# Level Preview Panel

When a player taps a node, show a polished preview panel.

Use an explorer notebook or parchment style.

Example:

```text
Level 3 — River of Echoes

The Lost Path reaches a river that guards one of the Sunstone clues.

Rewards:
Coins
Wood
Map Piece
Possible Sunstone Shard

[Start Expedition]
[Back]
```

For Level 6 without Sand Shoes:

```text
Level 6 — Wildlands of Peace

The path ahead is covered in deep sand. Sand Shoes are required to walk, jump, and continue the expedition.

Required:
Sand Shoes

[Buy Sand Shoes]
[Back]
```

---

# Story Integration

The map must clearly reflect the story.

Include visual references to:

* the Lost Path
* the Temple of the First Sun
* the Sunstone Heart
* ancient symbols
* map fragments
* expedition camp
* peaceful wildlife
* sandy Wildlands of Peace
* future home/land marker

The player should see the map and understand that they are on a journey, not selecting random levels.

---

# Wildlife and Animated Map Details

Add subtle animated life to the map.

## Required

At least 3 of these:

```text
birds flying across the jungle
butterflies near camp or flowers
river shimmer
fog moving over locked zones
torch glow near temple
elephant silhouette movement in Wildlands
warthog walking near Wildlands
glowing Sunstone marker
```

Keep animations lightweight.

---

# Better Graphics Implementation Options

Use one of the following approaches:

## Option A — Illustrated 2D Map Background

Create/source a single polished 2D map background image and overlay clickable level markers.

Recommended for speed.

Files:

```text
res://assets/backgrounds/bg_jungle_map.png
res://assets/ui/map_markers/
```

## Option B — Layered 2D Map

Use multiple layers:

```text
background jungle layer
river layer
path layer
landmark layer
fog layer
marker layer
animal animation layer
UI layer
```

Recommended for better polish.

## Option C — 3D Miniature Map

Use a small 3D diorama-style map with camera looking downward.

Only use this if performance and time allow.

For now, Option B is best.

---

# Suggested File Structure

Create:

```text
res://assets/backgrounds/bg_jungle_map.png
res://assets/ui/map/
res://assets/ui/map/markers/
res://assets/ui/map/icons/
res://assets/ui/map/landmarks/
res://assets/ui/map/effects/
```

Example assets:

```text
res://assets/ui/map/markers/marker_completed.png
res://assets/ui/map/markers/marker_current.png
res://assets/ui/map/markers/marker_locked.png
res://assets/ui/map/markers/marker_story.png
res://assets/ui/map/icons/icon_sand_shoes_required.png
res://assets/ui/map/icons/icon_sunstone.png
res://assets/ui/map/icons/icon_treasure.png
res://assets/ui/map/landmarks/landmark_camp.png
res://assets/ui/map/landmarks/landmark_temple_gate.png
res://assets/ui/map/landmarks/landmark_river_bridge.png
```

---

# Missing Assets Tracking

Update or create:

```text
res://MISSING_UI_ASSETS.md
```

Add missing items:

```md
# Missing UI / Map Assets

## Map Background
- High-quality jungle expedition map background

## Map Markers
- Current level marker
- Completed level marker
- Locked level marker
- Story level marker
- Treasure hunt marker
- Sand Shoes required marker

## Map Landmarks
- Expedition camp
- Jungle trail marker
- Deep forest marker
- River bridge
- Ancient ruins
- Temple gate
- Wildlands of Peace
- First land/home marker

## Map Effects
- Fog overlay
- River shimmer
- Glow effect
- Pulsing current marker
- Flying bird animation
- Butterfly animation
- Warthog/elephant ambient movement
```

Only remove items after they are added and tested.

---

# Required Asset Quality

Do not use:

* blurry assets
* mismatched random art
* pixelated low-resolution images
* plain rectangles
* placeholder boxes
* unreadable labels
* assets with unclear license

Use assets that are:

* clean
* readable
* mobile-friendly
* consistent in art style
* adventure-themed
* suitable for Google Play screenshots

---

# Required Files to Update

## Update `CHANGELOG.md`

Append:

```md
## [Unreleased] - Jungle Map Graphics Upgrade

### Added
- Added high-quality jungle expedition map direction.
- Added plan for improved jungle map background.
- Added winding Lost Path map layout.
- Added map landmarks for Camp, River of Echoes, Ancient Ruins, Temple Gate, and Wildlands of Peace.
- Added better map marker requirements for current, completed, locked, story, treasure, and upgrade-required levels.
- Added ambient map life direction including birds, butterflies, river shimmer, fog, and peaceful wildlife.
- Added map asset sourcing plan using free/commercial-safe resources.

### Changed
- Replaced plain map button approach with a visual expedition map direction.
- Improved map readability and story integration.
- Reduced blocky/pixel prototype appearance.

### Notes
- The map must look like a journey through the jungle, not a flat menu.
- All external assets must be recorded in `ASSET_LICENSES.md`.
```

Do not delete earlier changelog entries.

---

## Update `checkpoint.md`

Add/update:

```md
## Current Map Graphics Focus
The map screen is being upgraded from a basic block-style map into a polished jungle expedition map.

## Completed / In Progress
- Better asset sourcing plan requested.
- High-quality jungle map background requested.
- Winding Lost Path layout requested.
- Improved landmarks requested.
- Map marker states requested.
- Wildlife and animated map details requested.

## Still Needed
- Source or generate polished jungle map background.
- Add improved map markers.
- Add readable labels and preview panels.
- Add fog/locked-zone effects.
- Add Sand Shoes marker for Level 6.
- Add ambient map animations.
- Update asset license tracking.

## Next Recommended Step
Create/source the high-quality `bg_jungle_map.png`, then overlay improved interactive level markers.
```

---

# Completion Conditions

This task is complete only when:

* the map no longer looks blocky or pixel-prototype
* a high-quality jungle expedition map background exists
* the Lost Path is clearly visible and winding
* camp, river, ruins, temple, and wildlands zones are visible
* Level 1–6 markers are readable and well-spaced
* locked areas look like unexplored jungle, not disabled buttons
* tapping a marker opens a level preview panel
* Level 6 clearly shows Sand Shoes requirement when locked
* ambient life/effects exist on the map
* all external assets are documented in `ASSET_LICENSES.md`
* `CHANGELOG.md` is updated
* `checkpoint.md` is updated
* `MISSING_UI_ASSETS.md` is updated if assets are still missing

---

# Important Rule

Do not just make the current map darker or add more text.

Rebuild the map visually so it feels like:

```text
an expedition map into the jungle
```

The player should immediately understand:

```text
I started at camp, crossed the river, reached ruins, and I am moving toward the temple and wildlands.
```


# Agent Prompt — Add Level 5 Upgrade Gate, Sand Shoes, Wildlife Story, Treasure Hunt Collections, and First Land/Home System

## Main Objective

Add a stronger progression system after **Level 5** so the game becomes more than running through levels.

After completing Level 5, the player must unlock a new journey phase where they learn about peaceful coexistence with wildlife, prepare for sandy terrain, buy **Sand Shoes**, and begin collecting materials to eventually buy land and build their own jungle home/base.

This should make the game feel like a journey, not just random levels.

---

# New Progression Moment After Level 5

## Trigger

After the player completes **Level 5 — Temple Approach**, show a story transition screen before Level 6 unlocks.

## Required Story Message

Use this story direction:

```text
The jungle opens into a warmer land of sand paths, open plains, and peaceful wildlife.

Did you know people and animals can live side by side in peace? In places like Victoria Falls, Zimbabwe, elephants can be seen moving freely near town areas, and visitors may relax in parks where wild warthogs roam nearby.

The next part of your expedition is about learning respect for nature, sharing space with wildlife, and preparing for new terrain.

To continue, you need Sand Shoes. These will help your explorer walk safely on sand, keep balance, and jump across sandy gaps.

Prepare to buy your first piece of land, build your own jungle home, and begin the treasure hunt for materials.
```

## Tone

The message must feel:

* educational
* adventurous
* respectful toward wildlife
* inspiring
* connected to Zimbabwe / African natural beauty
* not childish
* not too long on screen

---

# Important Wildlife Message

The game should promote peaceful coexistence with animals.

Add messaging that teaches:

* do not harm wild animals
* do not chase animals
* do not feed wild animals
* keep safe distance
* respect natural habitats
* humans and animals can share space responsibly

Use short tips during loading screens, for example:

```text
Wildlife Tip: Respect animals from a safe distance.
```

```text
Wildlife Tip: The jungle is home to many creatures. Move with care.
```

```text
Wildlife Tip: Peace with nature begins with respect.
```

---

# Sand Shoes Upgrade System

## New Item

Add a new upgrade item:

```text
Sand Shoes
```

## Purpose

Sand Shoes allow the player to:

* walk properly on sand terrain
* avoid slowing down on sand
* jump across sandy gaps
* access Level 6 and later sand-based areas

## Unlock Timing

Sand Shoes become available after completing Level 5.

## Gate Rule

The player cannot start Level 6 unless they own Sand Shoes.

If the player tries to start Level 6 without Sand Shoes, show:

```text
Sand Shoes Required

The path ahead is covered in deep sand. Buy Sand Shoes to walk, jump, and continue the expedition.
```

Buttons:

```text
Buy Sand Shoes
Back to Level Select
```

---

# Suggested Sand Shoes Cost

Use in-game currency and resources, not real-money blocking.

Recommended cost:

```text
100 coins
2 food packs
1 relic strap
```

If `food packs` or `relic strap` do not exist yet, add them as new collectible/resource types.

Important: the player should be able to earn enough resources through Levels 1–5. Do not make the upgrade impossible.

---

# Build Function Logic

Implement a clean progression function to check whether the player can access a level.

## Required Function

Create a function similar to:

```gdscript
func can_start_level(level_id: int) -> bool:
	if level_id >= 6 and not player_inventory.has_item("sand_shoes"):
		show_upgrade_required_popup("sand_shoes")
		return false
	
	return true
```

## Required Upgrade Purchase Function

```gdscript
func buy_sand_shoes() -> bool:
	var cost = {
		"coins": 100,
		"food": 2,
		"relic_strap": 1
	}

	if not player_inventory.has_resources(cost):
		show_message("Not enough resources to buy Sand Shoes.")
		return false

	player_inventory.spend_resources(cost)
	player_inventory.add_item("sand_shoes")
	save_progress()
	show_message("Sand Shoes unlocked! You can now cross sandy paths.")
	return true
```

## Required Terrain Check

Sand terrain must behave differently depending on whether the player owns Sand Shoes.

```gdscript
func apply_terrain_effect(terrain_type: String) -> void:
	if terrain_type == "sand":
		if player_inventory.has_item("sand_shoes"):
			player.set_speed_modifier(1.0)
			player.set_can_jump(true)
		else:
			player.set_speed_modifier(0.45)
			player.set_can_jump(false)
```

## Completion Rule

The player must not be permanently stuck. If they lack resources, provide a way to replay earlier levels and collect what they need.

---

# Level 6 New Theme

## Level 6 — Sand Path of Peace

Level 6 begins the next chapter.

Environment should include:

* sandy jungle edge
* dry grass
* warm sunlight
* open walking areas
* peaceful wildlife nearby
* elephant silhouettes in distance
* warthogs or small animals roaming safely in park-like spaces
* scattered treasure materials
* wider path sections
* sandy jump gaps

Important: animals should be peaceful unless used later as hazards. In this chapter, they should mostly teach coexistence.

---

# New Story Chapter

Add a new chapter after Level 5:

## Chapter 2 — Wildlands of Peace

Story:

```text
Beyond the temple gate lies a sandy wildland where animals and people share the same world.

Kairo and Zuri learn that the greatest treasure is not only gold or relics, but the ability to live in balance with nature.

To continue the expedition, they must gather materials, help restore the old explorer camp, and prepare to build their first jungle home.
```

This chapter introduces:

* Sand Shoes
* peaceful wildlife
* treasure hunt materials
* land buying
* home/base building
* new collection items

---

# New Collection System

The game must now include more collectibles than just coins.

## Required Collectibles

Add these resources:

```text
coins
gems
bricks
tiles
windows
wood
food
tools
relic_keys
sunstone_shards
map_pieces
```

## Purpose of Each Collectible

### Coins

Used for normal purchases, hints, skins, and basic upgrades.

### Gems

Rare premium in-game reward for special unlocks.

### Bricks

Used to build the player’s jungle house/base.

### Tiles

Used for roofing/flooring upgrades in the house.

### Windows

Used for house construction and upgrades.

### Wood

Used for bridges, fences, house parts, and camp upgrades.

### Food

Used for expedition supplies and camp storage.
Do not use food to encourage feeding wild animals.

### Tools

Used for building and repairing camp structures.

### Relic Keys

Used to open ancient gates.

### Sunstone Shards

Main story collectible tied to restoring the Sunstone Heart.

### Map Pieces

Used to unlock new areas and chapters.

---

# Treasure Hunt System

After Level 5, introduce a **Treasure Hunt** mode or treasure hunt segments inside levels.

## Story Setup

```text
The lost path has revealed hidden supplies left behind by earlier explorers. Collect materials to build your first home and prepare for deeper expeditions.
```

## Treasure Hunt Items

Players should collect:

* bricks
* tiles
* windows
* wood
* food crates
* tools
* coins
* gems
* relic keys
* sunstone shards

## Placement Rules

* Coins can appear frequently.
* Bricks and wood appear moderately.
* Windows and tools are rarer.
* Sunstone Shards are story-critical and rare.
* Map Pieces unlock new areas.

---

# First Land and House System

## New Feature

After completing Level 5, introduce the idea that the player can eventually buy their first land and build a home/base.

## Required Story Message

```text
A peaceful clearing appears beyond the sandy path. Zuri believes it could become a safe expedition camp.

Collect building materials, buy your first land, and build a home where your journey can grow.
```

## First Land Unlock

Create a new locked feature:

```text
First Land / Jungle Home
```

## Suggested Unlock Requirement

```text
250 coins
20 bricks
10 wood
5 tiles
2 windows
3 food packs
```

## Purpose of the Home

The home/base can later be used for:

* storing collections
* viewing achievements
* upgrading characters
* unlocking animal friendship badges
* displaying relics
* preparing for expeditions
* daily rewards
* future social visits

---

# House Building Stages

The home should be built gradually.

## Stage 1 — Buy Land

Requires coins and map piece.

## Stage 2 — Build Foundation

Requires bricks and tools.

## Stage 3 — Build Walls

Requires bricks and wood.

## Stage 4 — Add Roof and Tiles

Requires tiles and wood.

## Stage 5 — Add Windows

Requires windows.

## Stage 6 — Complete Expedition Home

Unlocks daily rewards and collection display.

---

# UI Requirements

Update the HUD and inventory systems to support multiple collectible types.

## Required Screens / UI Areas

Add or update:

```text
Inventory screen
Collections screen
Upgrade shop
Land/Home screen
Treasure Hunt reward screen
Sand Shoes purchase popup
```

## HUD

Do not overcrowd the gameplay HUD with every resource.

HUD should show:

* coins
* current special collectible
* level progress
* pause

After level completion, show all collected items.

Example reward summary:

```text
Level Complete

Coins: +24
Bricks: +3
Wood: +2
Food: +1
Sunstone Shards: +1
```

---

# Shop / Upgrade Requirement

Add Sand Shoes to the upgrade shop.

## Sand Shoes Card

Display:

```text
Sand Shoes
Walk safely on sand and jump across sandy gaps.
Required for Level 6.
Cost: 100 coins + 2 food + 1 relic strap
```

States:

```text
Locked until Level 5 complete
Available
Owned
```

---

# Animal Coexistence System

Add peaceful animal encounters.

## Required Animal Behavior

Animals should mostly be environmental and peaceful.

Examples:

* elephants walk calmly in the far background
* warthogs roam near park/grass areas
* birds fly overhead
* monkeys sit on trees
* butterflies move near flowers

Do not make all animals enemies. The game should teach that animals are part of the world, not just obstacles.

## Animal Discovery Badges

Optional but recommended:

```text
Elephant Sighting
Warthog Watcher
Butterfly Trail
Parrot Flight
Monkey Grove
```

These can reward exploration and observation.

---

# Story Text After Buying Sand Shoes

After the player buys Sand Shoes, show:

```text
Sand Shoes unlocked!

The sandy path is now open. Kairo and Zuri step into the Wildlands of Peace, where treasure is found not only in ruins, but in learning how to live with nature.
```

---

# Story Text Before Treasure Hunt

Before the first treasure hunt level, show:

```text
The old map points to hidden supplies buried along the trail.

Collect bricks, tiles, windows, wood, food, and tools. These will help you buy land and build your first expedition home.
```

---

# Level Completion Text After Level 6

```text
You crossed the sandy path and found the first building supplies.

The dream of a jungle home has begun.
```

---

# Required Files to Update

## Update `CHANGELOG.md`

Append this entry:

```md
## [Unreleased] - Sand Shoes, Wildlife Coexistence, and Treasure Collection Update

### Added
- Added Sand Shoes upgrade required after Level 5.
- Added Level 6 access gate requiring Sand Shoes.
- Added sand terrain behavior for walking and jumping.
- Added wildlife coexistence story inspired by peaceful human-wildlife spaces.
- Added new collection resources: bricks, tiles, windows, wood, food, tools, relic keys, sunstone shards, and map pieces.
- Added treasure hunt progression after Level 5.
- Added first land and jungle home/base concept.
- Added peaceful animal ambience direction including elephants, warthogs, birds, butterflies, monkeys, and frogs.
- Added upgrade purchase logic for Sand Shoes.

### Changed
- Expanded progression beyond coins and levels.
- Shifted post-Level 5 gameplay toward exploration, collection, land ownership, and base building.
- Improved story connection between wildlife, nature respect, and treasure hunting.

### Notes
- Sand Shoes must be purchasable through in-game resources.
- The player must be able to replay earlier levels to collect missing resources.
- Wildlife must be represented respectfully and should not all be treated as enemies.
```

---

## Update `checkpoint.md`

Add or update this section:

```md
## Current Progression Focus
The game now introduces a major post-Level 5 progression milestone: Sand Shoes, sandy terrain, peaceful wildlife, treasure collection, and first land/home building.

## Completed / In Progress
- Sand Shoes upgrade system requested.
- Level 6 gate condition requested.
- Sand terrain behavior requested.
- Wildlife coexistence story requested.
- Multi-resource collection system requested.
- Treasure hunt system requested.
- First land and home/base building system requested.

## Still Needed
- Implement Sand Shoes inventory item.
- Implement upgrade shop purchase logic.
- Add sand terrain detection.
- Add Level 6 sandy wildlands environment.
- Add new collectible models/icons.
- Add inventory and collection screens.
- Add land purchase screen.
- Add house building stages.
- Add peaceful animal ambience.

## Next Recommended Step
Implement Sand Shoes and Level 6 gating first, then add the new collectible resource system, then build the first land/home feature.
```

---

# Required Missing Assets Update

Update or create:

```text
res://MISSING_3D_ASSETS.md
```

Add missing assets such as:

```md
## Upgrade Items
- Sand Shoes 3D model
- Sand Shoes UI icon

## New Collectibles
- Brick collectible
- Tile collectible
- Window collectible
- Wood collectible
- Food crate collectible
- Tool collectible
- Relic key collectible
- Sunstone shard collectible
- Map piece collectible

## Wildlife
- Elephant background model/animation
- Warthog model/animation
- Bird/parrot model/animation
- Butterfly model/animation
- Monkey model/animation
- Frog model/animation

## Land/Home Building
- Land plot model
- Foundation model
- Wall model
- Roof tile model
- Window model
- Completed jungle home model
```

---

# Completion Conditions

This feature is complete only when:

* completing Level 5 triggers the new story transition
* Sand Shoes become available after Level 5
* Level 6 cannot start without Sand Shoes
* the player can buy Sand Shoes using in-game resources
* sand terrain behavior changes when Sand Shoes are owned
* Level 6 introduces sandy wildlands
* wildlife coexistence messaging appears
* new collectibles exist in the game system
* treasure hunt rewards include more than coins
* land/home feature is introduced as a locked or early system
* `CHANGELOG.md` is updated
* `checkpoint.md` is updated
* `MISSING_3D_ASSETS.md` is updated

---

# Important Design Rule

This feature must not feel like a paywall.

It must feel like natural story progression:

```text
You completed the first chapter.
You discovered a new environment.
You need new gear.
You collect resources.
You prepare for a bigger adventure.
```

The player should feel excited to continue, not blocked unfairly.

update the tasks.md first