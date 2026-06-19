extends RefCounted
class_name UIStyle

const TITLE_FONT: Font     = preload("res://assets/fonts/title_font.ttf")
const BODY_FONT: Font      = preload("res://assets/fonts/body_font.ttf")

const ICON_PAUSE: Texture2D   = preload("res://assets/ui/icons/icon_pause.png")
const ICON_RESTART: Texture2D = preload("res://assets/ui/icons/icon_restart.png")
const ICON_HINT: Texture2D    = preload("res://assets/ui/icons/icon_hint.png")
const ICON_COIN: Texture2D    = preload("res://assets/ui/icons/icon_coin.png")
const ICON_KEY: Texture2D     = preload("res://assets/ui/icons/icon_key.png")
const ICON_STAR: Texture2D    = preload("res://assets/ui/icons/icon_star.png")

static func apply(root: Node) -> void:
	if root is Control:
		_apply_control(root as Control)
	for child in root.get_children():
		apply(child)

static func set_button_icon(button: Button, texture: Texture2D, icon_only: bool = false) -> void:
	button.icon = texture
	button.expand_icon = true
	if icon_only:
		button.text = ""
		button.custom_minimum_size = Vector2(52, 52)

static func make_counter_icon(texture: Texture2D) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(28, 28)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon

static func _apply_control(control: Control) -> void:
	if control is Label:
		_apply_label(control as Label)
	elif control is Button:
		_apply_button(control as Button)
	elif control is CheckBox:
		(control as CheckBox).add_theme_font_override("font", BODY_FONT)
	elif control is TabBar:
		(control as TabBar).add_theme_font_override("font", BODY_FONT)

static func _apply_label(label: Label) -> void:
	var lower_name := String(label.name).to_lower()
	if lower_name.contains("title") or lower_name.contains("world") or lower_name.contains("paused") or lower_name.contains("reason"):
		label.add_theme_font_override("font", TITLE_FONT)
	else:
		label.add_theme_font_override("font", BODY_FONT)
	label.add_theme_color_override("font_color", Color(0.92, 0.96, 0.82))

static func _apply_button(button: Button) -> void:
	button.add_theme_font_override("font", BODY_FONT)
	button.add_theme_color_override("font_color", Color(0.96, 0.94, 0.78))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.86))
	button.add_theme_color_override("font_pressed_color", Color(0.78, 1.0, 0.64))
