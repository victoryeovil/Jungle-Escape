extends Control

# ── Level data ────────────────────────────────────────────────────────────────
const TOTAL_LEVELS := 20
const MAP_ART_PATH := "res://assets/backgrounds/bg_jungle_map.png"

const LEVEL_INFO: Array = [
	# ── Chapter 1: The Lost Path (Levels 1–6) ──
	{ "name": "Jungle Trail",        "chapter": "Chapter 1", "area": "Jungle Entrance",
	  "zone": "jungle",    "color": Color(0.18, 0.52, 0.12),
	  "desc": "Your expedition begins on a bright jungle trail. Collect coins and reach the finish gate.",
	  "rewards": "Coins  ·  Gems  ·  Map Piece" },
	{ "name": "Deep Forest",         "chapter": "Chapter 2", "area": "Deep Forest",
	  "zone": "jungle",    "color": Color(0.08, 0.34, 0.08),
	  "desc": "The trees grow taller. The path bends LEFT into darkness. Monkeys watch from the canopy.",
	  "rewards": "Coins  ·  Gems  ·  Sunstone Shard" },
	{ "name": "River of Echoes",     "chapter": "Chapter 3", "area": "River Crossing",
	  "zone": "river",     "color": Color(0.10, 0.30, 0.52),
	  "desc": "The Lost Path reaches a river that guards a Sunstone fragment. Turn RIGHT across the old bridge.",
	  "rewards": "Coins  ·  Wood  ·  Map Piece  ·  Sunstone Shard" },
	{ "name": "Ancient Ruins",       "chapter": "Chapter 4", "area": "Ancient Ruins",
	  "zone": "ruins",     "color": Color(0.34, 0.24, 0.10),
	  "desc": "Moss-covered pillars rise from the jungle. Ancient traps guard a glowing relic. Turn LEFT.",
	  "rewards": "Coins  ·  Relic Key  ·  Bricks  ·  Sunstone Shard" },
	{ "name": "Temple Approach",     "chapter": "Chapter 5", "area": "Temple Gates",
	  "zone": "ruins",     "color": Color(0.55, 0.42, 0.08),
	  "desc": "The Temple of the First Sun is near. The Sunstone Heart is within reach. Turn RIGHT.",
	  "rewards": "Coins  ·  Gems  ·  Map Piece  ·  Sunstone Shard" },
	{ "name": "Wildlands of Peace",  "chapter": "Chapter 6", "area": "Wildlands",
	  "zone": "wildlands", "color": Color(0.68, 0.54, 0.18),
	  "desc": "A sandy path opens into warm wildlands. Elephants roam in the distance. Sand Shoes required.",
	  "rewards": "Coins  ·  Wood  ·  Bricks  ·  Food  ·  Sunstone Shard" },
	# ── Chapter 2: Wildlands Settlement (Levels 7–13) ──
	{ "name": "First Clearing",      "chapter": "Chapter 7", "area": "Wildlands Edge",
	  "zone": "wildlands", "color": Color(0.78, 0.58, 0.16),
	  "desc": "The jungle opens into a warm clearing. Build your first supply cache with wood and bricks.",
	  "rewards": "Coins  ·  Wood  ·  Bricks  ·  Food" },
	{ "name": "Foundation Run",      "chapter": "Chapter 8", "area": "Settlement Clearing",
	  "zone": "wildlands", "color": Color(0.44, 0.30, 0.12),
	  "desc": "Gather bricks and tools to lay the foundation of the jungle home. Two turns ahead.",
	  "rewards": "Coins  ·  Bricks  ·  Tools" },
	{ "name": "Timber Trail",        "chapter": "Chapter 9", "area": "Woodland Path",
	  "zone": "jungle",    "color": Color(0.32, 0.22, 0.08),
	  "desc": "A winding woodland path rich with timber. Rope and wood for the walls ahead.",
	  "rewards": "Coins  ·  Wood  ·  Rope" },
	{ "name": "The Lost Paw Trail",  "chapter": "Chapter 10", "area": "Mud Trail",
	  "zone": "jungle",    "color": Color(0.18, 0.30, 0.12),
	  "desc": "Muddy prints lead through the bush. Keep your medicine pack close on this hidden trail.",
	  "rewards": "Coins  ·  Food  ·  Medicine Pack  ·  Dog Token" },
	{ "name": "Rabbit Tracks",       "chapter": "Chapter 11", "area": "Grassland Route",
	  "zone": "wildlands", "color": Color(0.40, 0.52, 0.22),
	  "desc": "Spotted grassland paths where rabbits bound ahead. Earn your first animal badge.",
	  "rewards": "Coins  ·  Animal Badge  ·  Food  ·  Map Piece" },
	{ "name": "Sandy Supply Route",  "chapter": "Chapter 12", "area": "Sandy Track",
	  "zone": "wildlands", "color": Color(0.72, 0.62, 0.32),
	  "desc": "A long sandy route loaded with obstacles. Tools and food for the settlement ahead.",
	  "rewards": "Coins  ·  Tools  ·  Food  ·  Wood" },
	{ "name": "The Park Guide",      "chapter": "Chapter 13", "area": "Park Border",
	  "zone": "wildlands", "color": Color(0.72, 0.54, 0.16),
	  "desc": "Moyo the park guide shows the way. Collect animal badges to earn his respect.",
	  "rewards": "Coins  ·  Food  ·  Animal Badges" },
	# ── Chapter 3: Deep Wildlands (Levels 14–20) ──
	{ "name": "Warthog Watch",       "chapter": "Chapter 14", "area": "Grassland Post",
	  "zone": "wildlands", "color": Color(0.70, 0.50, 0.14),
	  "desc": "Warthogs cross the trail ahead. Collect animal badges and tiles for the home walls.",
	  "rewards": "Coins  ·  Animal Badge  ·  Bricks  ·  Tiles" },
	{ "name": "Market Path",         "chapter": "Chapter 15", "area": "Settlement Market",
	  "zone": "wildlands", "color": Color(0.82, 0.48, 0.14),
	  "desc": "Tariro the trader sets up market. Gather tiles and windows for the growing home.",
	  "rewards": "Coins  ·  Windows  ·  Tiles  ·  Food" },
	{ "name": "Antelope Trail",      "chapter": "Chapter 16", "area": "Open Savanna",
	  "zone": "wildlands", "color": Color(0.84, 0.70, 0.18),
	  "desc": "Antelope race across the open savanna. Two sharp turns on this long trail.",
	  "rewards": "Coins  ·  Animal Badge  ·  Map Piece  ·  Rope" },
	{ "name": "Window Run",          "chapter": "Chapter 17", "area": "Ruins Outpost",
	  "zone": "ruins",     "color": Color(0.44, 0.40, 0.34),
	  "desc": "An ancient outpost guards the route. Salvage windows and tiles from the ruins.",
	  "rewards": "Coins  ·  Windows  ·  Tiles  ·  Sunstone Shard  ·  Tools" },
	{ "name": "Hound of the Trail",  "chapter": "Chapter 18", "area": "Misty Hollow",
	  "zone": "jungle",    "color": Color(0.28, 0.38, 0.32),
	  "desc": "A loyal hound scouts the misty hollow. Relic keys and map pieces wait in the shadows.",
	  "rewards": "Coins  ·  Relic Key  ·  Map Piece  ·  Animal Badge" },
	{ "name": "The Builder's Visit", "chapter": "Chapter 19", "area": "Home Site",
	  "zone": "wildlands", "color": Color(0.50, 0.34, 0.14),
	  "desc": "Nyasha the village builder inspects the home site. Gather everything for the final push.",
	  "rewards": "Coins  ·  Tools  ·  Bricks  ·  Tiles  ·  Wood" },
	{ "name": "Baobab Treasure",     "chapter": "Chapter 20", "area": "The Ancient Baobab",
	  "zone": "wildlands", "color": Color(0.92, 0.72, 0.20),
	  "desc": "Beneath the great baobab tree lies the expedition's greatest treasure. Two turns. Three gemstones.",
	  "rewards": "Coins  ·  Gems  ·  Sunstone Shard  ·  Relic Key  ·  Animal Badge" },
]

const CANVAS_H  : float = 2460.0
const SCROLL_MAX: float = 1708.0   # CANVAS_H - 752 (usable scroll height)

# All 20 node positions in unified 2460 px canvas
# Ch1 y += 1640, Ch2 y += 820, Ch3 y += 0
const NODE_POS_ALL: Array = [
	Vector2(220, 2350), Vector2(318, 2222), Vector2(132, 2092),
	Vector2(322, 1968), Vector2(162, 1852), Vector2(300, 1748),
	Vector2(220, 1530), Vector2(310, 1406), Vector2(148, 1286),
	Vector2(310, 1168), Vector2(160, 1058), Vector2(306,  960),
	Vector2(190,  880),
	Vector2(220,  710), Vector2(306,  590), Vector2(152,  472),
	Vector2(310,  356), Vector2(156,  244), Vector2(308,  138),
	Vector2(200,   60),
]

const CAMP_POS   := Vector2(240, 812)   # local within ch1 section
const TEMPLE_POS := Vector2(240, 66)    # local within ch3 section

# Unified path through all 20 levels (canvas coordinates)
const PATH_PTS_ALL: Array = [
	Vector2(240, 2460),
	Vector2(236, 2426), Vector2(228, 2394), Vector2(222, 2370),
	Vector2(220, 2350),
	Vector2(232, 2312), Vector2(270, 2275), Vector2(300, 2240),
	Vector2(318, 2222),
	Vector2(288, 2184), Vector2(224, 2150), Vector2(152, 2114),
	Vector2(132, 2092),
	Vector2(148, 2054), Vector2(210, 2016), Vector2(298, 1984),
	Vector2(322, 1968),
	Vector2(286, 1932), Vector2(224, 1898), Vector2(178, 1870),
	Vector2(162, 1852),
	Vector2(176, 1820), Vector2(218, 1790), Vector2(268, 1764),
	Vector2(300, 1748),
	Vector2(280, 1690), Vector2(250, 1640), Vector2(225, 1590),
	Vector2(220, 1530),
	Vector2(240, 1488), Vector2(280, 1450), Vector2(308, 1420),
	Vector2(310, 1406),
	Vector2(286, 1368), Vector2(218, 1332), Vector2(162, 1302),
	Vector2(148, 1286),
	Vector2(160, 1246), Vector2(226, 1210), Vector2(298, 1182),
	Vector2(310, 1168),
	Vector2(284, 1128), Vector2(218, 1094), Vector2(170, 1074),
	Vector2(160, 1058),
	Vector2(174, 1016), Vector2(224,  986), Vector2(282,  968),
	Vector2(306,  960),
	Vector2(276,  926), Vector2(230,  898), Vector2(200,  882),
	Vector2(190,  880),
	Vector2(200,  820), Vector2(212,  760),
	Vector2(220,  710),
	Vector2(238,  666), Vector2(278,  630), Vector2(304,  604),
	Vector2(306,  590),
	Vector2(282,  550), Vector2(214,  516), Vector2(162,  488),
	Vector2(152,  472),
	Vector2(162,  430), Vector2(228,  396), Vector2(298,  368),
	Vector2(310,  356),
	Vector2(286,  314), Vector2(220,  278), Vector2(166,  258),
	Vector2(156,  244),
	Vector2(168,  200), Vector2(226,  168), Vector2(284,  148),
	Vector2(308,  138),
	Vector2(280,  104), Vector2(236,   74), Vector2(204,   62),
	Vector2(200,   60),
]

# ── Colour palette ───────────────────────────────────────────────────────────
const C_SKY        := Color(0.22, 0.42, 0.60)
const C_HORIZON    := Color(0.38, 0.52, 0.38)
const C_WILDLANDS  := Color(0.50, 0.40, 0.20)
const C_WILD_SAND  := Color(0.60, 0.48, 0.24)
const C_TEMPLE_Z   := Color(0.22, 0.17, 0.08)
const C_RUINS_Z    := Color(0.07, 0.09, 0.06)
const C_JUNGLE     := Color(0.03, 0.10, 0.04)
const C_JUNGLE2    := Color(0.05, 0.15, 0.06)
const C_FLOOR_Z    := Color(0.08, 0.18, 0.07)
const C_EARTH      := Color(0.20, 0.14, 0.07)
const C_EARTH2     := Color(0.14, 0.10, 0.05)

const C_TREE_D     := Color(0.02, 0.07, 0.03)
const C_TREE_M     := Color(0.03, 0.13, 0.05)
const C_TREE_L     := Color(0.06, 0.20, 0.09)
const C_TREE_PALE  := Color(0.10, 0.28, 0.12, 0.75)
const C_ACACIA_T   := Color(0.32, 0.20, 0.08)
const C_ACACIA_C   := Color(0.20, 0.36, 0.09)

const C_RIVER_D    := Color(0.08, 0.24, 0.42)
const C_RIVER_M    := Color(0.12, 0.34, 0.54)
const C_RIVER_L    := Color(0.18, 0.48, 0.66)
const C_RIVER_BANK := Color(0.14, 0.28, 0.14)
const C_SHIMMER    := Color(0.44, 0.74, 0.90)

const C_STONE_D    := Color(0.24, 0.19, 0.11)
const C_STONE_M    := Color(0.35, 0.28, 0.16)
const C_STONE_L    := Color(0.48, 0.38, 0.22)
const C_MOSS       := Color(0.16, 0.26, 0.10)
const C_GOLD       := Color(0.96, 0.82, 0.26)
const C_FIRE_O     := Color(0.96, 0.52, 0.10)
const C_FIRE_Y     := Color(0.98, 0.92, 0.22)

const C_PATH_SHD   := Color(0.0,  0.0,  0.0,  0.22)
const C_PATH_OUT   := Color(0.25, 0.15, 0.06)
const C_PATH_EDGE  := Color(0.38, 0.24, 0.10)
const C_PATH_DIRT  := Color(0.62, 0.44, 0.22)
const C_PATH_MID   := Color(0.76, 0.58, 0.34)
const C_PATH_LITE  := Color(0.88, 0.72, 0.44, 0.28)

# ── State ─────────────────────────────────────────────────────────────────────
var _rng             := RandomNumberGenerator.new()
var _preview_panel   : Control = null
var _current_preview : int     = 0
var _sand_popup      : Control = null
var _lives_popup     : Control = null
var _bird1           : Label   = null
var _bird2           : Label   = null
var _bird1_x         : float   = -28.0
var _bird2_x         : float   = 510.0
var _shimmer_t       : float   = 0.0
var _bg_texture      : Texture2D = null
var _scroll_y        : float   = SCROLL_MAX  # start showing chapter 1 at bottom
var _is_dragging     : bool    = false
var _drag_start_y    : float   = 0.0
var _drag_start_scroll: float  = 0.0
var _marker_layer    : Control = null

# ── SETUP ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_rng.seed = 4419
	_bg_texture = _load_map_texture()
	_setup()

func _setup() -> void:
	_marker_layer = Control.new()
	_marker_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marker_layer.size = Vector2(480, CANVAS_H)
	_marker_layer.position = Vector2(0.0, 68.0 - _scroll_y)
	add_child(_marker_layer)
	if _bg_texture == null:
		_build_bird_labels()
	_build_level_markers()
	_build_ui_overlay()
	_build_preview_panel()
	_build_sand_shoes_popup()
	_build_lives_popup()
	queue_redraw()

func _process(delta: float) -> void:
	_shimmer_t += delta * 1.25
	_bird1_x   += delta * 52.0
	_bird2_x   -= delta * 40.0
	if _bird1_x >  528.0: _bird1_x = -28.0
	if _bird2_x < -28.0:  _bird2_x =  528.0
	if _bird1 != null: _bird1.position.x = _bird1_x
	if _bird2 != null: _bird2.position.x = _bird2_x
	if _marker_layer != null:
		_marker_layer.position.y = 68.0 - _scroll_y
	queue_redraw()

# ── CUSTOM DRAW ───────────────────────────────────────────────────────────────
func _draw() -> void:
	if _bg_texture != null:
		_draw_reference_scroll_canvas()
		draw_set_transform(Vector2(0.0, -_scroll_y + 68.0))
		_draw_reference_map_life()
		_draw_progress_landmarks()
		_draw_marker_halos()
		draw_set_transform(Vector2.ZERO)
		_draw_scrollbar()
		return

	# Chapter 1 section — canvas y 1640–2460 (jungle / ruins / river / camp)
	var t1 := 1640.0 - _scroll_y + 68.0
	draw_set_transform(Vector2(0.0, t1))
	_rng.seed = 4419
	_draw_backgrounds()
	_draw_zone_accents()
	_draw_jungle_trees()
	_draw_ruins_deco()
	_draw_river_art()
	_draw_camp_art()
	_draw_fog()

	# Chapter 2 section — canvas y 820–1640 (wildlands settlement)
	var t2 := 820.0 - _scroll_y + 68.0
	draw_set_transform(Vector2(0.0, t2))
	_rng.seed = 5311
	_draw_backgrounds()
	_draw_zone_accents()
	_draw_jungle_trees()
	_draw_wildlands_deco()
	_draw_fog()

	# Chapter 3 section — canvas y 0–820 (deep wildlands / baobab)
	var t3 := -_scroll_y + 68.0
	draw_set_transform(Vector2(0.0, t3))
	_rng.seed = 6173
	_draw_backgrounds()
	_draw_zone_accents()
	_draw_jungle_trees()
	_draw_wildlands_deco()
	_draw_temple_art()
	_draw_fog()

	# Unified path + markers in full canvas coordinates
	draw_set_transform(Vector2(0.0, -_scroll_y + 68.0))
	_draw_route_mode_art()
	_draw_lost_path()
	_draw_marker_halos()

	draw_set_transform(Vector2.ZERO)
	_draw_scrollbar()

# ── DRAW: backgrounds ─────────────────────────────────────────────────────────
func _draw_reference_scroll_canvas() -> void:
	draw_set_transform(Vector2(0.0, -_scroll_y + 68.0))
	const SECTION_H := 820.0
	var tex_size := _bg_texture.get_size()
	var src_top := tex_size.y * 0.072
	var src_bottom_pad := tex_size.y * 0.047
	var src_rect := Rect2(0.0, src_top, tex_size.x, tex_size.y - src_top - src_bottom_pad)
	for i in range(3):
		var y := float(i) * SECTION_H
		draw_texture_rect_region(_bg_texture, Rect2(0.0, y, 480.0, SECTION_H + 1.0), src_rect)
		if i == 0:
			draw_rect(Rect2(0.0, y, 480.0, SECTION_H), Color(0.03, 0.05, 0.02, 0.10))
		elif i == 1:
			draw_rect(Rect2(0.0, y, 480.0, SECTION_H), Color(0.10, 0.07, 0.02, 0.07))
		else:
			draw_rect(Rect2(0.0, y, 480.0, SECTION_H), Color(0.02, 0.08, 0.03, 0.05))
	draw_rect(Rect2(0.0, 0.0, 480.0, CANVAS_H), Color(0.0, 0.0, 0.0, 0.08))
	draw_set_transform(Vector2.ZERO)

func _draw_reference_map_life() -> void:
	_draw_moving_birds()
	_draw_moving_elephant(Vector2(64.0, 1698.0), 0.0)
	_draw_moving_elephant(Vector2(348.0, 894.0), 1.4, 0.78)
	_draw_moving_rabbit(Vector2(132.0, 1086.0), 2.1)
	_draw_moving_antelope(Vector2(96.0, 480.0), 0.7)
	_draw_moving_boar(Vector2(318.0, 172.0), 1.2)
	_draw_moving_monkey(Vector2(380.0, 2194.0), 0.4)

func _draw_progress_landmarks() -> void:
	_draw_home_progress_site(Vector2(96.0, 1500.0), clamp(SaveManager.get_home_stage(), 0, 6))
	_draw_temple_progress_site(Vector2(244.0, 126.0), _temple_progress_stage())

func _draw_moving_birds() -> void:
	for i in range(5):
		var y := 106.0 + float(i % 3) * 38.0 + float(i / 3) * 840.0
		var x := fposmod(_shimmer_t * (28.0 + float(i) * 7.0) + float(i) * 92.0, 560.0) - 40.0
		_draw_bird_shape(Vector2(x, y), 0.68 + float(i % 2) * 0.18)

func _draw_bird_shape(p: Vector2, scale: float = 1.0) -> void:
	var c := Color(0.04, 0.03, 0.02, 0.72)
	var wing := 10.0 * scale
	draw_line(p, p + Vector2(-wing, -5.0 * scale), c, 2.0, true)
	draw_line(p, p + Vector2(wing, -5.0 * scale), c, 2.0, true)
	draw_circle(p, 1.5 * scale, c)

func _draw_moving_elephant(base: Vector2, phase: float, scale: float = 1.0) -> void:
	var p := base + Vector2(sin(_shimmer_t * 0.55 + phase) * 18.0, sin(_shimmer_t * 1.2 + phase) * 1.5)
	var c := Color(0.24, 0.22, 0.18, 0.76)
	var hi := Color(0.44, 0.40, 0.30, 0.50)
	draw_circle(p + Vector2(0, 2) * scale, 18.0 * scale, c)
	draw_circle(p + Vector2(19, -4) * scale, 11.0 * scale, c)
	draw_rect(Rect2(p.x + 23.0 * scale, p.y - 1.0 * scale, 5.0 * scale, 20.0 * scale), c)
	draw_circle(p + Vector2(13, -7) * scale, 7.0 * scale, hi)
	for i in range(4):
		draw_rect(Rect2(p.x - 13.0 * scale + float(i) * 8.0 * scale, p.y + 14.0 * scale, 4.0 * scale, 16.0 * scale), c.darkened(0.10))
	draw_line(p + Vector2(-18, -4) * scale, p + Vector2(-29, -11) * scale, c, 3.0 * scale, true)

func _draw_moving_rabbit(base: Vector2, phase: float) -> void:
	var hop := absf(sin(_shimmer_t * 2.6 + phase))
	var p := base + Vector2(sin(_shimmer_t * 0.9 + phase) * 24.0, -hop * 7.0)
	var c := Color(0.82, 0.74, 0.56, 0.86)
	draw_circle(p, 8.0, c)
	draw_circle(p + Vector2(9, -3), 5.0, c.lightened(0.08))
	draw_line(p + Vector2(10, -8), p + Vector2(14, -20), c, 3.0, true)
	draw_line(p + Vector2(6, -8), p + Vector2(5, -20), c, 3.0, true)
	draw_circle(p + Vector2(-8, 1), 4.0, Color(1.0, 0.96, 0.78, 0.72))

func _draw_moving_antelope(base: Vector2, phase: float) -> void:
	var stride := sin(_shimmer_t * 2.2 + phase)
	var p := base + Vector2(sin(_shimmer_t * 0.7 + phase) * 30.0, 0.0)
	var c := Color(0.74, 0.48, 0.20, 0.82)
	draw_rect(Rect2(p.x - 16, p.y - 7, 28, 12), c)
	draw_circle(p + Vector2(15, -9), 7.0, c.lightened(0.08))
	draw_line(p + Vector2(17, -16), p + Vector2(12, -27), Color(0.16, 0.10, 0.04, 0.78), 2.0, true)
	draw_line(p + Vector2(20, -15), p + Vector2(24, -27), Color(0.16, 0.10, 0.04, 0.78), 2.0, true)
	draw_line(p + Vector2(-8, 4), p + Vector2(-12, 21 + stride * 3.0), c.darkened(0.14), 3.0, true)
	draw_line(p + Vector2(7, 4), p + Vector2(11, 20 - stride * 3.0), c.darkened(0.14), 3.0, true)

func _draw_moving_boar(base: Vector2, phase: float) -> void:
	var p := base + Vector2(sin(_shimmer_t * 1.35 + phase) * 20.0, sin(_shimmer_t * 2.0 + phase) * 2.0)
	var c := Color(0.30, 0.18, 0.09, 0.86)
	draw_circle(p, 15.0, c)
	draw_circle(p + Vector2(15, -3), 8.0, c.darkened(0.08))
	draw_polygon(PackedVector2Array([p + Vector2(15, -11), p + Vector2(19, -22), p + Vector2(22, -9)]), PackedColorArray([c, c, c]))
	draw_line(p + Vector2(20, -1), p + Vector2(31, -5), Color(0.92, 0.84, 0.62, 0.72), 2.0, true)
	draw_line(p + Vector2(-11, 10), p + Vector2(-14, 22), c.darkened(0.14), 3.0, true)
	draw_line(p + Vector2(7, 10), p + Vector2(10, 21), c.darkened(0.14), 3.0, true)

func _draw_moving_monkey(base: Vector2, phase: float) -> void:
	var swing := sin(_shimmer_t * 1.8 + phase)
	var p := base + Vector2(swing * 22.0, cos(_shimmer_t * 1.8 + phase) * 6.0)
	var c := Color(0.46, 0.26, 0.10, 0.86)
	draw_line(base + Vector2(-22, -36), p + Vector2(0, -14), Color(0.18, 0.10, 0.04, 0.70), 2.0, true)
	draw_circle(p, 9.0, c)
	draw_circle(p + Vector2(0, -12), 7.0, c.lightened(0.12))
	draw_circle(p + Vector2(-7, -13), 3.0, c.lightened(0.06))
	draw_circle(p + Vector2(7, -13), 3.0, c.lightened(0.06))
	draw_arc(p + Vector2(-9, 3), 13.0, -0.6, 1.45, 12, c, 3.0, true)

func _draw_home_progress_site(pos: Vector2, stage: int) -> void:
	draw_circle(pos + Vector2(0, 20), 46.0, Color(0.0, 0.0, 0.0, 0.30))
	draw_rect(Rect2(pos.x - 54, pos.y + 22, 108, 10), Color(0.24, 0.15, 0.07, 0.88))
	for i in range(5):
		draw_rect(Rect2(pos.x - 45 + float(i) * 22.0, pos.y + 18, 4, 22), Color(0.58, 0.38, 0.16, 0.90))
	if stage <= 0:
		_draw_build_label(pos + Vector2(-52, -34), "HOME SITE")
		_draw_signpost(pos + Vector2(-22, 5), "LAND")
		return
	if stage >= 1:
		draw_rect(Rect2(pos.x - 38, pos.y + 5, 76, 14), Color(0.48, 0.34, 0.16, 0.92))
	if stage >= 2:
		draw_rect(Rect2(pos.x - 34, pos.y - 8, 68, 16), Color(0.42, 0.32, 0.22, 0.94))
		for i in range(5):
			draw_rect(Rect2(pos.x - 32 + float(i) * 14.0, pos.y - 7, 11, 6), Color(0.62, 0.50, 0.34, 0.90))
	if stage >= 3:
		draw_rect(Rect2(pos.x - 30, pos.y - 34, 60, 30), Color(0.42, 0.23, 0.10, 0.94))
		draw_rect(Rect2(pos.x - 7, pos.y - 20, 14, 16), Color(0.12, 0.08, 0.04, 0.92))
	if stage >= 4:
		draw_polygon(PackedVector2Array([
			pos + Vector2(-38, -34),
			pos + Vector2(0, -62),
			pos + Vector2(38, -34),
		]), PackedColorArray([
			Color(0.08, 0.28, 0.20, 0.96),
			Color(0.14, 0.42, 0.30, 0.96),
			Color(0.06, 0.20, 0.15, 0.96),
		]))
	if stage >= 5:
		draw_rect(Rect2(pos.x - 25, pos.y - 27, 12, 11), Color(1.0, 0.72, 0.20, 0.86))
		draw_rect(Rect2(pos.x + 13, pos.y - 27, 12, 11), Color(1.0, 0.72, 0.20, 0.86))
	if stage >= 6:
		draw_circle(pos + Vector2(0, -24), 54.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.10))
		draw_rect(Rect2(pos.x - 2, pos.y - 72, 4, 16), C_GOLD)
	_draw_build_label(pos + Vector2(-58, -82), "HOME " + str(stage) + "/6")

func _draw_temple_progress_site(pos: Vector2, stage: int) -> void:
	draw_circle(pos + Vector2(0, 10), 58.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.10 + float(stage) * 0.018))
	draw_rect(Rect2(pos.x - 52, pos.y + 24, 104, 9), Color(0.22, 0.16, 0.09, 0.90))
	if stage <= 0:
		for i in range(5):
			draw_rect(Rect2(pos.x - 42 + float(i) * 18.0, pos.y + 10 + float(i % 2) * 5.0, 15, 8), C_STONE_D)
		_draw_build_label(pos + Vector2(-58, -54), "TEMPLE RUINS")
		return
	if stage >= 1:
		for i in range(4):
			draw_rect(Rect2(pos.x - 42 + float(i) * 28.0, pos.y - 5, 18, 30), C_STONE_M)
	if stage >= 2:
		draw_rect(Rect2(pos.x - 50, pos.y - 16, 100, 12), C_STONE_L)
		draw_rect(Rect2(pos.x - 38, pos.y - 28, 76, 12), C_STONE_M)
	if stage >= 3:
		draw_polygon(PackedVector2Array([
			pos + Vector2(-46, -28),
			pos + Vector2(0, -62),
			pos + Vector2(46, -28),
		]), PackedColorArray([C_STONE_M, C_GOLD.darkened(0.12), C_STONE_M]))
	if stage >= 4:
		draw_circle(pos + Vector2(0, -22), 14.0, C_GOLD)
		for i in range(8):
			var a := float(i) * TAU / 8.0
			draw_line(pos + Vector2(0, -22) + Vector2(cos(a), sin(a)) * 17.0,
				pos + Vector2(0, -22) + Vector2(cos(a), sin(a)) * 25.0,
				C_GOLD, 2.0, true)
	if stage >= 5:
		draw_circle(pos + Vector2(0, -22), 38.0, Color(1.0, 0.82, 0.28, 0.16))
		draw_rect(Rect2(pos.x - 6, pos.y + 2, 12, 22), Color(1.0, 0.82, 0.28, 0.52))
	_draw_build_label(pos + Vector2(-58, -76), "TEMPLE " + str(stage) + "/5")

func _temple_progress_stage() -> int:
	if SaveManager.is_level_completed(20):
		return 5
	if SaveManager.is_level_completed(17):
		return 4
	if SaveManager.is_level_completed(12):
		return 3
	if SaveManager.is_level_completed(6):
		return 2
	if SaveManager.is_level_completed(5):
		return 1
	return 0

func _draw_signpost(pos: Vector2, text: String) -> void:
	draw_rect(Rect2(pos.x - 2, pos.y - 16, 4, 34), Color(0.24, 0.14, 0.05, 0.94))
	draw_rect(Rect2(pos.x - 22, pos.y - 28, 44, 15), Color(0.50, 0.30, 0.11, 0.94))
	var font := get_theme_default_font()
	if font != null:
		draw_string(font, pos + Vector2(-17, -17), text, HORIZONTAL_ALIGNMENT_CENTER, 34.0, 7,
			Color(1.0, 0.86, 0.46, 0.92))

func _draw_build_label(pos: Vector2, text: String) -> void:
	draw_rect(Rect2(pos, Vector2(116, 20)), Color(0.03, 0.02, 0.01, 0.76))
	draw_rect(Rect2(pos, Vector2(116, 2)), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.70))
	var font := get_theme_default_font()
	if font != null:
		draw_string(font, pos + Vector2(0, 14), text, HORIZONTAL_ALIGNMENT_CENTER, 116.0, 9,
			Color(1.0, 0.88, 0.48, 0.96))

func _draw_backgrounds() -> void:
	# Use bg_jungle_map.png when present; procedural fallback otherwise
	if _bg_texture != null:
		_draw_reference_map()
		return
	# Sky gradient across wildlands/temple top
	_grad(0,   76,  C_SKY,       C_HORIZON,   10)
	_grad(66,  168, C_HORIZON,   C_WILDLANDS, 14)
	# Wildlands warm band
	draw_rect(Rect2(0, 138, 480, 50), C_WILDLANDS)
	# Temple zone
	_grad(168, 220, C_WILDLANDS, C_TEMPLE_Z, 8)
	draw_rect(Rect2(0, 210, 480, 60), C_TEMPLE_Z)
	# Ruins zone
	_grad(258, 310, C_TEMPLE_Z, C_RUINS_Z, 8)
	draw_rect(Rect2(0, 300, 480, 108), C_RUINS_Z)
	# River transition
	_grad(398, 430, C_RUINS_Z, C_JUNGLE, 5)
	# Deep jungle
	draw_rect(Rect2(0, 420, 480, 260), C_JUNGLE)
	_grad(600, 660, C_JUNGLE, C_JUNGLE2, 6)
	# Floor
	_grad(660, 720, C_JUNGLE2, C_FLOOR_Z, 8)
	draw_rect(Rect2(0, 710, 480, 100), C_FLOOR_Z)
	# Camp earth
	_grad(800, 854, C_FLOOR_Z, C_EARTH2, 8)
	draw_rect(Rect2(0, 840, 480, 14), C_EARTH2)

func _draw_reference_map() -> void:
	draw_texture_rect(_bg_texture, Rect2(0, 0, 480, 854), false)

func _grad(y1: float, y2: float, c1: Color, c2: Color, steps: int) -> void:
	var h := (y2 - y1) / float(steps)
	for i in range(steps):
		var t := (float(i) + 0.5) / float(steps)
		draw_rect(Rect2(0, y1 + i * h, 480, h + 1.0), c1.lerp(c2, t))

# ── DRAW: zone accent ─────────────────────────────────────────────────────────
func _draw_zone_accents() -> void:
	# Sandy floor strip in wildlands
	for i in range(6):
		var tx := float(i) * 82.0 + _rng.randf_range(-6.0, 6.0)
		draw_rect(Rect2(tx, 142, _rng.randf_range(55, 90), 6), C_WILD_SAND.darkened(0.3))
	# Mossy ground in ruins
	for i in range(8):
		var tx := float(i) * 58.0 + _rng.randf_range(-8.0, 8.0)
		var ty := _rng.randf_range(296, 390)
		draw_rect(Rect2(tx, ty, _rng.randf_range(20, 44), 3), C_MOSS.darkened(0.3))
	# Grass tufts at jungle floor
	for i in range(12):
		var tx := float(i) * 40.0 + _rng.randf_range(-4.0, 4.0)
		var ty := _rng.randf_range(710, 724)
		draw_rect(Rect2(tx, ty, 4, _rng.randf_range(8, 18)), C_TREE_L)
	# Sandy ground tufts in camp
	for i in range(9):
		var tx := float(i) * 52.0 + _rng.randf_range(-5.0, 5.0)
		draw_rect(Rect2(tx, 808, 3, _rng.randf_range(6, 14)), C_EARTH.lightened(0.18))

# ── DRAW: jungle tree silhouettes ─────────────────────────────────────────────
func _draw_jungle_trees() -> void:
	# Left-edge trees
	for i in range(10):
		var yy := 188.0 + float(i) * 58.0
		if yy > 702.0: break
		var w  := float(_rng.randi_range(22, 42))
		var h  := float(_rng.randi_range(82, 145))
		_dtree(0.0, yy, w, h)
	# Right-edge trees
	for i in range(10):
		var yy := 176.0 + float(i) * 56.0
		if yy > 702.0: break
		var w  := float(_rng.randi_range(24, 44))
		var h  := float(_rng.randi_range(80, 142))
		_dtree(480.0 - w * 0.45, yy, w, h)
	# Mid-scene accent trees (jungle depth)
	_dtree(354.0, 520.0, 24.0, 98.0)
	_dtree(56.0,  604.0, 20.0, 84.0)
	_dtree(390.0, 626.0, 18.0, 72.0)

func _dtree(x: float, y_top: float, w: float, h: float) -> void:
	var cx := x + w * 0.5
	draw_rect(Rect2(x + w * 0.18, y_top, w * 0.28, h), C_TREE_D)
	# Layer 1 — wide base canopy
	draw_polygon(PackedVector2Array([
		Vector2(cx, y_top - h * 0.70),
		Vector2(cx - w * 1.20, y_top + 10.0),
		Vector2(cx + w * 1.20, y_top + 10.0),
	]), PackedColorArray([C_TREE_D, C_TREE_D, C_TREE_D]))
	# Layer 2 — mid canopy
	draw_polygon(PackedVector2Array([
		Vector2(cx, y_top - h * 1.00),
		Vector2(cx - w * 0.80, y_top - h * 0.26),
		Vector2(cx + w * 0.80, y_top - h * 0.26),
	]), PackedColorArray([C_TREE_M, C_TREE_M, C_TREE_M]))
	# Layer 3 — top canopy peak
	draw_polygon(PackedVector2Array([
		Vector2(cx, y_top - h * 1.24),
		Vector2(cx - w * 0.45, y_top - h * 0.64),
		Vector2(cx + w * 0.45, y_top - h * 0.64),
	]), PackedColorArray([C_TREE_L, C_TREE_L, C_TREE_L]))
	# Edge highlight
	draw_polygon(PackedVector2Array([
		Vector2(cx, y_top - h * 1.30),
		Vector2(cx - w * 0.22, y_top - h * 0.92),
		Vector2(cx + w * 0.22, y_top - h * 0.92),
	]), PackedColorArray([C_TREE_PALE, C_TREE_PALE, C_TREE_PALE]))

# ── DRAW: wildlands decorations ───────────────────────────────────────────────
func _draw_wildlands_deco() -> void:
	# Acacia tree pair at top corners
	_dacacia(34.0,  148.0, 8.0, 48.0)
	_dacacia(424.0, 142.0, 8.0, 44.0)
	_dacacia(14.0,  108.0, 6.0, 36.0)
	_dacacia(444.0, 112.0, 6.0, 34.0)
	# Elephant silhouette (distant, left side)
	var ec := Color(0.26, 0.22, 0.16, 0.60)
	draw_rect(Rect2(34, 122, 28, 20),  ec)   # body
	draw_rect(Rect2(54, 114, 14, 12),  ec)   # head
	draw_rect(Rect2(58, 110, 5,  16),  ec)   # trunk
	draw_rect(Rect2(36, 140, 5,  16),  ec)   # leg 1
	draw_rect(Rect2(44, 140, 5,  16),  ec)   # leg 2
	draw_rect(Rect2(52, 140, 5,  16),  ec)   # leg 3
	# Warthog (right side, small)
	var wc := Color(0.36, 0.28, 0.16, 0.52)
	draw_rect(Rect2(384, 132, 20, 11), wc)   # body
	draw_rect(Rect2(398, 126, 9,  9),  wc)   # head
	draw_rect(Rect2(406, 127, 5,  3),  Color(0.80, 0.72, 0.52, 0.52))  # tusk
	draw_rect(Rect2(386, 141, 4,  9),  wc)
	draw_rect(Rect2(393, 141, 4,  9),  wc)
	draw_rect(Rect2(400, 141, 4,  9),  wc)
	# Sandy dune mounds
	for i in range(4):
		var dx := 60.0 + float(i) * 95.0
		var dw := 68.0 + float(i) * 8.0
		draw_polygon(PackedVector2Array([
			Vector2(dx + dw * 0.5, 138.0),
			Vector2(dx, 156.0),
			Vector2(dx + dw, 156.0),
		]), PackedColorArray([C_WILD_SAND, C_WILD_SAND, C_WILD_SAND]))

func _dacacia(x: float, y: float, tw: float, th: float) -> void:
	draw_rect(Rect2(x, y, tw, th), C_ACACIA_T)
	var cw := tw * 3.6
	draw_rect(Rect2(x + tw * 0.5 - cw * 0.5, y - tw * 1.2, cw, tw * 0.8), C_ACACIA_C)
	draw_rect(Rect2(x + tw * 0.5 - cw * 0.3, y - tw * 1.9, cw * 0.6, tw * 0.6),
		C_ACACIA_C.lightened(0.08))

# ── DRAW: ruins decorations ───────────────────────────────────────────────────
func _draw_ruins_deco() -> void:
	# Broken pillars (Level 4 zone ~y 290-390)
	for arr in [[56, 304, 12, 52], [62, 290, 18, 10], [404, 326, 14, 48], [400, 314, 22, 10]]:
		draw_rect(Rect2(arr[0], arr[1], arr[2], arr[3]), C_STONE_M)
	# Moss on pillars
	draw_rect(Rect2(58, 326, 10, 6), C_MOSS)
	draw_rect(Rect2(406, 348, 10, 5), C_MOSS)
	# Relic glow fragment
	draw_rect(Rect2(402, 362, 9, 8), C_GOLD)
	draw_circle(Vector2(406, 366), 7.0, Color(0.96, 0.78, 0.20, 0.38))
	# Fallen stone slabs on ground
	for arr in [[28, 394, 42, 6], [368, 388, 56, 7], [190, 396, 30, 5]]:
		draw_rect(Rect2(arr[0], arr[1], arr[2], arr[3]),
			C_STONE_D.lerp(C_STONE_M, 0.4))
	# Vine drapes on sides
	for i in range(4):
		var vx := float(i) * 110.0 + 18.0
		draw_rect(Rect2(vx, 268, 4, _rng.randi_range(48, 88)),
			Color(0.12, 0.30, 0.10, 0.62))
		draw_rect(Rect2(480 - vx - 4, 282, 4, _rng.randi_range(40, 76)),
			Color(0.12, 0.28, 0.10, 0.55))

# ── DRAW: river ───────────────────────────────────────────────────────────────
func _draw_river_art() -> void:
	# Curved riverbanks
	var bank_top := PackedVector2Array([
		Vector2(-10, 404), Vector2(60,  400), Vector2(130, 397),
		Vector2(210, 402), Vector2(290, 406), Vector2(370, 401),
		Vector2(450, 398), Vector2(490, 400),
	])
	var bank_bot := PackedVector2Array([
		Vector2(-10, 454), Vector2(60,  458), Vector2(130, 455),
		Vector2(210, 452), Vector2(290, 456), Vector2(370, 452),
		Vector2(450, 458), Vector2(490, 456),
	])
	# Green bank strips
	draw_polyline(bank_top, C_RIVER_BANK, 7.0, true)
	draw_polyline(bank_bot, C_RIVER_BANK, 7.0, true)
	# Deep water body
	draw_polyline(bank_top, C_RIVER_D, 56.0, false)
	# River mid reflection
	var mid_pts := PackedVector2Array([
		Vector2(-10, 428), Vector2(80,  424), Vector2(180, 426),
		Vector2(270, 430), Vector2(370, 425), Vector2(490, 422),
	])
	draw_polyline(mid_pts, C_RIVER_M, 26.0, false)
	# Animated shimmer lines
	for i in range(4):
		var base_x := float(i) * 112.0 + 18.0
		var sy := 418.0 + float(i % 2) * 10.0
		var alpha: float = 0.10 + 0.16 * absf(sin(_shimmer_t + float(i) * 0.9))
		draw_rect(Rect2(base_x, sy, 90.0 + float(i) * 12.0, 4.0),
			Color(C_SHIMMER.r, C_SHIMMER.g, C_SHIMMER.b, alpha))
	# Reeds on banks
	for i in range(6):
		var rx := 260.0 + float(i) * 22.0
		draw_rect(Rect2(rx, 390, 3, 18), Color(0.26, 0.48, 0.24))
		draw_rect(Rect2(rx, 452, 3, 14), Color(0.26, 0.48, 0.24))
	# Bridge (wooden planks over water)
	draw_rect(Rect2(96, 398, 90, 56), C_STONE_D)                    # deck base
	for i in range(6):
		draw_rect(Rect2(100 + i * 14, 402, 10, 50), C_STONE_M)     # plank gaps
	draw_rect(Rect2(92,  394, 10, 64), C_STONE_D.darkened(0.2))    # left post
	draw_rect(Rect2(182, 394, 10, 64), C_STONE_D.darkened(0.2))    # right post
	draw_rect(Rect2(90,  392, 104, 8), C_STONE_L)                  # top rail
	draw_rect(Rect2(90,  450, 104, 8), C_STONE_L)                  # bottom rail

# ── DRAW: camp ────────────────────────────────────────────────────────────────
func _draw_camp_art() -> void:
	# Ground glow
	draw_circle(CAMP_POS, 36.0, Color(0.96, 0.72, 0.16, 0.14))
	# Campfire glow
	var fp := CAMP_POS + Vector2(-38, 4)
	draw_circle(fp, 16.0, Color(C_FIRE_O.r, C_FIRE_O.g, C_FIRE_O.b, 0.28))
	draw_circle(fp, 9.0,  Color(C_FIRE_Y.r, C_FIRE_Y.g, C_FIRE_Y.b, 0.22))
	# Logs
	draw_rect(Rect2(fp.x - 8, fp.y + 2,  16, 5), C_EARTH.darkened(0.3))
	draw_rect(Rect2(fp.x - 5, fp.y - 2,  10, 4), C_EARTH.darkened(0.3))
	# Flame triangles
	draw_polygon(PackedVector2Array([
		Vector2(fp.x, fp.y - 14), Vector2(fp.x - 7, fp.y + 2), Vector2(fp.x + 7, fp.y + 2),
	]), PackedColorArray([C_FIRE_Y, C_FIRE_O, C_FIRE_O]))
	draw_polygon(PackedVector2Array([
		Vector2(fp.x + 3, fp.y - 10), Vector2(fp.x - 3, fp.y + 2), Vector2(fp.x + 9, fp.y + 2),
	]), PackedColorArray([C_FIRE_Y, C_FIRE_O, C_FIRE_O]))
	# Tent (A-frame)
	var tp := CAMP_POS + Vector2(12, -6)
	draw_polygon(PackedVector2Array([
		Vector2(tp.x, tp.y - 24), Vector2(tp.x - 22, tp.y + 4), Vector2(tp.x + 22, tp.y + 4),
	]), PackedColorArray([Color(0.72, 0.22, 0.10), Color(0.72, 0.22, 0.10), Color(0.72, 0.22, 0.10)]))
	draw_polygon(PackedVector2Array([
		Vector2(tp.x, tp.y - 24), Vector2(tp.x - 22, tp.y + 4), Vector2(tp.x - 4, tp.y + 4),
	]), PackedColorArray([Color(0.52, 0.14, 0.08), Color(0.52, 0.14, 0.08), Color(0.52, 0.14, 0.08)]))
	# Tent pole
	draw_rect(Rect2(tp.x - 1, tp.y - 30, 3, 38), C_STONE_D)
	# Flag
	draw_polygon(PackedVector2Array([
		Vector2(tp.x + 1, tp.y - 30), Vector2(tp.x + 12, tp.y - 24), Vector2(tp.x + 1, tp.y - 18),
	]), PackedColorArray([C_GOLD, C_GOLD, C_GOLD]))
	# Crates
	draw_rect(Rect2(CAMP_POS.x + 30, CAMP_POS.y - 4, 14, 12), C_STONE_M)
	draw_rect(Rect2(CAMP_POS.x + 32, CAMP_POS.y - 4, 14, 12), C_EARTH)
	draw_rect(Rect2(CAMP_POS.x + 32, CAMP_POS.y - 1,  14, 2), C_STONE_D)

# ── DRAW: temple ──────────────────────────────────────────────────────────────
func _draw_temple_art() -> void:
	var gp := TEMPLE_POS
	# Main glow halos
	draw_circle(gp, 50.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.10))
	draw_circle(gp, 30.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.18))
	draw_circle(gp, 14.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.30))
	# Gate pillars
	draw_rect(Rect2(gp.x - 42, gp.y - 22, 10, 44), C_STONE_M)
	draw_rect(Rect2(gp.x + 32, gp.y - 22, 10, 44), C_STONE_M)
	# Pillar capitals
	draw_rect(Rect2(gp.x - 46, gp.y - 22, 18, 7), C_STONE_L)
	draw_rect(Rect2(gp.x + 28, gp.y - 22, 18, 7), C_STONE_L)
	# Lintel
	draw_rect(Rect2(gp.x - 46, gp.y - 28, 92, 9), C_STONE_M)
	draw_rect(Rect2(gp.x - 46, gp.y - 28, 92, 4), C_STONE_L)
	# Archway inner glow
	draw_rect(Rect2(gp.x - 32, gp.y - 20, 64, 42), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.22))
	# Sun symbol (concentric rings)
	draw_circle(gp + Vector2(0, 4), 11.0, C_GOLD)
	draw_circle(gp + Vector2(0, 4), 6.0,  Color(1.0, 0.96, 0.48))
	# Sun rays
	for i in range(8):
		var angle := float(i) * PI * 0.25
		var ray_start := gp + Vector2(cos(angle), sin(angle)) * 13.0 + Vector2(0, 4)
		var ray_end   := gp + Vector2(cos(angle), sin(angle)) * 20.0 + Vector2(0, 4)
		draw_line(ray_start, ray_end, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.70), 2.0, true)
	# Stone steps
	for s in range(3):
		var sw := 56.0 - float(s) * 10.0
		draw_rect(Rect2(gp.x - sw * 0.5, gp.y + 22.0 + float(s) * 5.0, sw, 5.0), C_STONE_M)

# ── DRAW: fog ─────────────────────────────────────────────────────────────────
func _draw_fog() -> void:
	# Check if Level 6 is locked — add fog over top area
	if not SaveManager.is_level_unlocked(6):
		draw_rect(Rect2(0,  0, 480, 80),  Color(0.08, 0.06, 0.03, 0.68))
		draw_rect(Rect2(0, 60, 480, 60),  Color(0.08, 0.06, 0.03, 0.42))
		draw_rect(Rect2(0, 100, 480, 50), Color(0.08, 0.06, 0.03, 0.20))
	# Light fog wisps across jungle mid-section
	draw_rect(Rect2(0, 480, 480, 24), Color(0.06, 0.16, 0.08, 0.14))
	draw_rect(Rect2(0, 492, 480, 12), Color(0.06, 0.16, 0.08, 0.08))

# ── DRAW: lost path ───────────────────────────────────────────────────────────
func _draw_lost_path() -> void:
	var pts := PackedVector2Array(PATH_PTS_ALL)
	# Shadow
	var shd := PackedVector2Array()
	for p: Vector2 in pts: shd.append(p + Vector2(5, 5))
	draw_polyline(shd, C_PATH_SHD, 26.0, false)
	# Outer dark edge
	draw_polyline(pts, C_PATH_OUT,  24.0, true)
	# Earthy border
	draw_polyline(pts, C_PATH_EDGE, 20.0, true)
	# Dirt fill
	draw_polyline(pts, C_PATH_DIRT, 14.0, true)
	# Centre highlight
	draw_polyline(pts, C_PATH_MID,  7.0,  true)
	# Shimmer
	draw_polyline(pts, C_PATH_LITE, 2.5,  true)
	# Small stone markers along path edges
	for i in range(0, pts.size() - 1, 3):
		var p: Vector2 = pts[i]
		var n: Vector2 = pts[i + 1]
		var dir := (n - p).normalized()
		var perp := Vector2(-dir.y, dir.x)
		draw_circle(p + perp * 8.5, 2.2, C_STONE_M)
		draw_circle(p - perp * 8.5, 2.0, C_STONE_D)

# ── DRAW: medallion nodes + label accents ────────────────────────────────────
func _draw_route_mode_art() -> void:
	_draw_canvas_region_label(Vector2(26, 2288), "LOST PATH", Color(0.20, 0.48, 0.12, 0.72))
	_draw_canvas_region_label(Vector2(260, 1508), "SETTLEMENT TRAIL", Color(0.65, 0.44, 0.12, 0.76))
	_draw_canvas_region_label(Vector2(34, 696), "DEEP WILDLANDS", Color(0.62, 0.38, 0.10, 0.74))
	_draw_canvas_region_label(Vector2(248, 32), "ANCIENT BAOBAB", Color(0.78, 0.55, 0.14, 0.78))

	_draw_tracking_trail(10, Color(0.66, 0.48, 0.24, 0.72))
	_draw_chase_trail(11, Color(0.85, 0.62, 0.18, 0.58))
	_draw_water_slide_trail(12)
	_draw_guide_post(_node_pos(13) + Vector2(54, -22), "GUIDE")
	_draw_tracking_trail(14, Color(0.68, 0.52, 0.22, 0.56))
	_draw_dock_trail(15)
	_draw_chase_trail(16, Color(0.92, 0.72, 0.16, 0.56))
	_draw_boat_trail(17)
	_draw_tracking_trail(18, Color(0.50, 0.66, 0.52, 0.58))
	_draw_escape_trail(19)
	_draw_final_baobab()

func _draw_canvas_region_label(pos: Vector2, text: String, col: Color) -> void:
	draw_rect(Rect2(pos + Vector2(3, 3), Vector2(142, 22)), Color(0.0, 0.0, 0.0, 0.28))
	draw_rect(Rect2(pos, Vector2(142, 22)), Color(0.05, 0.04, 0.02, 0.68))
	draw_rect(Rect2(pos, Vector2(142, 2)), col.lightened(0.24))
	draw_rect(Rect2(pos.x, pos.y + 20, 142, 2), col.darkened(0.12))
	_draw_leaf_pair(pos + Vector2(12, 11), col.lightened(0.15))
	_draw_leaf_pair(pos + Vector2(130, 11), col.lightened(0.15), true)
	var font := get_theme_default_font()
	if font != null:
		draw_string(font, pos + Vector2(25, 15), text, HORIZONTAL_ALIGNMENT_LEFT, 104.0, 9,
			Color(0.96, 0.88, 0.58, 0.92))

func _draw_water_slide_trail(level_id: int) -> void:
	var pts := _segment_points(level_id, -34.0, 14)
	_draw_water_ribbon(pts, 50.0, Color(0.05, 0.32, 0.54, 0.72), Color(0.18, 0.62, 0.82, 0.82))
	for i in range(2, pts.size(), 3):
		var p: Vector2 = pts[i]
		draw_circle(p + Vector2(0, 5), 7.0, Color(0.50, 0.86, 0.96, 0.22))
		draw_rect(Rect2(p.x - 13, p.y - 2, 26, 3), Color(0.70, 0.94, 1.0, 0.36))
	var exit_pos := _node_pos(level_id) + Vector2(-32, -30)
	draw_polygon(PackedVector2Array([
		exit_pos + Vector2(-18, -4),
		exit_pos + Vector2(0, 14),
		exit_pos + Vector2(18, -4),
	]), PackedColorArray([
		Color(0.65, 0.92, 1.0, 0.48),
		Color(0.16, 0.60, 0.86, 0.50),
		Color(0.65, 0.92, 1.0, 0.48),
	]))

func _draw_dock_trail(level_id: int) -> void:
	var pts := _segment_points(level_id, 28.0, 12)
	_draw_water_ribbon(pts, 42.0, Color(0.06, 0.24, 0.36, 0.62), Color(0.16, 0.46, 0.60, 0.72))
	var p := _node_pos(level_id) + Vector2(-58, -4)
	draw_rect(Rect2(p, Vector2(92, 16)), Color(0.18, 0.11, 0.05, 0.88))
	for i in range(7):
		draw_rect(Rect2(p.x + 5.0 + float(i) * 12.0, p.y + 2.0, 7.0, 12.0),
			Color(0.46, 0.28, 0.10, 0.92))
	draw_rect(Rect2(p.x - 4.0, p.y - 5.0, 6.0, 28.0), Color(0.10, 0.07, 0.03, 0.96))
	draw_rect(Rect2(p.x + 86.0, p.y - 5.0, 6.0, 28.0), Color(0.10, 0.07, 0.03, 0.96))

func _draw_boat_trail(level_id: int) -> void:
	var pts := _segment_points(level_id, -30.0, 14)
	_draw_water_ribbon(pts, 56.0, Color(0.04, 0.18, 0.34, 0.78), Color(0.12, 0.42, 0.62, 0.84))
	for i in range(1, pts.size(), 3):
		var p: Vector2 = pts[i]
		draw_rect(Rect2(p.x - 20, p.y - 1, 40, 3), Color(0.72, 0.92, 1.0, 0.32))
		draw_rect(Rect2(p.x - 6, p.y + 8, 12, 3), Color(0.84, 0.96, 1.0, 0.42))
	var boat_pos := _node_pos(level_id) + Vector2(-42, 24)
	draw_polygon(PackedVector2Array([
		boat_pos + Vector2(-20, -7),
		boat_pos + Vector2(19, -7),
		boat_pos + Vector2(10, 8),
		boat_pos + Vector2(-12, 8),
	]), PackedColorArray([
		Color(0.32, 0.18, 0.07, 0.94),
		Color(0.32, 0.18, 0.07, 0.94),
		Color(0.62, 0.38, 0.14, 0.94),
		Color(0.62, 0.38, 0.14, 0.94),
	]))
	draw_line(boat_pos + Vector2(-22, -10), boat_pos + Vector2(22, 11), Color(0.78, 0.60, 0.30), 3.0, true)

func _draw_chase_trail(level_id: int, col: Color) -> void:
	var pts := _segment_points(level_id, 24.0, 12)
	draw_polyline(pts, Color(col.r, col.g, col.b, 0.18), 44.0, true)
	draw_polyline(pts, Color(col.r, col.g, col.b, 0.36), 5.0, true)
	for i in range(1, pts.size(), 2):
		var p: Vector2 = pts[i]
		draw_circle(p + Vector2(-7, -3), 3.3, col.lightened(0.12))
		draw_circle(p + Vector2(7, 4), 3.0, col.lightened(0.08))
		draw_rect(Rect2(p.x - 12, p.y + 9, 24, 2), Color(col.r, col.g, col.b, 0.25))

func _draw_tracking_trail(level_id: int, col: Color) -> void:
	var pts := _segment_points(level_id, -18.0, 10)
	for i in range(1, pts.size(), 2):
		var p: Vector2 = pts[i]
		_draw_paw_print(p + Vector2(-10, 4), col)
		_draw_paw_print(p + Vector2(10, -4), col.darkened(0.08))

func _draw_escape_trail(level_id: int) -> void:
	var pts := _segment_points(level_id, 22.0, 12)
	draw_polyline(pts, Color(0.44, 0.10, 0.04, 0.22), 52.0, true)
	draw_polyline(pts, Color(0.88, 0.34, 0.08, 0.44), 6.0, true)
	for i in range(1, pts.size(), 2):
		var p: Vector2 = pts[i]
		draw_line(p + Vector2(-23, -8), p + Vector2(-8, 7), Color(0.66, 0.26, 0.08, 0.72), 3.0, true)
		draw_line(p + Vector2(21, -8), p + Vector2(7, 8), Color(0.66, 0.26, 0.08, 0.72), 3.0, true)
		draw_circle(p + Vector2(0, -14), 5.0, Color(0.96, 0.58, 0.10, 0.48))

func _draw_final_baobab() -> void:
	var p := _node_pos(20) + Vector2(54, -6)
	draw_circle(p + Vector2(0, -44), 44.0, Color(0.10, 0.24, 0.07, 0.74))
	draw_circle(p + Vector2(-30, -38), 29.0, Color(0.08, 0.20, 0.06, 0.78))
	draw_circle(p + Vector2(30, -36), 30.0, Color(0.08, 0.20, 0.06, 0.78))
	draw_rect(Rect2(p.x - 13, p.y - 50, 26, 72), Color(0.38, 0.22, 0.10, 0.90))
	draw_rect(Rect2(p.x - 5, p.y - 52, 10, 70), Color(0.58, 0.34, 0.14, 0.70))
	draw_circle(p + Vector2(0, 20), 18.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.18))
	draw_rect(Rect2(p.x - 18, p.y + 12, 36, 18), Color(0.50, 0.28, 0.10, 0.92))
	draw_rect(Rect2(p.x - 14, p.y + 8, 28, 7), Color(0.86, 0.62, 0.18, 0.92))

func _draw_water_ribbon(pts: PackedVector2Array, width: float, dark: Color, light: Color) -> void:
	var shadow := PackedVector2Array()
	for p: Vector2 in pts:
		shadow.append(p + Vector2(4, 5))
	draw_polyline(shadow, Color(0.0, 0.0, 0.0, 0.28), width + 8.0, true)
	draw_polyline(pts, dark, width, true)
	draw_polyline(pts, light, width * 0.58, true)
	draw_polyline(pts, Color(0.78, 0.94, 1.0, 0.34), 3.0, true)

func _segment_points(level_id: int, bend: float, count: int) -> PackedVector2Array:
	var a: Vector2 = Vector2(240.0, CANVAS_H)
	if level_id > 1:
		a = NODE_POS_ALL[level_id - 2]
	var b: Vector2 = NODE_POS_ALL[level_id - 1]
	var pts := PackedVector2Array()
	for i in range(count):
		var t: float = float(i) / max(1.0, float(count - 1))
		var p: Vector2 = a.lerp(b, t)
		p.x += sin(t * PI) * bend
		pts.append(p)
	return pts

func _node_pos(level_id: int) -> Vector2:
	return NODE_POS_ALL[level_id - 1]

func _draw_paw_print(p: Vector2, col: Color) -> void:
	draw_circle(p, 3.8, col)
	draw_circle(p + Vector2(-4, -4), 1.9, col)
	draw_circle(p + Vector2(0, -5), 2.0, col.lightened(0.08))
	draw_circle(p + Vector2(4, -4), 1.9, col)

func _draw_guide_post(p: Vector2, text: String) -> void:
	draw_rect(Rect2(p.x - 2, p.y - 2, 4, 34), Color(0.28, 0.16, 0.06, 0.92))
	draw_rect(Rect2(p.x - 26, p.y - 20, 52, 18), Color(0.42, 0.25, 0.08, 0.92))
	draw_rect(Rect2(p.x - 24, p.y - 18, 48, 14), Color(0.72, 0.50, 0.18, 0.72))
	draw_rect(Rect2(p.x - 28, p.y - 22, 56, 3), Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.66))
	var font := get_theme_default_font()
	if font != null:
		draw_string(font, p + Vector2(-20, -8), text, HORIZONTAL_ALIGNMENT_CENTER, 40.0, 8,
			Color(0.08, 0.04, 0.01, 0.90))

func _draw_leaf_pair(p: Vector2, col: Color, flip: bool = false) -> void:
	var sx := -1.0 if flip else 1.0
	draw_polygon(PackedVector2Array([
		p,
		p + Vector2(12.0 * sx, -7.0),
		p + Vector2(6.0 * sx, 3.0),
	]), PackedColorArray([col, col.lightened(0.10), col.darkened(0.10)]))
	draw_polygon(PackedVector2Array([
		p + Vector2(2.0 * sx, 1.0),
		p + Vector2(13.0 * sx, 6.0),
		p + Vector2(5.0 * sx, 8.0),
	]), PackedColorArray([col.darkened(0.06), col.lightened(0.08), col.darkened(0.14)]))

func _draw_marker_halos() -> void:
	for i in range(TOTAL_LEVELS):
		var level_id    := i + 1
		var p: Vector2  = NODE_POS_ALL[i]
		var unlocked    := SaveManager.is_level_unlocked(level_id)
		var stars       := SaveManager.get_stars(level_id)
		var needs_shoes := level_id == 6 and unlocked and not SaveManager.has_upgrade("sand_shoes")
		var col: Color  = _level_badge_color(level_id).lerp(LEVEL_INFO[level_id - 1]["color"], 0.35)
		const R         := 44.0

		# Animated glow pulse for next playable level
		if unlocked and stars == 0 and not needs_shoes:
			var ga: float = 0.15 + 0.11 * absf(sin(_shimmer_t * 1.1))
			draw_circle(p, R + 22.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, ga))
			draw_circle(p, R + 14.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, ga * 0.55))

		# Drop shadow
		draw_circle(p + Vector2(4.0, 5.5), R + 8.0, Color(0.0, 0.0, 0.0, 0.60))

		# Outermost brass / tarnished ring
		if unlocked:
			draw_circle(p, R + 7.0, Color(0.50, 0.35, 0.11))
		else:
			draw_circle(p, R + 7.0, Color(0.20, 0.15, 0.08))

		# Outer dark groove
		draw_circle(p, R + 4.5, Color(0.04, 0.03, 0.01))

		# Gold or dim second ring
		if unlocked:
			draw_circle(p, R + 2.5, C_GOLD)
		else:
			draw_circle(p, R + 2.5, Color(0.28, 0.22, 0.10))

		# Thin dark separator
		draw_circle(p, R + 0.5, Color(0.06, 0.04, 0.01))

		# Narrow inner accent ring
		if unlocked:
			draw_circle(p, R - 1.5, C_GOLD.darkened(0.30))
		else:
			draw_circle(p, R - 1.5, Color(0.18, 0.14, 0.07))

		# Inner groove
		draw_circle(p, R - 3.5, Color(0.05, 0.04, 0.01))

		# Inner fill
		if not unlocked:
			draw_circle(p, R - 5.0, Color(0.10, 0.10, 0.10, 0.97))
		else:
			draw_circle(p, R - 5.0, col.darkened(0.38))
			draw_circle(p + Vector2(-6.0, -8.0), R * 0.38,
				col.lightened(0.22).lerp(Color.WHITE, 0.20) * Color(1.0, 1.0, 1.0, 0.18))

	# Decorative underline accents beside level name labels
	for i in range(TOTAL_LEVELS):
		var p: Vector2  = NODE_POS_ALL[i]
		const R         := 44.0
		var right_side  := p.x < 248.0
		var uy          := p.y + 13.0
		var line_col    := Color(0.65, 0.52, 0.22, 0.68)
		if right_side:
			var lx := p.x + R + 16.0
			draw_line(Vector2(lx, uy), Vector2(lx + 86.0, uy), line_col, 1.0, true)
		else:
			var rx := p.x - R - 16.0
			draw_line(Vector2(rx - 86.0, uy), Vector2(rx, uy), line_col, 1.0, true)

# ── BUILD: bird labels ────────────────────────────────────────────────────────
func _build_bird_labels() -> void:
	_bird1 = _mk_bird(Vector2(_bird1_x, 268.0))
	_bird2 = _mk_bird(Vector2(_bird2_x, 392.0))

func _mk_bird(pos: Vector2) -> Label:
	var l := Label.new()
	l.text = "—•—"
	l.add_theme_font_size_override("font_size", 7)
	l.add_theme_color_override("font_color", Color(0.28, 0.24, 0.16, 0.80))
	l.size = Vector2(28, 12)
	l.position = pos
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

# zone labels replaced by per-node labels in _add_marker

# ── BUILD: level markers ──────────────────────────────────────────────────────
func _build_level_markers() -> void:
	for i in range(TOTAL_LEVELS):
		_add_marker(i + 1)

func _add_marker(level_id: int) -> void:
	var pos: Vector2     = NODE_POS_ALL[level_id - 1]
	var unlocked         := SaveManager.is_level_unlocked(level_id)
	var stars            := SaveManager.get_stars(level_id)
	var needs_shoes      := level_id == 6 and unlocked and not SaveManager.has_upgrade("sand_shoes")
	const R              := 44

	# Transparent hit-area button — visual drawn entirely by _draw_marker_halos
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(R * 2 + 14, R * 2 + 14)
	btn.size                = Vector2(R * 2 + 14, R * 2 + 14)
	btn.position            = pos - Vector2(R + 7.0, R + 7.0)
	btn.flat                = true
	btn.focus_mode          = Control.FOCUS_NONE
	var sf_empty            := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal",  sf_empty)
	btn.add_theme_stylebox_override("hover",   sf_empty)
	btn.add_theme_stylebox_override("pressed", sf_empty)
	btn.add_theme_stylebox_override("focus",   sf_empty)
	_marker_layer.add_child(btn)

	# Centre label — level number or icon
	var num_lbl := Label.new()
	if needs_shoes:
		num_lbl.text = "👟"
		num_lbl.add_theme_font_size_override("font_size", 24)
		num_lbl.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	elif not unlocked:
		num_lbl.text = "🔒"
		num_lbl.add_theme_font_size_override("font_size", 22)
		num_lbl.add_theme_color_override("font_color", Color(0.40, 0.38, 0.32))
	else:
		num_lbl.text = str(level_id)
		num_lbl.add_theme_font_size_override("font_size", 28)
		num_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	num_lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	num_lbl.add_theme_constant_override("shadow_offset_x", 1)
	num_lbl.add_theme_constant_override("shadow_offset_y", 2)
	num_lbl.size         = Vector2(R * 2.0 - 10.0, R * 2.0 - 10.0)
	num_lbl.position     = pos - Vector2(R - 5.0, R - 5.0)
	num_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marker_layer.add_child(num_lbl)

	# Stars below the circle (unlocked levels only)
	if unlocked and not needs_shoes:
		var star_lbl := Label.new()
		if stars > 0:
			star_lbl.text = "★".repeat(stars) + "☆".repeat(3 - stars)
			star_lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.18))
			star_lbl.add_theme_font_size_override("font_size", 17)
		else:
			star_lbl.text = "☆  ☆  ☆"
			star_lbl.add_theme_color_override("font_color", Color(0.56, 0.52, 0.42))
			star_lbl.add_theme_font_size_override("font_size", 15)
		star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star_lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.80))
		star_lbl.add_theme_constant_override("shadow_offset_x", 1)
		star_lbl.add_theme_constant_override("shadow_offset_y", 1)
		star_lbl.size         = Vector2(R * 2 + 14, 24)
		star_lbl.position     = pos + Vector2(-(R + 7.0), R + 7.0)
		star_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_marker_layer.add_child(star_lbl)

	# Level name label — beside node; left side when node is on right half of screen
	var label_right := pos.x < 248.0
	var name_lbl    := Label.new()
	name_lbl.text   = _level_marker_title(level_id).to_upper()
	var marker_font_size: int = 10 if name_lbl.text.length() > 18 or name_lbl.text.find("\n") >= 0 else 12
	name_lbl.add_theme_font_size_override("font_size", marker_font_size)
	name_lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	name_lbl.add_theme_constant_override("shadow_offset_x", 1)
	name_lbl.add_theme_constant_override("shadow_offset_y", 1)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if unlocked:
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.97, 0.90))
	else:
		name_lbl.add_theme_color_override("font_color", Color(0.82, 0.78, 0.70, 0.90))
	if label_right:
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_lbl.size     = Vector2(150, 36)
		name_lbl.position = pos + Vector2(R + 16.0, -22.0)
	else:
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		name_lbl.size     = Vector2(140, 36)
		name_lbl.position = pos + Vector2(-R - 156.0, -22.0)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marker_layer.add_child(name_lbl)

	_add_mode_badge(level_id, pos, label_right, _marker_layer)

	# Sand Shoes badge for Level 6
	if level_id == 6:
		_add_shoes_badge(pos, label_right, _marker_layer)

	if unlocked:
		btn.pressed.connect(_on_marker.bind(level_id))

# ── BUILD: UI overlay ─────────────────────────────────────────────────────────
func _build_ui_overlay() -> void:

	# ── Header ──
	var hdr := ColorRect.new()
	hdr.color        = Color(0.02, 0.02, 0.02, 0.95)
	hdr.size         = Vector2(480, 68)
	hdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hdr)

	var hdr_line := ColorRect.new()
	hdr_line.color    = Color(0.70, 0.55, 0.18, 0.90)
	hdr_line.size     = Vector2(480, 2)
	hdr_line.position = Vector2(0, 68)
	hdr_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hdr_line)

	# Back button — rounded dark box
	var btn_back := Button.new()
	btn_back.text             = "←"
	btn_back.custom_minimum_size = Vector2(52, 44)
	btn_back.position         = Vector2(8, 12)
	btn_back.focus_mode       = Control.FOCUS_NONE
	btn_back.add_theme_font_size_override("font_size", 22)
	btn_back.add_theme_color_override("font_color", Color(0.92, 0.82, 0.30))
	var sb_back := StyleBoxFlat.new()
	sb_back.bg_color             = Color(0.08, 0.07, 0.05, 0.90)
	sb_back.border_color         = Color(0.50, 0.38, 0.14)
	sb_back.border_width_left    = 2; sb_back.border_width_right  = 2
	sb_back.border_width_top     = 2; sb_back.border_width_bottom = 2
	sb_back.corner_radius_top_left     = 10
	sb_back.corner_radius_top_right    = 10
	sb_back.corner_radius_bottom_left  = 10
	sb_back.corner_radius_bottom_right = 10
	btn_back.add_theme_stylebox_override("normal",  sb_back)
	var sb_back_h             := sb_back.duplicate() as StyleBoxFlat
	sb_back_h.bg_color        = Color(0.14, 0.12, 0.08, 0.95)
	btn_back.add_theme_stylebox_override("hover",   sb_back_h)
	btn_back.add_theme_stylebox_override("pressed", sb_back)
	btn_back.pressed.connect(_on_back)
	add_child(btn_back)

	# Title
	var title := Label.new()
	title.text = "THE EXPEDITION  ·  20 LEVELS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.size         = Vector2(258, 48)
	title.position     = Vector2(68, 10)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)
	title.text = "JUNGLE MAP"
	title.add_theme_font_size_override("font_size", 24)
	title.size = Vector2(242, 36)
	title.position = Vector2(72, 5)

	var subtitle := Label.new()
	subtitle.text = "20 LEVEL EXPEDITION"
	if SaveManager.should_show_lives():
		subtitle.text = "20 LEVELS  -  LIFE " + SaveManager.get_lives_display()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 9)
	subtitle.add_theme_color_override("font_color", Color(0.68, 0.88, 0.46))
	subtitle.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.70))
	subtitle.add_theme_constant_override("shadow_offset_x", 1)
	subtitle.add_theme_constant_override("shadow_offset_y", 1)
	subtitle.size         = Vector2(242, 18)
	subtitle.position     = Vector2(72, 42)
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(subtitle)

	# Coins pill container
	var coins_bg := Panel.new()
	coins_bg.position     = Vector2(328, 14)
	coins_bg.size         = Vector2(96, 40)
	coins_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb_coin := StyleBoxFlat.new()
	sb_coin.bg_color            = Color(0.08, 0.06, 0.02, 0.92)
	sb_coin.border_color        = Color(0.70, 0.55, 0.18, 0.95)
	sb_coin.border_width_left   = 2; sb_coin.border_width_right  = 2
	sb_coin.border_width_top    = 2; sb_coin.border_width_bottom = 2
	sb_coin.corner_radius_top_left     = 20
	sb_coin.corner_radius_top_right    = 20
	sb_coin.corner_radius_bottom_left  = 20
	sb_coin.corner_radius_bottom_right = 20
	coins_bg.add_theme_stylebox_override("panel", sb_coin)
	add_child(coins_bg)

	var coins_lbl := Label.new()
	coins_lbl.text = "🪙 " + str(SaveManager.get_coins())
	coins_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	coins_lbl.add_theme_font_size_override("font_size", 14)
	coins_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.24))
	coins_lbl.size         = Vector2(96, 40)
	coins_lbl.position     = Vector2(328, 14)
	coins_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(coins_lbl)

	# "+" add-coins button
	var btn_plus := Button.new()
	btn_plus.text             = "+"
	btn_plus.custom_minimum_size = Vector2(36, 40)
	btn_plus.position         = Vector2(430, 14)
	btn_plus.focus_mode       = Control.FOCUS_NONE
	btn_plus.add_theme_font_size_override("font_size", 22)
	btn_plus.add_theme_color_override("font_color", Color(0.05, 0.02, 0.01))
	var sb_plus := StyleBoxFlat.new()
	sb_plus.bg_color            = Color(0.82, 0.62, 0.14)
	sb_plus.border_width_left   = 0; sb_plus.border_width_right  = 0
	sb_plus.border_width_top    = 0; sb_plus.border_width_bottom = 0
	sb_plus.corner_radius_top_left     = 20
	sb_plus.corner_radius_top_right    = 20
	sb_plus.corner_radius_bottom_left  = 20
	sb_plus.corner_radius_bottom_right = 20
	btn_plus.add_theme_stylebox_override("normal",  sb_plus)
	var sb_plus_h        := sb_plus.duplicate() as StyleBoxFlat
	sb_plus_h.bg_color   = Color(0.96, 0.76, 0.20)
	btn_plus.add_theme_stylebox_override("hover",   sb_plus_h)
	btn_plus.add_theme_stylebox_override("pressed", sb_plus)
	btn_plus.pressed.connect(func() -> void: GameManager.go_to_upgrade_shop())
	add_child(btn_plus)

	# ── Bottom bar ──
	var bot := ColorRect.new()
	bot.color        = Color(0.02, 0.02, 0.02, 0.92)
	bot.size         = Vector2(480, 36)
	bot.position     = Vector2(0, 818)
	bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bot)

	var bot_line := ColorRect.new()
	bot_line.color    = Color(0.68, 0.52, 0.18, 0.70)
	bot_line.size     = Vector2(480, 1)
	bot_line.position = Vector2(0, 818)
	bot_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bot_line)

	var obj := Label.new()
	obj.text = "✦  Swipe up to explore  •  Tap a level to begin the expedition  ✦"
	obj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	obj.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	obj.add_theme_font_size_override("font_size", 9)
	obj.add_theme_color_override("font_color", Color(0.76, 0.90, 0.60, 0.92))
	obj.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.70))
	obj.add_theme_constant_override("shadow_offset_x", 1)
	obj.add_theme_constant_override("shadow_offset_y", 1)
	obj.size         = Vector2(480, 36)
	obj.position     = Vector2(0, 818)
	obj.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(obj)
	obj.text = "Follow the Lost Path  -  Tap a level to preview and start"


# ── BUILD: preview panel ──────────────────────────────────────────────────────
func _build_preview_panel() -> void:
	_preview_panel = Control.new()
	_preview_panel.size     = Vector2(480, 284)
	_preview_panel.position = Vector2(0, 538)
	_preview_panel.visible  = false
	add_child(_preview_panel)

	# Parchment-style background
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.07, 0.03, 0.97)
	bg.size = Vector2(480, 284); bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(bg)
	# Top accent line
	var acc := ColorRect.new()
	acc.color = Color(0.70, 0.54, 0.18, 0.90)
	acc.size = Vector2(480, 2); acc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(acc)
	# Corner ornaments
	for d: Array in [[Vector2(0,0),Vector2(18,3)],[Vector2(0,0),Vector2(3,18)],
					 [Vector2(459,0),Vector2(21,3)],[Vector2(477,0),Vector2(3,18)]]:
		var c := ColorRect.new()
		c.color = C_GOLD; c.position = d[0]; c.size = d[1]
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_preview_panel.add_child(c)

	_label(_preview_panel, "ChapterLbl", Vector2(20,  10), Vector2(440, 20), 11, Color(0.56, 0.80, 0.44))
	_label(_preview_panel, "NameLbl",    Vector2(20,  32), Vector2(440, 38), 22, Color(0.96, 0.90, 0.58))
	_label(_preview_panel, "StarsLbl",   Vector2(20,  72), Vector2(440, 28), 18, Color(1.00, 0.82, 0.18))
	_label(_preview_panel, "ModeLbl",    Vector2(22, 100), Vector2(436, 20), 10, Color(0.96, 0.72, 0.26))
	_label(_preview_panel, "DescLbl",    Vector2(22, 124), Vector2(436, 58), 13, Color(0.80, 0.88, 0.70))
	(_preview_panel.get_node("DescLbl") as Label).autowrap_mode = TextServer.AUTOWRAP_WORD
	var div := ColorRect.new()
	div.color = Color(0.40, 0.30, 0.12, 0.50)
	div.size = Vector2(436, 1); div.position = Vector2(22, 188)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(div)
	_label(_preview_panel, "RewardsLbl", Vector2(20, 192), Vector2(440, 22), 11, Color(0.68, 0.64, 0.42))

	var btn_start := Button.new()
	btn_start.name = "BtnStart"
	btn_start.text = "▶  Start Expedition"
	btn_start.custom_minimum_size = Vector2(222, 52)
	btn_start.position = Vector2(14, 220)
	btn_start.add_theme_font_size_override("font_size", 16)
	btn_start.pressed.connect(_on_start)
	_preview_panel.add_child(btn_start)

	var btn_close := Button.new()
	btn_close.name = "BtnClose"
	btn_close.text = "✕  Back"
	btn_close.custom_minimum_size = Vector2(170, 52)
	btn_close.position = Vector2(252, 220)
	btn_close.add_theme_font_size_override("font_size", 16)
	btn_close.pressed.connect(_hide_preview)
	_preview_panel.add_child(btn_close)

# ── BUILD: sand shoes popup ───────────────────────────────────────────────────
func _build_sand_shoes_popup() -> void:
	_sand_popup = Control.new()
	_sand_popup.size     = Vector2(420, 338)
	_sand_popup.position = Vector2(30, 258)
	_sand_popup.visible  = false
	add_child(_sand_popup)

	_cr(_sand_popup, Vector2(0,   0), Vector2(420, 338), Color(0.08, 0.06, 0.02, 0.97))
	_cr(_sand_popup, Vector2(0,   0), Vector2(420,   3), Color(0.88, 0.70, 0.22))
	_cr(_sand_popup, Vector2(0, 335), Vector2(420,   3), Color(0.88, 0.70, 0.22))

	var icon := Label.new()
	icon.text = "👟"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 42)
	icon.size = Vector2(420, 62); icon.position = Vector2(0, 14)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sand_popup.add_child(icon)

	var title := Label.new()
	title.text = "Sand Shoes Required"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	title.size = Vector2(420, 32); title.position = Vector2(0, 80)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sand_popup.add_child(title)

	var desc := Label.new()
	desc.name = "SandDesc"
	desc.text = "The path ahead is covered in deep sand.\nBuy Sand Shoes from the expedition supply shop to walk, jump, and continue.\n\nCost: 150 Coins"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.86, 0.82, 0.68))
	desc.size = Vector2(380, 96); desc.position = Vector2(20, 118)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sand_popup.add_child(desc)

	var btn_buy := Button.new()
	btn_buy.text = "👟  Buy Sand Shoes"
	btn_buy.custom_minimum_size = Vector2(200, 46)
	btn_buy.position = Vector2(16, 228)
	btn_buy.add_theme_font_size_override("font_size", 15)
	btn_buy.pressed.connect(_on_buy_sand_shoes)
	_sand_popup.add_child(btn_buy)

	var btn_close := Button.new()
	btn_close.text = "✕  Back"
	btn_close.custom_minimum_size = Vector2(152, 46)
	btn_close.position = Vector2(230, 228)
	btn_close.add_theme_font_size_override("font_size", 15)
	btn_close.pressed.connect(func() -> void: _sand_popup.visible = false)
	_sand_popup.add_child(btn_close)

	var btn_shop := Button.new()
	btn_shop.text = "🛒  Open Upgrade Shop"
	btn_shop.custom_minimum_size = Vector2(390, 38)
	btn_shop.position = Vector2(15, 284)
	btn_shop.add_theme_font_size_override("font_size", 13)
	btn_shop.pressed.connect(func() -> void: GameManager.go_to_upgrade_shop())
	_sand_popup.add_child(btn_shop)

# ── LOGIC ─────────────────────────────────────────────────────────────────────
func _build_lives_popup() -> void:
	_lives_popup = Control.new()
	_lives_popup.size = Vector2(420, 402)
	_lives_popup.position = Vector2(30, 224)
	_lives_popup.visible = false
	add_child(_lives_popup)

	_cr(_lives_popup, Vector2(0, 0), Vector2(420, 402), Color(0.05, 0.03, 0.02, 0.98))
	_cr(_lives_popup, Vector2(0, 0), Vector2(420, 3), Color(0.88, 0.70, 0.22))
	_cr(_lives_popup, Vector2(0, 399), Vector2(420, 3), Color(0.88, 0.70, 0.22))

	var icon := Label.new()
	icon.text = "LIFE"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 28)
	icon.add_theme_color_override("font_color", Color(1.0, 0.42, 0.34))
	icon.size = Vector2(420, 42)
	icon.position = Vector2(0, 14)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lives_popup.add_child(icon)

	var title := Label.new()
	title.text = "No Lives Left"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	title.size = Vector2(420, 34)
	title.position = Vector2(0, 58)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lives_popup.add_child(title)

	var desc := Label.new()
	desc.name = "LivesDesc"
	desc.text = "The jungle is dangerous. Rest at camp or recover a life to continue your expedition."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.86, 0.82, 0.68))
	desc.size = Vector2(382, 54)
	desc.position = Vector2(19, 98)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lives_popup.add_child(desc)

	var status := Label.new()
	status.name = "LivesStatus"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 12)
	status.add_theme_color_override("font_color", Color(0.68, 0.88, 0.52))
	status.size = Vector2(382, 46)
	status.position = Vector2(19, 154)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lives_popup.add_child(status)

	_lives_button("BtnCoinLife", "Use 50 Coins", Vector2(24, 210), Vector2(174, 42), _on_buy_life_coin)
	_lives_button("BtnGemLife", "Use 1 Gem", Vector2(222, 210), Vector2(174, 42), _on_buy_life_gem)
	_lives_button("BtnFullCoinLife", "Full 200 Coins", Vector2(24, 260), Vector2(174, 38), _on_buy_full_lives_coin)
	_lives_button("BtnFullGemLife", "Full 4 Gems", Vector2(222, 260), Vector2(174, 38), _on_buy_full_lives_gem)
	var ad_btn := _lives_button("BtnAdLife", "Watch Ad for +1 Life", Vector2(24, 308), Vector2(174, 42), _on_reward_ad_life)
	ad_btn.disabled = true
	var camp_btn := _lives_button("BtnCamp", "Return to Camp", Vector2(222, 308), Vector2(174, 42), _on_return_to_camp)
	camp_btn.add_theme_color_override("font_color", Color(0.96, 0.90, 0.70))
	var close_btn := _lives_button("BtnCloseLives", "Back", Vector2(124, 360), Vector2(172, 30), func() -> void: _lives_popup.visible = false)
	close_btn.add_theme_font_size_override("font_size", 12)

func _lives_button(node_name: String, text: String, pos: Vector2, box_size: Vector2, callback: Callable) -> Button:
	var btn := Button.new()
	btn.name = node_name
	btn.text = text
	btn.custom_minimum_size = box_size
	btn.position = pos
	btn.add_theme_font_size_override("font_size", 13)
	btn.pressed.connect(callback)
	_lives_popup.add_child(btn)
	return btn

func _show_preview(level_id: int) -> void:
	_current_preview = level_id
	var info: Dictionary = LEVEL_INFO[level_id - 1]
	var stars            := SaveManager.get_stars(level_id)
	(_preview_panel.get_node("ChapterLbl") as Label).text = info["chapter"] + "  ·  " + info["area"]
	(_preview_panel.get_node("NameLbl") as Label).text    = "Level " + str(level_id) + "  —  " + info["name"]
	(_preview_panel.get_node("ChapterLbl") as Label).text = info["chapter"] + "  -  " + _level_area(level_id)
	(_preview_panel.get_node("NameLbl") as Label).text    = "Level " + str(level_id) + "  -  " + _level_title(level_id)
	(_preview_panel.get_node("ModeLbl") as Label).text    = _level_badge(level_id) + " ROUTE"
	var sl := _preview_panel.get_node("StarsLbl") as Label
	if stars > 0:
		sl.text = "★".repeat(stars) + "☆".repeat(3 - stars)
		sl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.18))
	else:
		sl.text = "Not yet completed  ☆ ☆ ☆"
		sl.add_theme_color_override("font_color", Color(0.55, 0.52, 0.40))
	(_preview_panel.get_node("DescLbl") as Label).text    = info["desc"]
	(_preview_panel.get_node("RewardsLbl") as Label).text = "Rewards: " + info["rewards"]
	(_preview_panel.get_node("DescLbl") as Label).text    = _level_desc(level_id)
	(_preview_panel.get_node("RewardsLbl") as Label).text = "Rewards: " + _level_rewards(level_id)
	_preview_panel.visible = true

func _hide_preview() -> void:
	_preview_panel.visible = false
	_current_preview = 0

func _on_marker(level_id: int) -> void:
	EventBus.play_sfx.emit("button")
	if level_id == 6 and not SaveManager.has_upgrade("sand_shoes"):
		_sand_popup.visible = true
		return
	_show_preview(level_id)

func _show_no_lives_popup(message: String = "") -> void:
	if _lives_popup == null:
		return
	_update_lives_popup(message)
	_lives_popup.visible = true

func _update_lives_popup(message: String = "") -> void:
	if _lives_popup == null:
		return
	var status := _lives_popup.get_node("LivesStatus") as Label
	var text := "Expedition Lives: " + SaveManager.get_lives_display()
	var remaining := SaveManager.get_life_regen_seconds_remaining()
	if remaining > 0 and SaveManager.get_lives() < SaveManager.get_max_lives():
		text += "\nNext recovery in " + _format_life_time(remaining)
	if message != "":
		text += "\n" + message
	status.text = text

	var lives_full := SaveManager.get_lives() >= SaveManager.get_max_lives()
	(_lives_popup.get_node("BtnCoinLife") as Button).disabled = lives_full or SaveManager.get_coins() < SaveManager.LIFE_COIN_COST
	(_lives_popup.get_node("BtnGemLife") as Button).disabled = lives_full or SaveManager.get_gems() < SaveManager.LIFE_GEM_COST
	(_lives_popup.get_node("BtnFullCoinLife") as Button).disabled = lives_full or SaveManager.get_coins() < SaveManager.FULL_LIFE_COIN_COST
	(_lives_popup.get_node("BtnFullGemLife") as Button).disabled = lives_full or SaveManager.get_gems() < SaveManager.FULL_LIFE_GEM_COST
	(_lives_popup.get_node("BtnAdLife") as Button).disabled = true

func _format_life_time(seconds: int) -> String:
	var minutes := int(seconds / 60)
	var secs := seconds % 60
	return "%02d:%02d" % [minutes, secs]

func _on_buy_life_coin() -> void:
	EventBus.play_sfx.emit("button")
	var ok := SaveManager.buy_life_with_coins()
	_update_lives_popup("Recovered 1 life." if ok else "Not enough coins, or lives are already full.")
	queue_redraw()

func _on_buy_life_gem() -> void:
	EventBus.play_sfx.emit("button")
	var ok := SaveManager.buy_life_with_gems()
	_update_lives_popup("Recovered 1 life." if ok else "Not enough gems, or lives are already full.")
	queue_redraw()

func _on_buy_full_lives_coin() -> void:
	EventBus.play_sfx.emit("button")
	var ok := SaveManager.buy_full_lives_with_coins()
	_update_lives_popup("Expedition Lives refilled." if ok else "Not enough coins, or lives are already full.")
	queue_redraw()

func _on_buy_full_lives_gem() -> void:
	EventBus.play_sfx.emit("button")
	var ok := SaveManager.buy_full_lives_with_gems()
	_update_lives_popup("Expedition Lives refilled." if ok else "Not enough gems, or lives are already full.")
	queue_redraw()

func _on_reward_ad_life() -> void:
	_update_lives_popup("Reward ads coming soon.")

func _on_return_to_camp() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

func _on_start() -> void:
	if _current_preview > 0:
		EventBus.play_sfx.emit("button")
		if not SaveManager.can_start_level(_current_preview):
			_show_no_lives_popup()
			return
		GameManager.go_to_gameplay_3d(_current_preview)

func _on_buy_sand_shoes() -> void:
	EventBus.play_sfx.emit("button")
	if SaveManager.buy_upgrade("sand_shoes"):
		_sand_popup.visible = false
		queue_redraw()
		_show_preview(6)
	else:
		var desc := _sand_popup.get_node("SandDesc") as Label
		desc.text = "Not enough coins!\n\nNeeded: 150 Coins\n\nReplay earlier levels to collect more coins."

func _on_back() -> void:
	if _lives_popup != null and _lives_popup.visible:
		_lives_popup.visible = false; return
	if _sand_popup != null and _sand_popup.visible:
		_sand_popup.visible = false; return
	if _preview_panel != null and _preview_panel.visible:
		_hide_preview(); return
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

# ── HELPERS ───────────────────────────────────────────────────────────────────
func _build_reference_hit_targets() -> void:
	_reference_button(Rect2(10, 10, 58, 44)).pressed.connect(_on_back)
	_reference_button(Rect2(428, 12, 42, 44)).pressed.connect(_on_reference_plus)

func _on_reference_plus() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_upgrade_shop()

func _reference_button(rect: Rect2) -> Button:
	var btn := Button.new()
	btn.text = ""
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.position = rect.position
	btn.size = rect.size
	btn.custom_minimum_size = rect.size
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("hover", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("focus", empty)
	add_child(btn)
	return btn

func _load_map_texture() -> Texture2D:
	if ResourceLoader.exists(MAP_ART_PATH):
		var tex := load(MAP_ART_PATH)
		if tex is Texture2D:
			return tex as Texture2D

	var img := Image.new()
	if img.load(MAP_ART_PATH) == OK:
		return ImageTexture.create_from_image(img)
	return null

func _using_reference_map() -> bool:
	return false  # full 2460-px scrollable canvas always uses procedural drawing

func _level_title(level_id: int) -> String:
	match level_id:
		1: return "Jungle Trail Entrance"
		2: return "Deep Forest Bend"
		4: return "Ancient Ruins Corridor"
		10: return "Lost Paw Trail"
		12: return "Water Slide Trail"
		13: return "Park Guide Path"
		15: return "Market River Dock"
		17: return "Rapids Run"
		18: return "Hound of the Hidden Trail"
		19: return "Boar Escape"
		20: return "Treasure Beneath the Baobab"
		_: return LEVEL_INFO[level_id - 1]["name"]

func _level_area(level_id: int) -> String:
	match level_id:
		12: return "Water Slide Channel"
		15: return "River Dock"
		17: return "Rapids Fork"
		19: return "Survival Escape Route"
		20: return "Ancient Baobab"
		_: return LEVEL_INFO[level_id - 1]["area"]

func _level_marker_title(level_id: int) -> String:
	match level_id:
		1: return "Jungle\nTrail"
		2: return "Deep Forest"
		4: return "Ancient\nRuins"
		10: return "Lost Paw\nTrail"
		12: return "Water Slide\nTrail"
		13: return "Park Guide\nPath"
		15: return "River Dock"
		17: return "Rapids Run"
		18: return "Hidden\nHound Trail"
		19: return "Boar Escape"
		20: return "Baobab\nTreasure"
		_: return _level_title(level_id)

func _level_desc(level_id: int) -> String:
	match level_id:
		10:
			return "Muddy pawprints mark the correct path. Read the clues and choose the dog-token route."
		12:
			return "A blue water-slide channel drops through the jungle. Steer through rocks, logs, and spray."
		13:
			return "Moyo guides the route through wildlife markers, observation points, and a safe junction."
		15:
			return "The market trail reaches a river dock. Dodge crates, collect trade tokens, and enter the boat."
		17:
			return "Full boat mode through rapids, floating logs, crocodile danger zones, and a forked river."
		18:
			return "A hound scouts hidden footprints through mist, false paths, relic markers, and a 3-way choice."
		19:
			return "A high-pressure boar escape through mud, thorns, fallen branches, and a raised safe finish."
		20:
			return "The final route mixes chase, water slide, boat bends, treasure junctions, ruins, and the baobab."
		_: return LEVEL_INFO[level_id - 1]["desc"]

func _level_rewards(level_id: int) -> String:
	match level_id:
		12: return "Coins  -  Water Tokens  -  Fish Token  -  Food"
		15: return "Coins  -  Trade Tokens  -  Windows  -  Tiles  -  Fish Token"
		17: return "Coins  -  River Relic  -  Fish Token  -  Sunstone Shard"
		19: return "Coins  -  Tools  -  Bricks  -  Tiles  -  Wood"
		20: return "Coins  -  Gems  -  Treasure  -  Sunstone Shard  -  Relic Key"
		_: return LEVEL_INFO[level_id - 1]["rewards"]

func _level_badge(level_id: int) -> String:
	match level_id:
		1, 2, 3, 4, 5, 6: return "TRAIL"
		7, 8, 9: return "BUILD"
		10, 14, 18: return "TRACK"
		11, 16: return "CHASE"
		12: return "SLIDE"
		13: return "GUIDE"
		15: return "DOCK"
		17: return "BOAT"
		19: return "ESCAPE"
		20: return "FINAL"
		_: return "RUN"

func _level_badge_color(level_id: int) -> Color:
	match _level_badge(level_id):
		"BUILD": return Color(0.68, 0.42, 0.14)
		"TRACK": return Color(0.34, 0.50, 0.20)
		"CHASE": return Color(0.84, 0.56, 0.12)
		"SLIDE": return Color(0.12, 0.58, 0.82)
		"GUIDE": return Color(0.55, 0.68, 0.24)
		"DOCK": return Color(0.24, 0.46, 0.62)
		"BOAT": return Color(0.10, 0.38, 0.58)
		"ESCAPE": return Color(0.72, 0.22, 0.08)
		"FINAL": return Color(0.86, 0.62, 0.14)
		_: return Color(0.28, 0.50, 0.18)

func _add_mode_badge(level_id: int, node_pos: Vector2, right_side: bool, parent: Node) -> void:
	const R := 44
	var badge := _level_badge(level_id)
	var col := _level_badge_color(level_id)
	var badge_size := Vector2(70, 18)
	var badge_pos: Vector2
	if right_side:
		badge_pos = node_pos + Vector2(R + 16.0, 16.0)
	else:
		badge_pos = node_pos + Vector2(-R - 86.0, 16.0)

	var panel := Panel.new()
	panel.position = badge_pos
	panel.size = badge_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(col.r, col.g, col.b, 0.72).darkened(0.34)
	sb.border_color = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.72)
	sb.border_width_left = 1; sb.border_width_right = 1
	sb.border_width_top = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left = 5
	sb.corner_radius_top_right = 5
	sb.corner_radius_bottom_left = 5
	sb.corner_radius_bottom_right = 5
	panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(panel)

	var lbl := Label.new()
	lbl.text = badge
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.58))
	lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.80))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.size = badge_size
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(lbl)

func _add_shoes_badge(node_pos: Vector2, right_side: bool, parent: Node) -> void:
	const R  := 44
	const BW := 124.0
	const BH := 36.0
	var badge_pos: Vector2
	if right_side:
		badge_pos = node_pos + Vector2(R + 16.0, 18.0)
	else:
		badge_pos = node_pos + Vector2(-R - BW - 16.0, 18.0)

	var badge := Panel.new()
	badge.position     = badge_pos
	badge.size         = Vector2(BW, BH)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color            = Color(0.06, 0.04, 0.02, 0.92)
	sb.border_color        = Color(0.68, 0.52, 0.18, 0.88)
	sb.border_width_left   = 1; sb.border_width_right  = 1
	sb.border_width_top    = 1; sb.border_width_bottom = 1
	sb.corner_radius_top_left     = 5
	sb.corner_radius_top_right    = 5
	sb.corner_radius_bottom_left  = 5
	sb.corner_radius_bottom_right = 5
	badge.add_theme_stylebox_override("panel", sb)
	parent.add_child(badge)

	var lbl := Label.new()
	lbl.text = "👟 SAND SHOES\n   REQUIRED"
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.size         = Vector2(BW, BH)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(lbl)

func _cr(parent: Node, pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos; r.size = size; r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r); return r

func _label(parent: Node, node_name: String, pos: Vector2, size: Vector2,
		font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.name = node_name; l.position = pos; l.size = size
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l); return l

func _anchor(world_pos: Vector2, size: Vector2) -> Control:
	var c := Control.new()
	c.size = size; c.position = world_pos - size * 0.5
	add_child(c); return c

# ── SCROLL ────────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if _preview_panel != null and _preview_panel.visible: return
	if _sand_popup    != null and _sand_popup.visible:    return
	if _lives_popup   != null and _lives_popup.visible:   return
	if event is InputEventScreenDrag:
		_scroll_by(-(event as InputEventScreenDrag).relative.y)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_scroll_by(-80.0)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_scroll_by(80.0)
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed and mb.position.y > 68.0 and mb.position.y < 820.0:
				_is_dragging = true
				_drag_start_y      = mb.position.y
				_drag_start_scroll = _scroll_y
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		var mm := event as InputEventMouseMotion
		_scroll_y = _drag_start_scroll - (mm.position.y - _drag_start_y)
		_clamp_scroll()
		_update_scroll()

func _scroll_by(delta: float) -> void:
	_scroll_y += delta
	_clamp_scroll()
	_update_scroll()

func _clamp_scroll() -> void:
	_scroll_y = clamp(_scroll_y, 0.0, SCROLL_MAX)

func _update_scroll() -> void:
	if _marker_layer != null:
		_marker_layer.position.y = 68.0 - _scroll_y
	queue_redraw()

# ── DRAW: scrollbar indicator ─────────────────────────────────────────────────
func _draw_scrollbar() -> void:
	const TRACK_X  := 472.0
	const TRACK_Y1 := 74.0
	const TRACK_H  := 740.0
	const THUMB_H  := 80.0
	# Track
	draw_rect(Rect2(TRACK_X, TRACK_Y1, 4.0, TRACK_H), Color(0.0, 0.0, 0.0, 0.30))
	# Thumb — position proportional to scroll
	var thumb_y := TRACK_Y1 + (TRACK_H - THUMB_H) * (_scroll_y / SCROLL_MAX)
	draw_rect(Rect2(TRACK_X, thumb_y, 4.0, THUMB_H), Color(0.70, 0.55, 0.18, 0.70))
	draw_rect(Rect2(TRACK_X + 1.0, thumb_y + 2.0, 2.0, THUMB_H - 4.0), Color(0.90, 0.76, 0.30, 0.50))
