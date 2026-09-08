extends RefCounted
class_name RunProgressSummary

static func build() -> VBoxContainer:
	var box := VBoxContainer.new()
	box.name = "RunProgress"
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var result := ExpeditionProgress.get_last_run_summary()
	var rank := ExpeditionProgress.get_rank_progress()
	var headline := "+%d XP  |  Rank %d · %s" % [int(result.get("xp_earned", 0)), int(rank.get("rank", 1)), str(rank.get("title", "Explorer"))]
	if bool(result.get("rank_up", false)):
		headline = "RANK UP!  " + headline
	_add_label(box, headline, Color("ffdb7a"), 15)
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 8
	bar.show_percentage = false
	bar.max_value = maxi(1, int(rank.get("needed", 1)))
	bar.value = int(rank.get("current", 0))
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bar)
	var completed: Array = result.get("completed_missions", [])
	if not completed.is_empty():
		_add_label(box, "%d goal%s complete · +%d bonus coins" % [completed.size(), "s" if completed.size() != 1 else "", int(result.get("reward_coins", 0))], Color("a7e3a0"), 14)
	var missions := ExpeditionProgress.get_missions()
	if not missions.is_empty():
		var closest: Dictionary = missions[0]
		for mission: Dictionary in missions:
			if float(mission.get("progress", 0)) / maxf(1.0, float(mission.get("target", 1))) > float(closest.get("progress", 0)) / maxf(1.0, float(closest.get("target", 1))):
				closest = mission
		_add_label(box, "Next goal: %s  ·  %d / %d" % [str(closest.get("title", "Explore")), int(closest.get("progress", 0)), int(closest.get("target", 1))], Color("d5e3ca"), 13)
	return box

static func style_panel(panel: Panel, vbox: VBoxContainer) -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "ResultBackdrop"
	backdrop.color = Color(0.01, 0.04, 0.02, 0.6)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.get_parent().add_child(backdrop)
	panel.get_parent().move_child(backdrop, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("14291e")
	style.border_color = Color("bb9647")
	style.set_border_width_all(2)
	style.set_corner_radius_all(20)
	style.shadow_size = 12
	style.shadow_color = Color(0, 0, 0, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	vbox.offset_left = 18
	vbox.offset_right = -18
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 12)

static func fit_panel(panel: Panel, vbox: VBoxContainer) -> void:
	var height := clampf(vbox.get_combined_minimum_size().y + 40.0, 360.0, 750.0)
	panel.offset_top = -height * 0.5
	panel.offset_bottom = height * 0.5

static func add_chain_result(parent: VBoxContainer, best: int, bonus: int) -> void:
	if not is_instance_valid(parent) or best < 2:
		return
	_add_label(parent, "Best coin chain: %d  ·  %d bonus coins included" % [best, bonus], Color("edc567"), 13)

static func _add_label(parent: Control, text: String, color: Color, font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
