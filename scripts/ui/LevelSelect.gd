extends Control

# ── Level data ────────────────────────────────────────────────────────────────
const TOTAL_LEVELS := 6

const LEVEL_INFO: Array = [
	{ "name": "Jungle Trail",      "chapter": "Chapter 1", "area": "Jungle Entrance",
	  "zone": "jungle",    "color": Color(0.18, 0.52, 0.12),
	  "desc": "Your expedition begins on a bright jungle trail. Collect coins and reach the finish gate.",
	  "rewards": "Coins  ·  Gems  ·  Map Piece" },
	{ "name": "Deep Forest",       "chapter": "Chapter 2", "area": "Deep Forest",
	  "zone": "jungle",    "color": Color(0.08, 0.34, 0.08),
	  "desc": "The trees grow taller. The path bends LEFT into darkness. Monkeys watch from the canopy.",
	  "rewards": "Coins  ·  Gems  ·  Sunstone Shard" },
	{ "name": "River of Echoes",   "chapter": "Chapter 3", "area": "River Crossing",
	  "zone": "river",     "color": Color(0.10, 0.30, 0.52),
	  "desc": "The Lost Path reaches a river that guards a Sunstone fragment. Turn RIGHT across the old bridge.",
	  "rewards": "Coins  ·  Wood  ·  Map Piece  ·  Sunstone Shard" },
	{ "name": "Ancient Ruins",     "chapter": "Chapter 4", "area": "Ancient Ruins",
	  "zone": "ruins",     "color": Color(0.34, 0.24, 0.10),
	  "desc": "Moss-covered pillars rise from the jungle. Ancient traps guard a glowing relic. Turn LEFT.",
	  "rewards": "Coins  ·  Relic Key  ·  Bricks  ·  Sunstone Shard" },
	{ "name": "Temple Approach",   "chapter": "Chapter 5", "area": "Temple Gates",
	  "zone": "ruins",     "color": Color(0.55, 0.42, 0.08),
	  "desc": "The Temple of the First Sun is near. The Sunstone Heart is within reach. Turn RIGHT.",
	  "rewards": "Coins  ·  Gems  ·  Map Piece  ·  Sunstone Shard" },
	{ "name": "Wildlands of Peace","chapter": "Chapter 6", "area": "Wildlands",
	  "zone": "wildlands", "color": Color(0.68, 0.54, 0.18),
	  "desc": "A sandy path opens into warm wildlands. Elephants roam in the distance. Sand Shoes required.",
	  "rewards": "Coins  ·  Wood  ·  Bricks  ·  Food  ·  Sunstone Shard" },
]

const NODE_POS: Array = [
	Vector2(148, 710), Vector2(318, 582), Vector2(132, 452),
	Vector2(322, 328), Vector2(162, 212), Vector2(300, 108),
]
const CAMP_POS   := Vector2(240, 812)
const TEMPLE_POS := Vector2(240, 66)

const PATH_PTS: Array = [
	Vector2(240, 814),
	Vector2(210, 780), Vector2(174, 748),
	Vector2(148, 728), Vector2(148, 710),
	Vector2(168, 672), Vector2(228, 635), Vector2(300, 600),
	Vector2(318, 582),
	Vector2(288, 544), Vector2(224, 510), Vector2(152, 474),
	Vector2(132, 452),
	Vector2(148, 414), Vector2(210, 376), Vector2(298, 344),
	Vector2(322, 328),
	Vector2(286, 292), Vector2(224, 258), Vector2(178, 230),
	Vector2(162, 212),
	Vector2(176, 180), Vector2(218, 150), Vector2(268, 124),
	Vector2(300, 108),
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
var _bird1           : Label   = null
var _bird2           : Label   = null
var _bird1_x         : float   = -28.0
var _bird2_x         : float   = 510.0
var _shimmer_t       : float   = 0.0

# ── SETUP ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_rng.seed = 4419
	_build_bird_labels()
	_build_zone_labels()
	_build_level_markers()
	_build_ui_overlay()
	_build_preview_panel()
	_build_sand_shoes_popup()
	queue_redraw()

func _process(delta: float) -> void:
	_shimmer_t += delta * 1.25
	_bird1_x   += delta * 52.0
	_bird2_x   -= delta * 40.0
	if _bird1_x >  528.0: _bird1_x = -28.0
	if _bird2_x < -28.0:  _bird2_x =  528.0
	if _bird1 != null: _bird1.position.x = _bird1_x
	if _bird2 != null: _bird2.position.x = _bird2_x
	queue_redraw()

# ── CUSTOM DRAW ───────────────────────────────────────────────────────────────
func _draw() -> void:
	_rng.seed = 4419
	_draw_backgrounds()
	_draw_zone_accents()
	_draw_jungle_trees()
	_draw_wildlands_deco()
	_draw_ruins_deco()
	_draw_river_art()
	_draw_camp_art()
	_draw_temple_art()
	_draw_fog()
	_draw_lost_path()
	_draw_marker_halos()

# ── DRAW: backgrounds ─────────────────────────────────────────────────────────
func _draw_backgrounds() -> void:
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
	var pts := PackedVector2Array(PATH_PTS)
	# Shadow
	var shd := PackedVector2Array()
	for p: Vector2 in pts: shd.append(p + Vector2(4, 4))
	draw_polyline(shd, C_PATH_SHD, 18.0, false)
	# Outer dark edge
	draw_polyline(pts, C_PATH_OUT,  17.0, true)
	# Earthy border
	draw_polyline(pts, C_PATH_EDGE, 13.0, true)
	# Dirt fill
	draw_polyline(pts, C_PATH_DIRT, 9.0,  true)
	# Centre highlight
	draw_polyline(pts, C_PATH_MID,  4.5,  true)
	# Shimmer
	draw_polyline(pts, C_PATH_LITE, 1.8,  true)
	# Small stone markers along path edges
	for i in range(0, pts.size() - 1, 3):
		var p: Vector2 = pts[i]
		var n: Vector2 = pts[i + 1]
		var dir := (n - p).normalized()
		var perp := Vector2(-dir.y, dir.x)
		draw_circle(p + perp * 8.5, 2.2, C_STONE_M)
		draw_circle(p - perp * 8.5, 2.0, C_STONE_D)

# ── DRAW: marker halos ────────────────────────────────────────────────────────
func _draw_marker_halos() -> void:
	for i in range(TOTAL_LEVELS):
		if not SaveManager.is_level_unlocked(i + 1): continue
		var p:   Vector2 = NODE_POS[i]
		var col: Color   = LEVEL_INFO[i]["color"]
		draw_circle(p, 50.0, col.darkened(0.60).lerp(Color.TRANSPARENT, 0.55))
		draw_circle(p, 38.0, col.darkened(0.45).lerp(Color.TRANSPARENT, 0.45))
		if SaveManager.get_stars(i + 1) == 0:  # current next level — brighter halo
			draw_circle(p, 52.0, Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.14))

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

# ── BUILD: zone labels ────────────────────────────────────────────────────────
func _build_zone_labels() -> void:
	var zones := [
		["WILDLANDS OF PEACE", Vector2(0,  148), 9,  Color(0.80, 0.70, 0.36, 0.55), HORIZONTAL_ALIGNMENT_CENTER],
		["TEMPLE APPROACH",    Vector2(0,  222), 8,  Color(0.72, 0.60, 0.24, 0.44), HORIZONTAL_ALIGNMENT_RIGHT],
		["ANCIENT RUINS",      Vector2(0,  300), 8,  Color(0.52, 0.40, 0.18, 0.40), HORIZONTAL_ALIGNMENT_RIGHT],
		["~ River of Echoes ~", Vector2(0,  434), 10, Color(0.60, 0.86, 0.96, 0.72), HORIZONTAL_ALIGNMENT_CENTER],
		["DEEP FOREST",        Vector2(8,  538), 8,  Color(0.20, 0.48, 0.16, 0.38), HORIZONTAL_ALIGNMENT_LEFT],
		["JUNGLE TRAIL",       Vector2(0,  644), 8,  Color(0.24, 0.58, 0.18, 0.40), HORIZONTAL_ALIGNMENT_RIGHT],
		["START CAMP",         Vector2(0,  820), 9,  Color(0.86, 0.74, 0.42, 0.72), HORIZONTAL_ALIGNMENT_CENTER],
	]
	for z in zones:
		var l := Label.new()
		l.text = z[0]
		l.horizontal_alignment = z[4]
		l.add_theme_font_size_override("font_size", z[2])
		l.add_theme_color_override("font_color", z[3])
		l.size = Vector2(480, 20)
		l.position = z[1]
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(l)

# ── BUILD: level markers ──────────────────────────────────────────────────────
func _build_level_markers() -> void:
	for i in range(TOTAL_LEVELS):
		_add_marker(i + 1)

func _add_marker(level_id: int) -> void:
	var info: Dictionary = LEVEL_INFO[level_id - 1]
	var pos: Vector2     = NODE_POS[level_id - 1]
	var unlocked   := SaveManager.is_level_unlocked(level_id)
	var stars      := SaveManager.get_stars(level_id)
	var is_next    := unlocked and stars == 0
	var needs_shoes:= level_id == 6 and unlocked and not SaveManager.has_upgrade("sand_shoes")

	# Outer hit zone (transparent, defines tap area)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(90, 90)
	btn.size                = Vector2(90, 90)
	btn.position            = pos - Vector2(45, 45)
	btn.flat                = true
	btn.focus_mode          = Control.FOCUS_NONE
	add_child(btn)

	var sf := StyleBoxFlat.new()
	sf.corner_radius_top_left    = 45
	sf.corner_radius_top_right   = 45
	sf.corner_radius_bottom_left = 45
	sf.corner_radius_bottom_right= 45
	sf.border_width_left = 2; sf.border_width_right  = 2
	sf.border_width_top  = 2; sf.border_width_bottom = 2

	if needs_shoes:
		sf.bg_color     = Color(0.52, 0.38, 0.12, 0.88)
		sf.border_color = Color(0.92, 0.74, 0.24)
	elif not unlocked:
		sf.bg_color     = Color(0.05, 0.05, 0.05, 0.85)
		sf.border_color = Color(0.22, 0.22, 0.20, 0.50)
		sf.border_width_left = 1; sf.border_width_right  = 1
		sf.border_width_top  = 1; sf.border_width_bottom = 1
	else:
		var col: Color = info["color"]
		sf.bg_color     = col.darkened(0.48)
		sf.border_color = C_GOLD if is_next else col.lightened(0.28)

	btn.add_theme_stylebox_override("normal",  sf)
	btn.add_theme_stylebox_override("pressed", sf)
	var sfh := sf.duplicate() as StyleBoxFlat
	if unlocked:
		var sfh_col: Color = info["color"]
		sfh.bg_color = sfh_col.darkened(0.28)
	btn.add_theme_stylebox_override("hover", sfh)

	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.add_theme_constant_override("separation", 0)
	btn.add_child(vb)

	# Level number or status icon
	var num_lbl := Label.new()
	if needs_shoes:
		num_lbl.text = "👟"
		num_lbl.add_theme_color_override("font_color", Color(0.96, 0.84, 0.32))
	elif not unlocked:
		num_lbl.text = "🔒"
		num_lbl.add_theme_color_override("font_color", Color(0.42, 0.42, 0.38))
	else:
		num_lbl.text = str(level_id)
		var num_col: Color = info["color"]
		num_lbl.add_theme_color_override("font_color", num_col.lightened(0.72))
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.add_theme_font_size_override("font_size", 24)
	num_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	num_lbl.add_theme_constant_override("shadow_offset_x", 1)
	num_lbl.add_theme_constant_override("shadow_offset_y", 1)
	vb.add_child(num_lbl)

	# Stars or state row
	var star_lbl := Label.new()
	star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if needs_shoes:
		star_lbl.text = "Shoes"
		star_lbl.add_theme_color_override("font_color", Color(0.96, 0.80, 0.24))
		star_lbl.add_theme_font_size_override("font_size", 10)
	elif not unlocked:
		star_lbl.text = "— —"
		star_lbl.add_theme_color_override("font_color", Color(0.34, 0.34, 0.32))
		star_lbl.add_theme_font_size_override("font_size", 11)
	elif stars > 0:
		star_lbl.text = "★".repeat(stars) + "☆".repeat(3 - stars)
		star_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.18))
		star_lbl.add_theme_font_size_override("font_size", 16)
	else:
		star_lbl.text = "☆ ☆ ☆"
		star_lbl.add_theme_color_override("font_color", Color(0.55, 0.52, 0.40))
		star_lbl.add_theme_font_size_override("font_size", 15)
	vb.add_child(star_lbl)

	# Level name label below the marker circle
	var name_lbl := Label.new()
	name_lbl.text = info["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 10)
	var nc: Color
	if unlocked:
		var nc_base: Color = info["color"]
		nc = nc_base.lightened(0.55)
	else:
		nc = Color(0.38, 0.36, 0.32)
	name_lbl.add_theme_color_override("font_color", nc)
	name_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.70))
	name_lbl.add_theme_constant_override("shadow_offset_x", 1)
	name_lbl.add_theme_constant_override("shadow_offset_y", 1)
	name_lbl.size = Vector2(110, 18)
	name_lbl.position = pos - Vector2(55, -47)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_lbl)

	if unlocked:
		btn.pressed.connect(_on_marker.bind(level_id))

	if is_next and not needs_shoes:
		var tw := create_tween().set_loops()
		tw.tween_property(btn, "modulate", Color(1.40, 1.26, 0.80), 0.78)
		tw.tween_property(btn, "modulate", Color(1.00, 1.00, 1.00), 0.78)

# ── BUILD: UI overlay ─────────────────────────────────────────────────────────
func _build_ui_overlay() -> void:
	# Header background
	var hdr := ColorRect.new()
	hdr.color = Color(0.02, 0.05, 0.02, 0.96)
	hdr.size = Vector2(480, 62)
	hdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hdr)
	# Accent lines
	var gold_line := ColorRect.new()
	gold_line.color = Color(0.72, 0.56, 0.18, 0.85)
	gold_line.size = Vector2(480, 2)
	gold_line.position = Vector2(0, 62)
	gold_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gold_line)

	var title := Label.new()
	title.text = "✦  JUNGLE MAP  ✦"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.82, 0.28))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.60))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.size = Vector2(300, 44); title.position = Vector2(90, 10)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)

	var btn_back := Button.new()
	btn_back.text = "←"
	btn_back.custom_minimum_size = Vector2(52, 44)
	btn_back.position = Vector2(6, 10)
	btn_back.add_theme_font_size_override("font_size", 22)
	btn_back.pressed.connect(_on_back)
	add_child(btn_back)

	var coins_lbl := Label.new()
	coins_lbl.text = "🪙 " + str(SaveManager.get_coins())
	coins_lbl.add_theme_font_size_override("font_size", 13)
	coins_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.24))
	coins_lbl.size = Vector2(90, 30); coins_lbl.position = Vector2(384, 16)
	coins_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(coins_lbl)

	# Bottom objective strip
	var bot := ColorRect.new()
	bot.color = Color(0.02, 0.05, 0.02, 0.90)
	bot.size = Vector2(480, 32); bot.position = Vector2(0, 822)
	bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bot)
	var obj := Label.new()
	obj.text = "Follow the Lost Path  ·  Reach the Temple of the First Sun"
	obj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	obj.add_theme_font_size_override("font_size", 10)
	obj.add_theme_color_override("font_color", Color(0.70, 0.86, 0.58, 0.90))
	obj.size = Vector2(480, 28); obj.position = Vector2(0, 826)
	obj.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(obj)

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
	_label(_preview_panel, "DescLbl",    Vector2(22, 104), Vector2(436, 72), 13, Color(0.80, 0.88, 0.70))
	(_preview_panel.get_node("DescLbl") as Label).autowrap_mode = TextServer.AUTOWRAP_WORD
	var div := ColorRect.new()
	div.color = Color(0.40, 0.30, 0.12, 0.50)
	div.size = Vector2(436, 1); div.position = Vector2(22, 180)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(div)
	_label(_preview_panel, "RewardsLbl", Vector2(20, 184), Vector2(440, 22), 11, Color(0.68, 0.64, 0.42))

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
func _show_preview(level_id: int) -> void:
	_current_preview = level_id
	var info: Dictionary = LEVEL_INFO[level_id - 1]
	var stars            := SaveManager.get_stars(level_id)
	(_preview_panel.get_node("ChapterLbl") as Label).text = info["chapter"] + "  ·  " + info["area"]
	(_preview_panel.get_node("NameLbl") as Label).text    = "Level " + str(level_id) + "  —  " + info["name"]
	var sl := _preview_panel.get_node("StarsLbl") as Label
	if stars > 0:
		sl.text = "★".repeat(stars) + "☆".repeat(3 - stars)
		sl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.18))
	else:
		sl.text = "Not yet completed  ☆ ☆ ☆"
		sl.add_theme_color_override("font_color", Color(0.55, 0.52, 0.40))
	(_preview_panel.get_node("DescLbl") as Label).text    = info["desc"]
	(_preview_panel.get_node("RewardsLbl") as Label).text = "Rewards: " + info["rewards"]
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

func _on_start() -> void:
	if _current_preview > 0:
		EventBus.play_sfx.emit("button")
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
	if _sand_popup != null and _sand_popup.visible:
		_sand_popup.visible = false; return
	if _preview_panel != null and _preview_panel.visible:
		_hide_preview(); return
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

# ── HELPERS ───────────────────────────────────────────────────────────────────
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
