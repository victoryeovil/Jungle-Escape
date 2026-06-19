extends Control

# ─── Upgrade Shop ─────────────────────────────────────────────────────────────
# Lists all buyable upgrades from Constants.UPGRADES.
# Shows owned status, cost breakdown, and handles purchase via SaveManager.

var _cards: Dictionary = {}   # upgrade_id → Dictionary of UI nodes
var _status_lbl: Label = null

func _ready() -> void:
	_build_background()
	_build_header()
	_build_inventory_strip()
	_build_upgrade_list()
	_build_status_label()
	_refresh_all()

# ─── Build ────────────────────────────────────────────────────────────────────

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.16, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Dark green gradient overlay at top
	var top := ColorRect.new()
	top.color = Color(0.04, 0.12, 0.04, 0.70)
	top.size = Vector2(480, 100)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)

func _build_header() -> void:
	var hdr := ColorRect.new()
	hdr.color = Color(0.06, 0.10, 0.04, 0.96)
	hdr.size = Vector2(480, 60)
	add_child(hdr)

	var btn_back := Button.new()
	btn_back.text = "←"
	btn_back.custom_minimum_size = Vector2(52, 44)
	btn_back.position = Vector2(6, 8)
	btn_back.pressed.connect(_on_back)
	_style_btn(btn_back, Color(0.18, 0.30, 0.12))
	hdr.add_child(btn_back)

	var lbl_title := Label.new()
	lbl_title.text = "Upgrade Shop"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 20)
	lbl_title.add_theme_color_override("font_color", Color(0.92, 0.82, 0.40))
	lbl_title.size = Vector2(260, 44)
	lbl_title.position = Vector2(110, 10)
	hdr.add_child(lbl_title)

	var lbl_coins := Label.new()
	lbl_coins.name = "HdrCoins"
	lbl_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_coins.add_theme_font_size_override("font_size", 14)
	lbl_coins.add_theme_color_override("font_color", Color(1.0, 0.90, 0.30))
	lbl_coins.size = Vector2(90, 44)
	lbl_coins.position = Vector2(382, 10)
	hdr.add_child(lbl_coins)

func _build_inventory_strip() -> void:
	var strip := ColorRect.new()
	strip.name = "InventoryStrip"
	strip.color = Color(0.04, 0.08, 0.03, 0.85)
	strip.size = Vector2(480, 38)
	strip.position = Vector2(0, 60)
	add_child(strip)

	var x := 8.0
	for r: Dictionary in Constants.RESOURCES:
		var lbl := Label.new()
		lbl.name = "ResLbl_" + str(r.get("id", ""))
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.88, 0.82, 0.58))
		lbl.size = Vector2(74, 38)
		lbl.position = Vector2(x, 2)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		strip.add_child(lbl)
		x += 76.0

func _build_upgrade_list() -> void:
	var list := Control.new()
	list.name = "UpgradeList"
	list.position = Vector2(0, 106)
	list.size = Vector2(480, 640)
	add_child(list)

	var y := 0.0
	for upg: Dictionary in Constants.UPGRADES:
		var card := _build_upgrade_card(upg, Vector2(16, y))
		list.add_child(card)
		_cards[upg.get("id", "")] = card
		y += 172.0

func _build_upgrade_card(upg: Dictionary, card_pos: Vector2) -> Control:
	var upg_id: String = upg.get("id", "unknown")
	var card := ColorRect.new()
	card.name = "Card_" + upg_id
	card.color = Color(0.08, 0.16, 0.06, 0.92)
	card.size = Vector2(448, 160)
	card.position = card_pos

	# Icon strip left
	var icon_col := ColorRect.new()
	icon_col.color = Color(0.12, 0.22, 0.08, 1.0)
	icon_col.size = Vector2(60, 160)
	card.add_child(icon_col)

	var icon_lbl := Label.new()
	icon_lbl.name = "Icon"
	icon_lbl.text = upg.get("icon", "?")
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 32)
	icon_lbl.size = Vector2(60, 160)
	card.add_child(icon_lbl)

	var lbl_name := Label.new()
	lbl_name.text = upg.get("name", upg_id)
	lbl_name.add_theme_font_size_override("font_size", 17)
	lbl_name.add_theme_color_override("font_color", Color(0.92, 0.88, 0.60))
	lbl_name.size = Vector2(280, 28)
	lbl_name.position = Vector2(68, 8)
	card.add_child(lbl_name)

	var lbl_desc := Label.new()
	lbl_desc.text = upg.get("description", upg.get("desc", ""))
	lbl_desc.add_theme_font_size_override("font_size", 12)
	lbl_desc.add_theme_color_override("font_color", Color(0.78, 0.78, 0.68))
	lbl_desc.size = Vector2(280, 48)
	lbl_desc.position = Vector2(68, 36)
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(lbl_desc)

	# Cost breakdown
	var cost: Dictionary = upg.get("cost", {})
	var cost_text := _build_cost_text(cost)
	var lbl_cost := Label.new()
	lbl_cost.name = "LblCost"
	lbl_cost.text = cost_text
	lbl_cost.add_theme_font_size_override("font_size", 12)
	lbl_cost.add_theme_color_override("font_color", Color(0.90, 0.75, 0.30))
	lbl_cost.size = Vector2(280, 40)
	lbl_cost.position = Vector2(68, 82)
	lbl_cost.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(lbl_cost)

	# Status / Buy button
	var btn_buy := Button.new()
	btn_buy.name = "BtnBuy"
	btn_buy.text = "Buy"
	btn_buy.custom_minimum_size = Vector2(88, 36)
	btn_buy.position = Vector2(350, 116)
	btn_buy.pressed.connect(func() -> void: _on_buy(upg_id))
	_style_btn(btn_buy, Color(0.24, 0.48, 0.12))
	card.add_child(btn_buy)

	var lbl_status := Label.new()
	lbl_status.name = "LblStatus"
	lbl_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_status.add_theme_font_size_override("font_size", 13)
	lbl_status.size = Vector2(280, 32)
	lbl_status.position = Vector2(68, 122)
	card.add_child(lbl_status)

	return card

func _build_status_label() -> void:
	_status_lbl = Label.new()
	_status_lbl.name = "StatusLbl"
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_font_size_override("font_size", 13)
	_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.60, 0.30))
	_status_lbl.size = Vector2(440, 32)
	_status_lbl.position = Vector2(20, 810)
	_status_lbl.visible = false
	add_child(_status_lbl)

# ─── Refresh ──────────────────────────────────────────────────────────────────

func _refresh_all() -> void:
	# Coins in header
	var hdr_coins := find_child("HdrCoins", true, false) as Label
	if hdr_coins != null:
		hdr_coins.text = "🪙 " + str(SaveManager.get_coins())
	# Resource inventory strip
	var strip := find_child("InventoryStrip", true, false)
	if strip != null:
		for r: Dictionary in Constants.RESOURCES:
			var res_id: String = r.get("id", "")
			var lbl := strip.find_child("ResLbl_" + res_id, false, false) as Label
			if lbl != null:
				lbl.text = r.get("icon", "?") + " " + str(SaveManager.get_resource(res_id))
	# Each upgrade card
	for upg_id: String in _cards:
		_refresh_card(upg_id)

func _refresh_card(upg_id: String) -> void:
	var card := _cards.get(upg_id) as Control
	if card == null:
		return
	var owned := SaveManager.has_upgrade(upg_id)
	var btn_buy := card.find_child("BtnBuy", false, false) as Button
	var lbl_status := card.find_child("LblStatus", false, false) as Label
	if owned:
		if btn_buy != null:
			btn_buy.visible = false
		if lbl_status != null:
			lbl_status.text = "✓ Owned"
			lbl_status.add_theme_color_override("font_color", Color(0.42, 0.90, 0.38))
		card.color = Color(0.06, 0.14, 0.08, 0.92)
	else:
		if btn_buy != null:
			btn_buy.visible = true
			btn_buy.disabled = not _can_afford(upg_id)
		if lbl_status != null:
			lbl_status.text = ""

# ─── Actions ──────────────────────────────────────────────────────────────────

func _on_buy(upg_id: String) -> void:
	EventBus.play_sfx.emit("button")
	if SaveManager.has_upgrade(upg_id):
		_show_status("Already owned!")
		return
	var ok := SaveManager.buy_upgrade(upg_id)
	if ok:
		_show_status("Purchased! 🎉")
		_refresh_all()
	else:
		_show_status("Not enough resources.")
		_refresh_all()

func _on_back() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_level_select()

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _can_afford(upg_id: String) -> bool:
	for upg: Dictionary in Constants.UPGRADES:
		if upg.get("id", "") == upg_id:
			var cost: Dictionary = upg.get("cost", {})
			for key: String in cost:
				if key == "coins":
					if SaveManager.get_coins() < int(cost[key]):
						return false
				else:
					if SaveManager.get_resource(key) < int(cost[key]):
						return false
			return true
	return false

func _build_cost_text(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for key: String in cost:
		var val: int = int(cost[key])
		if key == "coins":
			parts.append("🪙 " + str(val) + " Coins")
		else:
			var info := _find_resource_info(key)
			parts.append(info.get("icon", "?") + " " + str(val) + " " + info.get("name", key))
	return "  ".join(parts)

func _find_resource_info(resource_id: String) -> Dictionary:
	for r: Dictionary in Constants.RESOURCES:
		if r.get("id", "") == resource_id:
			return r
	return { "id": resource_id, "name": resource_id, "icon": "?" }

func _show_status(msg: String) -> void:
	if _status_lbl == null:
		return
	_status_lbl.text = msg
	_status_lbl.visible = true
	get_tree().create_timer(2.4).timeout.connect(func() -> void:
		if _status_lbl != null:
			_status_lbl.visible = false
	)

func _style_btn(btn: Button, col: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	btn.add_theme_stylebox_override("normal", sb)
	var sb_h := sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = col.lightened(0.18)
	btn.add_theme_stylebox_override("hover", sb_h)
	var sb_p := sb.duplicate() as StyleBoxFlat
	sb_p.bg_color = col.darkened(0.18)
	btn.add_theme_stylebox_override("pressed", sb_p)
