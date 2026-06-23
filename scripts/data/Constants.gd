extends Node

# ── Tile types ─────────────────────────────────────────────────────────────────
const TILE_WALL    := "W"
const TILE_FLOOR   := "."
const TILE_PLAYER  := "P"
const TILE_COIN    := "C"
const TILE_GEM     := "M"
const TILE_KEY     := "K"
const TILE_GATE    := "G"
const TILE_EXIT    := "E"
const TILE_SPIKE   := "S"
const TILE_SNAKE   := "N"
const TILE_RIVER   := "R"
const TILE_BRIDGE  := "B"
const TILE_MUD     := "U"
const TILE_SWITCH  := "X"
const TILE_ROCK    := "O"
const TILE_VINE    := "V"
const TILE_FRUIT   := "F"
const TILE_CHEST   := "T"

# ── Tile pixel size ────────────────────────────────────────────────────────────
const TILE_SIZE := 64

# ── Worlds ─────────────────────────────────────────────────────────────────────
# level_start/level_end are inclusive; use a helper to get the range at runtime.
const WORLDS := [
	{ "id": 1, "name": "Jungle Path",   "level_start": 1,  "level_end": 10, "unlock_at": 0  },
	{ "id": 2, "name": "Hidden Gates",  "level_start": 11, "level_end": 20, "unlock_at": 10 },
	{ "id": 3, "name": "Snake Temple",  "level_start": 21, "level_end": 30, "unlock_at": 20 },
	{ "id": 4, "name": "River Ruins",   "level_start": 31, "level_end": 40, "unlock_at": 30 },
	{ "id": 5, "name": "Lost Cave",     "level_start": 41, "level_end": 50, "unlock_at": 40 },
]

static func world_levels(world: Dictionary) -> Array:
	var result: Array = []
	for i in range(world["level_start"], world["level_end"] + 1):
		result.append(i)
	return result

# ── Skins ──────────────────────────────────────────────────────────────────────
const SKINS := [
	{
		"id": "explorer", "name": "Kairo",
		"preview_path": "res://assets/3d/characters/kairo/kairo_source_preview.jpg",
		"scene_path": "res://assets/3d/characters/kairo/Kairo.tscn",
		"cost_coins": 0, "cost_gems": 0, "unlock_method": "default", "available_after_level": 0,
		"stats": {"speed": 3, "agility": 3},
		"special": "Balanced — holds his own on any route",
		"lore": "A seasoned explorer, Kairo has charted dozens of lost jungle trails.",
		"color_variants": [
			{"id": "default", "name": "Classic",     "modulate": Color(1.00, 1.00, 1.00)},
			{"id": "sand",    "name": "Desert Sand",  "modulate": Color(1.00, 0.88, 0.68)},
			{"id": "night",   "name": "Night Run",    "modulate": Color(0.62, 0.68, 1.00)},
		],
	},
	{
		"id": "jungle_girl", "name": "Zuri",
		"preview_path": "res://assets/3d/characters/zuri/zuri_source_preview.jpg",
		"scene_path": "res://assets/3d/characters/zuri/Zuri.tscn",
		"cost_coins": 0, "cost_gems": 0, "unlock_method": "default", "available_after_level": 0,
		"stats": {"speed": 4, "agility": 4},
		"special": "Nimble — slides execute faster",
		"lore": "Zuri grew up in the jungle canopy — no path is too wild for her.",
		"color_variants": [
			{"id": "default", "name": "Classic",   "modulate": Color(1.00, 1.00, 1.00)},
			{"id": "sunset",  "name": "Sunset",    "modulate": Color(1.00, 0.82, 0.62)},
			{"id": "storm",   "name": "Stormborn", "modulate": Color(0.72, 0.80, 0.90)},
		],
	},
	{
		"id": "monkey", "name": "Monkey",
		"preview_path": "res://assets/3d/characters/monkey/monkey_source_preview.png",
		"scene_path": "res://assets/3d/characters/monkey/Monkey.tscn",
		"cost_coins": 300, "cost_gems": 0, "unlock_method": "coins", "available_after_level": 3,
		"stats": {"speed": 5, "agility": 5},
		"special": "Climber — jumps carry further",
		"lore": "Quick and restless, the Jungle Monkey never misses a vine.",
		"color_variants": [
			{"id": "default", "name": "Classic",  "modulate": Color(1.00, 1.00, 1.00)},
			{"id": "golden",  "name": "Gold Fur", "modulate": Color(1.08, 0.88, 0.46)},
			{"id": "shadow",  "name": "Shadow",   "modulate": Color(0.48, 0.38, 0.55)},
		],
	},
	{
		"id": "robot", "name": "Robot Explorer",
		"preview_path": "res://assets/3d/characters/robot/robot_source_preview.png",
		"scene_path": "res://assets/3d/characters/robot/RobotExplorer.tscn",
		"cost_coins": 0, "cost_gems": 5, "unlock_method": "gems", "available_after_level": 5,
		"stats": {"speed": 2, "agility": 2},
		"special": "Shielded — survives one obstacle hit",
		"lore": "Built to endure harsh terrain — the Robot Explorer never gives up.",
		"color_variants": [
			{"id": "default", "name": "Steel",   "modulate": Color(1.00, 1.00, 1.00)},
			{"id": "combat",  "name": "Combat",  "modulate": Color(0.92, 0.46, 0.44)},
			{"id": "arctic",  "name": "Arctic",  "modulate": Color(0.72, 0.88, 1.00)},
		],
	},
	{
		"id": "treasure", "name": "Treasure Hunter",
		"preview_path": "res://assets/3d/characters/treasure/treasure_source_preview.png",
		"scene_path": "res://assets/3d/characters/treasure/TreasureHunter.tscn",
		"cost_coins": 500, "cost_gems": 0, "unlock_method": "coins", "available_after_level": 8,
		"stats": {"speed": 3, "agility": 3},
		"special": "Magnet — pulls nearby coins in",
		"lore": "Coin by coin, the Treasure Hunter has never left empty-handed.",
		"color_variants": [
			{"id": "default", "name": "Classic",     "modulate": Color(1.00, 1.00, 1.00)},
			{"id": "desert",  "name": "Desert Gold", "modulate": Color(1.00, 0.86, 0.58)},
			{"id": "camo",    "name": "Jungle Camo", "modulate": Color(0.60, 0.82, 0.56)},
		],
	},
	{
		"id": "tribal", "name": "Tribal Adventurer",
		"preview_path": "res://assets/3d/characters/tribal/tribal_source_preview.png",
		"scene_path": "res://assets/3d/characters/tribal/TribalAdventurer.tscn",
		"cost_coins": 0, "cost_gems": 8, "unlock_method": "gems", "available_after_level": 10,
		"stats": {"speed": 4, "agility": 3},
		"special": "Tracker — reveals alternate paths",
		"lore": "A guardian of the ancient paths, the Tribal Adventurer runs with the jungle.",
		"color_variants": [
			{"id": "default", "name": "Classic",  "modulate": Color(1.00, 1.00, 1.00)},
			{"id": "flame",   "name": "Flame",    "modulate": Color(1.00, 0.70, 0.38)},
			{"id": "spirit",  "name": "Spirit",   "modulate": Color(0.72, 0.60, 0.92)},
		],
	},
	{
		"id": "golden", "name": "Golden Explorer",
		"preview_path": "res://assets/3d/characters/golden/golden_source_preview.png",
		"scene_path": "res://assets/3d/characters/golden/GoldenExplorer.tscn",
		"cost_coins": 0, "cost_gems": 0, "unlock_method": "stars", "unlock_stars": 60, "available_after_level": 20,
		"stats": {"speed": 4, "agility": 4},
		"special": "Lucky — earns bonus coins each run",
		"lore": "Forged by fortune — every step the Golden Explorer takes leaves a trail.",
		"color_variants": [
			{"id": "default", "name": "Gold",    "modulate": Color(1.00, 1.00, 1.00)},
			{"id": "diamond", "name": "Diamond", "modulate": Color(0.76, 0.90, 1.05)},
			{"id": "ruby",    "name": "Ruby",    "modulate": Color(1.00, 0.54, 0.54)},
		],
	},
]

static func get_skin(skin_id: String) -> Dictionary:
	for skin: Dictionary in SKINS:
		if str(skin.get("id", "")) == skin_id:
			return skin
	return {}

static func get_skin_variant(skin_id: String, variant_id: String) -> Dictionary:
	var skin := get_skin(skin_id)
	for v: Dictionary in skin.get("color_variants", []):
		if str(v.get("id", "")) == variant_id:
			return v
	var variants: Array = skin.get("color_variants", [])
	return variants[0] if not variants.is_empty() else {}

# ── Trails ─────────────────────────────────────────────────────────────────────
const TRAILS := [
	{ "id": "none",      "name": "No Trail",       "cost_coins": 0,   "cost_gems": 0 },
	{ "id": "leaf",      "name": "Leaf Trail",     "cost_coins": 150, "cost_gems": 0 },
	{ "id": "firefly",   "name": "Firefly Trail",  "cost_coins": 0,   "cost_gems": 3 },
	{ "id": "dust",      "name": "Dust Trail",     "cost_coins": 100, "cost_gems": 0 },
	{ "id": "splash",    "name": "Water Splash",   "cost_coins": 200, "cost_gems": 0 },
	{ "id": "sparkle",   "name": "Golden Sparkle", "cost_coins": 0,   "cost_gems": 10 },
]

# ── Economy ────────────────────────────────────────────────────────────────────
const COINS_PER_STAR   := 10
const COINS_PER_LEVEL  := 20
const HINT_COIN_COST   := 30
const STARTING_HINTS   := 3

# ── Teaser messages ────────────────────────────────────────────────────────────
const TEASER_MESSAGES := [
	"Complete Level 10 to unlock the River Ruins.",
	"Log in to challenge friends in the Snake Temple.",
	"Invite 1 friend to unlock a bonus challenge.",
	"Complete all World 1 levels with 3 stars to unlock Golden Explorer.",
]

# ── Resources (collectibles beyond coins/gems) ──────────────────────────────
const RESOURCES: Array = [
	{ "id": "bricks",          "name": "Bricks",          "icon": "🧱" },
	{ "id": "wood",            "name": "Wood",             "icon": "🪵" },
	{ "id": "tiles",           "name": "Tiles",            "icon": "🔲" },
	{ "id": "windows",         "name": "Windows",          "icon": "🪟" },
	{ "id": "food",            "name": "Food",             "icon": "🥫" },
	{ "id": "tools",           "name": "Tools",            "icon": "🔧" },
	{ "id": "relic_keys",      "name": "Relic Keys",       "icon": "🗝" },
	{ "id": "sunstone_shards", "name": "Sunstone Shards",  "icon": "✦" },
	{ "id": "map_pieces",      "name": "Map Pieces",       "icon": "🗺" },
	{ "id": "water_token",     "name": "Water Tokens",     "icon": "~" },
	{ "id": "fish_token",      "name": "Fish Tokens",      "icon": "><>" },
	{ "id": "river_relic",     "name": "River Relics",     "icon": "R" },
	{ "id": "animal_badge",    "name": "Animal Badges",    "icon": "*" },
	{ "id": "trade_token",     "name": "Trade Tokens",     "icon": "o" },
]

# ── Upgrades ────────────────────────────────────────────────────────────────
const UPGRADES: Array = [
	{
		"id": "sand_shoes",
		"name": "Sand Shoes",
		"desc": "Walk safely on sand and jump across sandy gaps. Required for Level 6.",
		"unlock_after_level": 5,
		"cost": { "coins": 150 },
		"icon": "👟",
	},
]

# ── Land / home building stages ─────────────────────────────────────────────
const HOME_STAGES: Array = [
	{ "stage": 1, "name": "Buy Land",     "cost": { "coins": 250, "map_pieces": 1 } },
	{ "stage": 2, "name": "Foundation",   "cost": { "bricks": 20, "tools": 3 } },
	{ "stage": 3, "name": "Walls",        "cost": { "bricks": 30, "wood": 10 } },
	{ "stage": 4, "name": "Roof & Tiles", "cost": { "tiles": 5,   "wood": 5 } },
	{ "stage": 5, "name": "Windows",      "cost": { "windows": 2 } },
	{ "stage": 6, "name": "Complete Home","cost": { "tools": 2,   "wood": 5 } },
]

# ── Wildlife tips (shown during loads) ─────────────────────────────────────
const WILDLIFE_TIPS: Array[String] = [
	"Wildlife Tip: Respect animals from a safe distance.",
	"Wildlife Tip: The jungle is home to many creatures. Move with care.",
	"Wildlife Tip: Peace with nature begins with respect.",
	"Wildlife Tip: Do not chase or disturb wild animals.",
	"Wildlife Tip: Observe wildlife — never feed wild animals.",
]

# ── Timing ─────────────────────────────────────────────────────────────────────
const SPLASH_DURATION   := 2.0
const MOVE_DURATION     := 0.15   # seconds per tile move animation
const COLLECT_ANIM_TIME := 0.3
