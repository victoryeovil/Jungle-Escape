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
	{ "id": "explorer",      "name": "Kairo",             "cost_coins": 0,   "cost_gems": 0, "unlock_method": "default", "available_after_level": 0 },
	{ "id": "jungle_girl",   "name": "Zuri",              "cost_coins": 0,   "cost_gems": 0, "unlock_method": "default", "available_after_level": 0 },
	{ "id": "monkey",        "name": "Monkey",            "cost_coins": 300, "cost_gems": 0, "unlock_method": "coins",   "available_after_level": 3 },
	{ "id": "robot",         "name": "Robot Explorer",    "cost_coins": 0,   "cost_gems": 5, "unlock_method": "gems",    "available_after_level": 5 },
	{ "id": "treasure",      "name": "Treasure Hunter",   "cost_coins": 500, "cost_gems": 0, "unlock_method": "coins",   "available_after_level": 8 },
	{ "id": "tribal",        "name": "Tribal Adventurer", "cost_coins": 0,   "cost_gems": 8, "unlock_method": "gems",    "available_after_level": 10 },
	{ "id": "golden",        "name": "Golden Explorer",   "cost_coins": 0,   "cost_gems": 0, "unlock_method": "stars",   "unlock_stars": 60, "available_after_level": 20 },
]

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
