# 3D Jungle World Creation Instructions — Jungle Escape: Lost Path

## Objective

Create a believable, attractive, mobile-friendly **3D jungle environment** for **Jungle Escape: Lost Path**.

The jungle must feel alive, adventurous, and playable. It must not look like a flat green field, empty scene, or random objects placed on a plane.

The player should feel like they are running through an actual jungle path with trees, grass, animals, rivers, ruins, obstacles, and atmosphere.

---

# Core Jungle Style

## Visual Direction

Use a **stylized low-poly 3D jungle style**.

The jungle should be:

* colorful but not childish
* polished but lightweight
* adventurous
* readable on mobile
* full of life
* optimized for Android
* suitable for a 3D runner/adventure game

Avoid:

* empty green planes
* plain cubes
* random scattered trees
* overly realistic heavy models
* toy-like childish assets
* very dark visuals that hide gameplay
* too many objects that reduce performance

---

# Main Jungle Structure

The world should be built around a **clear running path**.

## Required Layout

The player must run along a visible jungle trail.

The path should include:

* dirt road / jungle trail
* grass beside the path
* trees and bushes around the sides
* rocks and logs as obstacles
* coins placed along the path
* animals and birds as ambient life
* finish gate or temple gate at the end

The player should never look like they are running across an empty flat surface.

---

# Recommended Scene Structure in Godot

Create or update the main 3D scene:

```text
res://scenes/Game3D.tscn
```

Recommended node structure:

```text
Game3D
├── WorldEnvironment
├── DirectionalLight3D
├── CameraRig
│   └── Camera3D
├── Player
├── LevelRoot
│   ├── Terrain
│   ├── JunglePath
│   ├── Trees
│   ├── GrassAndPlants
│   ├── RocksAndLogs
│   ├── Ruins
│   ├── RiverSections
│   ├── Collectibles
│   ├── Obstacles
│   ├── Animals
│   └── FinishGate
├── Audio
└── HUD
```

---

# Terrain and Ground

## Jungle Ground

Create a ground plane or modular ground pieces with:

* jungle soil
* patches of grass
* subtle color variation
* path edges
* soft terrain details

Do not use one plain green material for the whole world.

## Path

The path must be the central visual guide.

Use:

* dirt path texture
* slightly raised or carved trail
* curves where possible
* edges with grass, roots, stones, and leaves

For runner gameplay, create a path with **3 lanes**:

```text
Left Lane | Center Lane | Right Lane
```

The lanes should not be visibly marked like road lines. They should be naturally implied by the path width.

---

# Jungle Vegetation

## Trees

Add different tree types:

* palm trees
* broad jungle trees
* short trees
* tall canopy trees
* dead/fallen trees

Trees should mostly be placed outside the playable path.

## Plants

Add:

* ferns
* bushes
* tall grass
* vines
* mushrooms
* large leaves
* small flowers

Use these to make the jungle feel alive, but keep the running path clear.

## Placement Rules

Vegetation must be layered:

* small grass near the path
* bushes slightly farther out
* trees on the outer edges
* large background trees behind everything

This creates depth.

Do not place all plants randomly. Use clusters.

---

# Jungle Atmosphere

Add atmosphere to make the world feel premium.

## Required

* soft directional sunlight
* slight green jungle fog
* shadows under trees
* darker background depth
* lighter playable path
* ambient jungle sound

## Optional Polish

* slow-moving leaves
* floating dust or pollen particles
* fireflies in darker ruin areas
* water shimmer near rivers
* birds flying in background

---

# Animals and Wildlife

Animals should make the jungle feel alive.

They do not all need to affect gameplay. Most can be decorative.

## Animal Categories

### 1. Ambient Animals

These animals are for atmosphere only.

Examples:

* parrots
* small birds
* butterflies
* monkeys
* frogs
* fireflies

They should not block the player.

### 2. Gameplay Hazard Animals

These can affect gameplay.

Examples:

* snake on path
* crocodile near river
* wild boar crossing path

These should be used carefully and clearly.

### 3. Background Animals

These appear in the distance.

Examples:

* birds flying overhead
* monkeys moving on trees
* butterflies near bushes

---

# Animal Behavior Requirements

## Parrots / Birds

Use birds as ambient life.

Behavior:

* fly from one tree to another
* occasionally cross above the path
* do not collide with player
* use simple looping animation
* use low-poly models

Suggested node setup:

```text
Bird
├── MeshInstance3D
├── AnimationPlayer
└── PathFollow3D
```

## Monkeys

Monkeys should appear on trees or ruins.

Behavior:

* sit on branches
* jump lightly between fixed points
* wave or look around
* decorative only for MVP

Do not make monkeys attack the player in the first version.

## Butterflies

Butterflies should appear near bushes and flowers.

Behavior:

* small hovering movement
* slow looping path
* no collision
* add color and life to the scene

## Frogs

Frogs can appear near rivers or mud patches.

Behavior:

* idle near water
* occasional small hop
* decorative only

## Snakes

Snakes can be gameplay hazards.

Behavior options:

* snake stays on one lane and forces player to dodge
* snake slowly crosses the path
* snake appears near ruins or grass
* collision causes stumble/game over

Snake must be clearly visible and not hidden in grass.

## Crocodiles

Use crocodiles only in river levels.

Behavior:

* placed near river edges
* can open mouth or move slightly
* may be obstacle near broken bridge
* should not be overused

## Wild Boar

Optional for later levels.

Behavior:

* runs across path from side to side
* player must jump, dodge, or wait
* use only after Level 3 or higher

---

# Level-by-Level Jungle Setup

## Level 1 — Jungle Trail Entrance

Goal: Introduce the player.

Environment:

* bright jungle entrance
* clear dirt path
* simple trees and grass
* a few rocks
* fallen logs as first obstacles
* coins in a straight line
* birds and butterflies as decoration

Animals:

* butterflies near flowers
* birds flying in background
* no dangerous animals yet

Gameplay:

* simple running
* easy coin collection
* one or two logs to jump over
* finish gate visible at end

---

## Level 2 — Deep Forest Path

Goal: Make the jungle feel denser. Introduce the first path turn.

Environment:

* taller trees
* thicker bushes
* vines hanging from trees
* darker green atmosphere
* path bends LEFT at row 20 (first turn in the game)
* more obstacles

Animals:

* monkeys in trees
* birds flying across
* butterflies near bushes

Gameplay:

* more coins
* rocks and logs
* first side-dodge obstacle
* **PATH TURN LEFT at row 20** — two glowing yellow floor arrows warn the player; "◀ TURN LEFT" HUD prompt appears; any swipe executes the left turn; log-jam dam blocks straight path
* slightly longer path

---

## Level 3 — River Crossing

Goal: Introduce water, bridges, and the first RIGHT-direction turn.

Environment:

* jungle river
* wooden bridges
* wet mud patches
* river stones
* reeds and water plants
* path bends RIGHT at row 18

Animals:

* frogs near water
* birds near river
* optional crocodile near river edge

Gameplay:

* **PATH TURN RIGHT at row 18** — "TURN RIGHT ▶" HUD prompt; any swipe executes the right turn; log-jam dam blocks straight path
* broken bridge section after the turn
* jump over gaps
* avoid mud patches
* collect coin trail over bridge

---

## Level 4 — Ancient Ruins

Goal: Add adventure and mystery. Second left-turn corner.

Environment:

* mossy stone ruins
* broken pillars
* stone walls
* vines over ruins
* glowing relics
* temple path bending LEFT at row 22

Animals:

* snakes near ruin edges
* bats or birds in background
* monkeys sitting on ruins

Gameplay:

* **PATH TURN LEFT at row 22** — "◀ TURN LEFT" HUD prompt; any swipe executes the left turn
* spike traps
* tighter lanes
* hidden coin clusters
* snake obstacle introduced

---

## Level 5 — Temple Approach

Goal: Make the player feel close to treasure. Final right-turn corner before the temple gate.

Environment:

* temple gate
* torches
* statues
* stone stairs
* jungle overgrowth
* stronger lighting and atmosphere
* path bends RIGHT at row 25

Animals:

* birds flying overhead
* snakes near temple stones
* optional boar crossing path

Gameplay:

* **PATH TURN RIGHT at row 25** — "TURN RIGHT ▶" HUD prompt; any swipe executes the right turn
* harder obstacle pattern on the post-turn stretch
* moving obstacle
* richer coin rewards
* glowing finish gate

---

# Obstacle Integration

Jungle obstacles must look natural.

Use:

* fallen logs
* rocks
* thorn bushes
* mud patches
* broken bridge gaps
* spike traps
* snakes
* rolling boulders
* low branches for slide action

Each obstacle must clearly communicate what the player should do:

```text
Log = jump
Low branch = slide
Rock = dodge
Snake = dodge
Mud = avoid
Gap = jump
```

---

# Collectible Placement

Coins should guide the player.

Use coins to:

* show the best path
* lead players into jumps
* reward risk
* guide lane switching
* encourage replay

Coins should rotate or glow slightly.

Do not randomly scatter coins without purpose.

---

# Finish Gate

Every level must end with a clear destination.

Use:

* jungle temple gate
* ancient stone arch
* glowing portal
* treasure entrance

The finish must feel rewarding.

Add:

* light glow
* small particle effect
* victory sound
* character celebration animation

---

# Asset Sources

Use free/commercial-safe assets only.

Recommended sources:

* Quaternius for low-poly nature, characters, and animations
* Kenney for additional game assets
* Poly Pizza for extra low-poly animals and props
* OpenGameArt only when license is clearly checked

Create this file:

```text
res://ASSET_LICENSES.md
```

List each asset source and license.

Do not use assets with unclear licensing.

---

# Performance Rules for Mobile

This game is for Android, so optimize the jungle.

## Required

* use low-poly assets
* limit heavy textures
* reuse tree and rock models
* avoid too many unique materials
* use simple collisions
* use invisible collision boxes where possible
* keep animals simple
* avoid complex physics
* avoid excessive particles

## Good Practice

Use repeated objects:

```text
same tree model, different scale/rotation
same grass clump, reused often
same rock model, reused in clusters
```

This makes the world look full without becoming heavy.

---

# Minimum Jungle Completion Conditions

This task is complete only when:

* the player runs through a proper 3D jungle path
* the environment has trees, grass, bushes, rocks, and logs
* at least 3 types of vegetation are visible
* at least 2 ambient animals are visible
* at least 1 animal hazard exists by Level 4
* coins are placed along the route
* obstacles look like real jungle objects
* the finish gate exists
* the scene does not look empty
* the scene does not look like a flat green field
* the jungle supports mobile performance
* the level looks good enough for a Play Store screenshot

---

# First Build Priority

Build the jungle in this order:

1. Create the dirt running path.
2. Add grass and ground variation.
3. Add trees around the path.
4. Add bushes, ferns, vines, and rocks.
5. Add coins along the path.
6. Add basic obstacles: logs and rocks.
7. Add ambient animals: birds and butterflies.
8. Add river/bridge for Level 3.
9. Add snakes for Level 4.
10. Add temple gate finish area.

Do not start with complex animals before the basic jungle path looks good.

---

# Important Quality Rule

The jungle must sell the game visually.

The player should see the screen and immediately feel:

“This looks like an adventure.”

Not:

“This is an empty test scene.”
