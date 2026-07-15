extends Control

const SW := 480.0
const SH := 854.0
const PAD := 24.0
const CW  := SW - PAD * 2.0   # 432

const C_GOLD   := Color(0.96, 0.82, 0.24)
const C_GREEN  := Color(0.28, 0.72, 0.32)
const C_TEXT   := Color(0.90, 0.92, 0.84)
const C_DIM    := Color(0.58, 0.64, 0.52)
const C_ERROR  := Color(1.00, 0.38, 0.28)
const C_CARD   := Color(0.04, 0.09, 0.04, 0.97)
const C_INPUT  := Color(0.06, 0.12, 0.06, 1.00)
const C_BORDER := Color(0.26, 0.46, 0.18, 0.85)

var _is_signup    : bool    = false
var _inp_name     : LineEdit = null
var _inp_email    : LineEdit = null
var _inp_pass     : LineEdit = null
var _inp_confirm  : LineEdit = null
var _lbl_error    : Label   = null
var _btn_submit   : Button  = null
var _btn_toggle   : Button  = null
var _lbl_form_title: Label  = null
var _name_row     : Control = null
var _confirm_row  : Control = null
var _skip_btn     : Button  = null
var _btn_google   : Button  = null
var _lbl_oauth    : Label   = null

func _ready() -> void:
	UIStyle.apply(self)
	_build_ui()
	SupabaseClient.auth_success.connect(_on_auth_success)
	SupabaseClient.auth_error.connect(_on_auth_error)

# ── Build ─────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	_build_bg_deco()
	_build_header()
	_build_hero()
	_build_form_card()
	_build_skip_row()

func _build_bg_deco() -> void:
	# Subtle top green gradient strip
	var top := ColorRect.new()
	top.color    = Color(0.04, 0.18, 0.04, 0.55)
	top.size     = Vector2(SW, 200)
	top.position = Vector2.ZERO
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)

	# Bottom gradient strip
	var bot := ColorRect.new()
	bot.color    = Color(0.02, 0.10, 0.02, 0.40)
	bot.size     = Vector2(SW, 160)
	bot.position = Vector2(0, SH - 160)
	bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bot)

	# Decorative horizontal divider lines
	for y_val in [58.0, SH - 60.0]:
		var line := ColorRect.new()
		line.color    = Color(C_GOLD.r, C_GOLD.g, C_GOLD.b, 0.30)
		line.size     = Vector2(SW, 1)
		line.position = Vector2(0, y_val)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(line)

func _build_header() -> void:
	var hdr := ColorRect.new()
	hdr.color    = Color(0.02, 0.06, 0.02, 0.98)
	hdr.size     = Vector2(SW, 58)
	hdr.position = Vector2.ZERO
	hdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hdr)

	var btn := Button.new()
	btn.text     = "←  Back"
	btn.position = Vector2(8, 9)
	btn.custom_minimum_size = Vector2(96, 40)
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", C_GOLD)
	var sb := _make_sb(Color(0.04, 0.08, 0.02, 0.85), Color(0.50, 0.38, 0.10, 0.80), 1, 7)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover",  _make_sb(Color(0.08, 0.14, 0.04, 0.95), Color(0.70, 0.54, 0.14, 0.90), 1, 7))
	btn.add_theme_stylebox_override("pressed", sb)
	btn.pressed.connect(func() -> void: GameManager.go_to_menu())
	hdr.add_child(btn)

	var title := Label.new()
	title.text = "EXPLORER LOG IN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	title.size = Vector2(SW, 58)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", C_GOLD)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hdr.add_child(title)

func _build_hero() -> void:
	var hero := Control.new()
	hero.position    = Vector2(0, 62)
	hero.size        = Vector2(SW, 130)
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hero)

	# Jungle emblem circle
	var circle := ColorRect.new()
	circle.size     = Vector2(86, 86)
	circle.position = Vector2((SW - 86) * 0.5, 14)
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(0.06, 0.16, 0.06, 0.95)
	csb.border_color = C_GOLD
	csb.border_width_left = 2; csb.border_width_right = 2
	csb.border_width_top = 2; csb.border_width_bottom = 2
	csb.corner_radius_top_left = 43; csb.corner_radius_top_right = 43
	csb.corner_radius_bottom_left = 43; csb.corner_radius_bottom_right = 43
	circle.add_theme_stylebox_override("panel", csb)
	hero.add_child(circle)

	var icon := Label.new()
	icon.text = "🌿"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	icon.size = Vector2(86, 86)
	icon.position = Vector2((SW - 86) * 0.5, 14)
	icon.add_theme_font_size_override("font_size", 40)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(icon)

	var tagline := Label.new()
	tagline.text = "Save your journey. Compete globally."
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.size = Vector2(SW, 28)
	tagline.position = Vector2(0, 106)
	tagline.add_theme_font_size_override("font_size", 13)
	tagline.add_theme_color_override("font_color", C_DIM)
	tagline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(tagline)

func _build_form_card() -> void:
	var card := Panel.new()
	card.position = Vector2(PAD, 202)
	card.size     = Vector2(CW, 530)
	var csb := _make_sb(C_CARD, C_BORDER, 2, 14)
	card.add_theme_stylebox_override("panel", csb)
	add_child(card)

	var y := 28.0

	# Form title
	_lbl_form_title = Label.new()
	_lbl_form_title.text = "Sign In to Your Account"
	_lbl_form_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_form_title.size = Vector2(CW, 32)
	_lbl_form_title.position = Vector2(0, y)
	_lbl_form_title.add_theme_font_size_override("font_size", 20)
	_lbl_form_title.add_theme_color_override("font_color", C_GOLD)
	_lbl_form_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(_lbl_form_title)
	y += 50.0

	# Benefits strip (sign-in mode) / shown only when not signup
	var benefits_lbl := Label.new()
	benefits_lbl.name = "BenefitsLbl"
	benefits_lbl.text = "• Cloud save  •  Leaderboards  •  Daily rewards"
	benefits_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	benefits_lbl.size = Vector2(CW - 32, 22)
	benefits_lbl.position = Vector2(16, y)
	benefits_lbl.add_theme_font_size_override("font_size", 11)
	benefits_lbl.add_theme_color_override("font_color", C_DIM)
	benefits_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(benefits_lbl)
	y += 32.0

	# ── Input fields ──────────────────────────────────────────────────────────

	# Display name row (sign-up only)
	_name_row = _make_field_row(card, y, "Display Name", false)
	_inp_name = _name_row.get_child(0) as LineEdit
	_name_row.visible = false
	y += 62.0

	# Email
	var email_row := _make_field_row(card, y, "Email", false)
	_inp_email = email_row.get_child(0) as LineEdit
	y += 62.0

	# Password
	var pass_row := _make_field_row(card, y, "Password", true)
	_inp_pass = pass_row.get_child(0) as LineEdit
	y += 62.0

	# Confirm password row (sign-up only)
	_confirm_row = _make_field_row(card, y, "Confirm Password", true)
	_inp_confirm = _confirm_row.get_child(0) as LineEdit
	_confirm_row.visible = false
	y += 62.0

	# Error label
	_lbl_error = Label.new()
	_lbl_error.name = "ErrLbl"
	_lbl_error.size = Vector2(CW - 32, 36)
	_lbl_error.position = Vector2(16, y)
	_lbl_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_error.add_theme_font_size_override("font_size", 12)
	_lbl_error.add_theme_color_override("font_color", C_ERROR)
	_lbl_error.visible = false
	card.add_child(_lbl_error)
	y += 40.0

	# Submit button
	_btn_submit = Button.new()
	_btn_submit.text = "SIGN IN"
	_btn_submit.position = Vector2(16, y)
	_btn_submit.custom_minimum_size = Vector2(CW - 32, 52)
	_btn_submit.focus_mode = Control.FOCUS_NONE
	_btn_submit.add_theme_font_size_override("font_size", 17)
	_btn_submit.add_theme_color_override("font_color", Color(0.06, 0.06, 0.02))
	var submit_sb := _make_sb(C_GREEN, Color(0.20, 0.56, 0.22), 0, 10)
	var submit_sbh := _make_sb(C_GREEN.lightened(0.12), Color(0.20, 0.56, 0.22), 0, 10)
	_btn_submit.add_theme_stylebox_override("normal",  submit_sb)
	_btn_submit.add_theme_stylebox_override("hover",   submit_sbh)
	_btn_submit.add_theme_stylebox_override("pressed", submit_sb)
	_btn_submit.pressed.connect(_on_submit)
	card.add_child(_btn_submit)
	y += 62.0

	# Toggle sign-in / register
	_btn_toggle = Button.new()
	_btn_toggle.text = "New here?  Create a free account  →"
	_btn_toggle.position = Vector2(16, y)
	_btn_toggle.custom_minimum_size = Vector2(CW - 32, 36)
	_btn_toggle.flat = true
	_btn_toggle.focus_mode = Control.FOCUS_NONE
	_btn_toggle.add_theme_font_size_override("font_size", 13)
	_btn_toggle.add_theme_color_override("font_color", C_GREEN.lightened(0.20))
	_btn_toggle.pressed.connect(_on_toggle_mode)
	card.add_child(_btn_toggle)
	y += 40.0

	# Divider
	var div := ColorRect.new()
	div.color    = Color(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.40)
	div.size     = Vector2(CW - 32, 1)
	div.position = Vector2(16, y)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(div)
	y += 14.0

	# Google button
	_btn_google = Button.new()
	_btn_google.text = "G   Continue with Google"
	_btn_google.position = Vector2(16, y)
	_btn_google.custom_minimum_size = Vector2(CW - 32, 48)
	_btn_google.focus_mode = Control.FOCUS_NONE
	_btn_google.add_theme_font_size_override("font_size", 14)
	_btn_google.add_theme_color_override("font_color", Color(0.12, 0.12, 0.12))
	var gsb  := _make_sb(Color(0.96, 0.96, 0.96, 1.0), Color(0.78, 0.78, 0.78, 1.0), 1, 8)
	var gsbh := _make_sb(Color(0.88, 0.88, 0.88, 1.0), Color(0.68, 0.68, 0.68, 1.0), 1, 8)
	_btn_google.add_theme_stylebox_override("normal",  gsb)
	_btn_google.add_theme_stylebox_override("hover",   gsbh)
	_btn_google.add_theme_stylebox_override("pressed", gsb)
	_btn_google.pressed.connect(_on_google)
	card.add_child(_btn_google)
	y += 58.0

	# OAuth waiting notice (hidden until sign-in starts)
	_lbl_oauth = Label.new()
	_lbl_oauth.text = "⏳  Waiting for Google sign-in in your browser…"
	_lbl_oauth.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_oauth.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_oauth.size = Vector2(CW - 32, 36)
	_lbl_oauth.position = Vector2(16, y)
	_lbl_oauth.add_theme_font_size_override("font_size", 12)
	_lbl_oauth.add_theme_color_override("font_color", C_DIM)
	_lbl_oauth.visible = false
	card.add_child(_lbl_oauth)

	# Resize card to fit content
	card.size = Vector2(CW, y + 50.0)

func _make_field_row(parent: Control, y: float, hint: String, secret: bool) -> Control:
	var row := Control.new()
	row.position = Vector2(16, y)
	row.size     = Vector2(CW - 32, 52)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(row)

	var inp := LineEdit.new()
	inp.placeholder_text = hint
	inp.secret           = secret
	inp.size             = Vector2(CW - 32, 52)
	inp.custom_minimum_size = Vector2(0, 52)
	inp.add_theme_font_size_override("font_size", 16)
	inp.add_theme_color_override("font_color", C_TEXT)
	inp.add_theme_color_override("font_placeholder_color", C_DIM)
	var isb := _make_sb(C_INPUT, C_BORDER, 1, 8)
	inp.add_theme_stylebox_override("normal", isb)
	inp.add_theme_stylebox_override("focus",  _make_sb(C_INPUT, C_GREEN, 2, 8))
	row.add_child(inp)
	return row

func _build_skip_row() -> void:
	_skip_btn = Button.new()
	_skip_btn.name = "SkipBtn"
	_skip_btn.text = "Maybe Later"
	_skip_btn.position = Vector2(PAD, SH - 64)
	_skip_btn.custom_minimum_size = Vector2(CW, 44)
	_skip_btn.flat = true
	_skip_btn.focus_mode = Control.FOCUS_NONE
	_skip_btn.add_theme_font_size_override("font_size", 14)
	_skip_btn.add_theme_color_override("font_color", C_DIM)
	_skip_btn.pressed.connect(_on_skip)
	add_child(_skip_btn)

	if GameManager.login_required:
		_skip_btn.visible = false

# ── Mode toggle ───────────────────────────────────────────────────────────────

func _on_toggle_mode() -> void:
	_is_signup = not _is_signup
	_lbl_error.visible = false
	_inp_name.text    = ""
	_inp_confirm.text = ""
	_name_row.visible    = _is_signup
	_confirm_row.visible = _is_signup

	if _is_signup:
		_lbl_form_title.text = "Create Your Account"
		_btn_submit.text     = "CREATE ACCOUNT"
		_btn_toggle.text     = "Already have an account?  Sign in  ←"
		_btn_toggle.add_theme_color_override("font_color", C_GOLD)
	else:
		_lbl_form_title.text = "Sign In to Your Account"
		_btn_submit.text     = "SIGN IN"
		_btn_toggle.text     = "New here?  Create a free account  →"
		_btn_toggle.add_theme_color_override("font_color", C_GREEN.lightened(0.20))

# ── Actions ───────────────────────────────────────────────────────────────────

func _on_google() -> void:
	EventBus.play_sfx.emit("button")
	_lbl_error.visible  = false
	_btn_google.disabled = true
	_btn_google.text     = "Opening browser…"
	_lbl_oauth.visible  = true
	SupabaseClient.sign_in_google()

func _on_skip() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

func _on_submit() -> void:
	EventBus.play_sfx.emit("button")
	_lbl_error.visible = false

	var email    := _inp_email.text.strip_edges()
	var password := _inp_pass.text

	if email.is_empty() or password.is_empty():
		_show_error("Please enter your email and password.")
		return
	if "@" not in email or "." not in email:
		_show_error("Enter a valid email address.")
		return
	if password.length() < 6:
		_show_error("Password must be at least 6 characters.")
		return

	if _is_signup:
		var confirm := _inp_confirm.text
		if confirm != password:
			_show_error("Passwords do not match.")
			return
		var display_name := _inp_name.text.strip_edges()
		if display_name.is_empty():
			display_name = email.split("@")[0]
		_set_loading(true)
		SupabaseClient.sign_up(email, password, display_name)
	else:
		_set_loading(true)
		SupabaseClient.sign_in(email, password)

func _set_loading(on: bool) -> void:
	_btn_submit.disabled = on
	if on:
		_btn_submit.text = "Please wait…"
	else:
		_btn_submit.text = "CREATE ACCOUNT" if _is_signup else "SIGN IN"

# ── Supabase callbacks ────────────────────────────────────────────────────────

func _on_auth_success(_user_id: String, display_name: String) -> void:
	if _lbl_oauth != null:
		_lbl_oauth.visible = false
	var is_new_login := not GameManager.is_logged_in
	GameManager.is_logged_in = true
	GameManager.is_guest     = false
	GameManager.player_name  = display_name
	if is_new_login:
		SaveManager.add_coins(50)
	EventBus.login_completed.emit(true)

	SupabaseClient.check_deletion_status(func(deletion_date: Variant) -> void:
		if deletion_date != null:
			_show_deletion_recovery(deletion_date)
		else:
			_proceed_after_login()
	)

func _proceed_after_login() -> void:
	SupabaseClient.download_save(func(cloud_data: Dictionary) -> void:
		if not cloud_data.is_empty():
			SaveManager.restore_from_cloud(cloud_data)
		var pending := GameManager.pending_level_after_login
		if pending > 0:
			GameManager.login_required = false
			GameManager.pending_level_after_login = 0
			GameManager.go_to_gameplay_3d(pending)
		else:
			GameManager.login_required = false
			GameManager.go_to_menu()
	)

func _on_auth_error(message: String) -> void:
	_set_loading(false)
	if _btn_google != null:
		_btn_google.disabled = false
		_btn_google.text     = "G   Continue with Google"
	if _lbl_oauth != null:
		_lbl_oauth.visible = false
	_show_error(message)

# ── Deletion recovery dialog ──────────────────────────────────────────────────

func _show_deletion_recovery(deletion_date: String) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.75)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var dw := 432.0; var dh := 310.0
	var dp := Panel.new()
	dp.position = Vector2((SW - dw) * 0.5, (SH - dh) * 0.5)
	dp.size     = Vector2(dw, dh)
	dp.add_theme_stylebox_override("panel", _make_sb(Color(0.04, 0.08, 0.04, 0.99), Color(0.76, 0.22, 0.14, 0.85), 2, 12))
	add_child(dp)

	var t := Label.new()
	t.text = "Account Pending Deletion"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	t.size = Vector2(dw, 56)
	t.add_theme_font_size_override("font_size", 17)
	t.add_theme_color_override("font_color", Color(1.0, 0.38, 0.28))
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dp.add_child(t)

	var b := Label.new()
	b.text = "Your account is scheduled for deletion on %s.\nWould you like to cancel and keep it?" % deletion_date
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.size = Vector2(dw - 40, 80); b.position = Vector2(20, 60)
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", C_TEXT)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dp.add_child(b)

	var keep := Button.new()
	keep.text = "CANCEL DELETION — KEEP MY ACCOUNT"
	keep.custom_minimum_size = Vector2(dw - 40, 50)
	keep.position = Vector2(20, 160)
	keep.focus_mode = Control.FOCUS_NONE
	keep.add_theme_font_size_override("font_size", 13)
	keep.add_theme_color_override("font_color", C_GOLD)
	keep.add_theme_stylebox_override("normal", _make_sb(Color(0.08, 0.18, 0.06), C_BORDER, 1, 8))
	dp.add_child(keep)
	keep.pressed.connect(func() -> void:
		keep.disabled = true
		SupabaseClient.cancel_deletion(func(_ok: bool) -> void:
			overlay.queue_free(); dp.queue_free()
			_proceed_after_login()
		)
	)

	var out := Button.new()
	out.text = "Sign Out"
	out.custom_minimum_size = Vector2(dw - 40, 44)
	out.position = Vector2(20, 222)
	out.flat = true; out.focus_mode = Control.FOCUS_NONE
	out.add_theme_font_size_override("font_size", 13)
	out.add_theme_color_override("font_color", C_DIM)
	dp.add_child(out)
	out.pressed.connect(func() -> void:
		SupabaseClient.sign_out()
		GameManager.is_logged_in = false
		GameManager.is_guest     = true
		GameManager.player_name  = "Explorer"
		overlay.queue_free(); dp.queue_free()
		GameManager.go_to_menu()
	)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _show_error(msg: String) -> void:
	_lbl_error.text    = msg
	_lbl_error.visible = true

func _make_sb(bg: Color, border: Color, bw: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = bw; sb.border_width_right  = bw
	sb.border_width_top  = bw; sb.border_width_bottom = bw
	sb.corner_radius_top_left     = radius; sb.corner_radius_top_right    = radius
	sb.corner_radius_bottom_left  = radius; sb.corner_radius_bottom_right = radius
	sb.content_margin_left = 12; sb.content_margin_right  = 12
	sb.content_margin_top  = 8;  sb.content_margin_bottom = 8
	return sb
