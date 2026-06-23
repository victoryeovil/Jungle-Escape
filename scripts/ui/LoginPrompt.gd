extends Control

# Soft login prompt — never blocks gameplay.
# Shows benefits + email/skip; email opens a real Supabase auth form.

@onready var _btn_google : Button = $Panel/VBox/BtnGoogle
@onready var _btn_email  : Button = $Panel/VBox/BtnEmail
@onready var _btn_skip   : Button = $Panel/VBox/BtnSkip
@onready var _lbl_benefits: Label = $Panel/VBox/LblBenefits

const _BENEFITS := """Log in to unlock:
• Cloud save — never lose progress
• Leaderboards — compete globally
• Daily rewards — free coins every day
• +50 Bonus Coins on first login"""

# Email form (built dynamically)
var _form      : Control = null
var _inp_email : LineEdit = null
var _inp_pass  : LineEdit = null
var _lbl_error : Label   = null
var _btn_submit: Button  = null
var _btn_toggle: Button  = null
var _is_signup : bool    = false   # false = sign-in, true = sign-up
var _inp_name  : LineEdit = null   # only visible in sign-up mode

func _ready() -> void:
	UIStyle.apply(self)
	if GameManager.login_required:
		_btn_skip.visible = false
		_lbl_benefits.text = "Level 4 and beyond require a free account.\n\nCreate one to:\n• Continue your jungle expedition\n• Keep progress safe across devices\n• Earn daily rewards & compete globally"
	else:
		_lbl_benefits.text = _BENEFITS
	_btn_google.pressed.connect(_on_google)
	_btn_email.pressed.connect(_on_email)
	_btn_skip.pressed.connect(_on_skip)
	SupabaseClient.auth_success.connect(_on_auth_success)
	SupabaseClient.auth_error.connect(_on_auth_error)

# ── Initial choice buttons ────────────────────────────────────────────────────

func _on_google() -> void:
	EventBus.play_sfx.emit("button")
	_show_status("Google login coming soon — use Email for now.", Color(1, 0.85, 0.3))

func _on_email() -> void:
	EventBus.play_sfx.emit("button")
	$Panel/VBox.visible = false
	_build_email_form()
	_form.visible = true

func _on_skip() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()

# ── Email form ────────────────────────────────────────────────────────────────

func _build_email_form() -> void:
	if _form != null:
		_form.visible = true
		return

	_form = VBoxContainer.new()
	_form.set_anchors_preset(Control.PRESET_FULL_RECT)
	_form.add_theme_constant_override("separation", 14)
	_form.position = Vector2(32, 160)
	_form.size     = Vector2(416, 0)
	$Panel.add_child(_form)

	# Title
	var title := Label.new()
	title.text = "Sign In"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.98, 0.86, 0.40))
	_form.add_child(title)
	_btn_toggle = Button.new()   # re-assign below; keep reference for title swap
	# store title ref so toggle can update it
	_btn_toggle.set_meta("title_ref", title)

	# Display name (sign-up only, hidden by default)
	_inp_name = LineEdit.new()
	_inp_name.placeholder_text = "Display name"
	_inp_name.custom_minimum_size = Vector2(0, 48)
	_inp_name.add_theme_font_size_override("font_size", 16)
	_inp_name.visible = false
	_form.add_child(_inp_name)

	# Email
	_inp_email = LineEdit.new()
	_inp_email.placeholder_text = "Email"
	_inp_email.custom_minimum_size = Vector2(0, 48)
	_inp_email.add_theme_font_size_override("font_size", 16)
	_form.add_child(_inp_email)

	# Password
	_inp_pass = LineEdit.new()
	_inp_pass.placeholder_text = "Password"
	_inp_pass.secret = true
	_inp_pass.custom_minimum_size = Vector2(0, 48)
	_inp_pass.add_theme_font_size_override("font_size", 16)
	_form.add_child(_inp_pass)

	# Error label
	_lbl_error = Label.new()
	_lbl_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_error.add_theme_color_override("font_color", Color(1, 0.42, 0.38))
	_lbl_error.add_theme_font_size_override("font_size", 13)
	_lbl_error.visible = false
	_form.add_child(_lbl_error)

	# Submit button
	_btn_submit = Button.new()
	_btn_submit.text = "Sign In"
	_btn_submit.custom_minimum_size = Vector2(0, 52)
	_btn_submit.add_theme_font_size_override("font_size", 18)
	_btn_submit.pressed.connect(_on_submit)
	_form.add_child(_btn_submit)

	# Toggle sign-in / sign-up
	_btn_toggle.text = "New here? Create account"
	_btn_toggle.flat = true
	_btn_toggle.add_theme_font_size_override("font_size", 13)
	_btn_toggle.add_theme_color_override("font_color", Color(0.70, 0.90, 0.62))
	_btn_toggle.pressed.connect(_on_toggle_mode)
	_form.add_child(_btn_toggle)

	# Back
	var btn_back := Button.new()
	btn_back.text = "← Back"
	btn_back.flat = true
	btn_back.add_theme_font_size_override("font_size", 13)
	btn_back.pressed.connect(_on_back_to_choices)
	_form.add_child(btn_back)

	# Status label (for google coming-soon message)
	var status_lbl := Label.new()
	status_lbl.name = "StatusLbl"
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.add_theme_font_size_override("font_size", 13)
	status_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	status_lbl.visible = false
	$Panel/VBox.add_child(status_lbl)

func _on_toggle_mode() -> void:
	_is_signup = not _is_signup
	_lbl_error.visible = false
	_inp_name.visible  = _is_signup
	var title_ref := _btn_toggle.get_meta("title_ref") as Label
	if _is_signup:
		title_ref.text    = "Create Account"
		_btn_submit.text  = "Sign Up"
		_btn_toggle.text  = "Already have an account? Sign in"
	else:
		title_ref.text    = "Sign In"
		_btn_submit.text  = "Sign In"
		_btn_toggle.text  = "New here? Create account"

func _on_back_to_choices() -> void:
	EventBus.play_sfx.emit("button")
	if _form:
		_form.visible = false
	$Panel/VBox.visible = true

func _on_submit() -> void:
	EventBus.play_sfx.emit("button")
	var email    := _inp_email.text.strip_edges()
	var password := _inp_pass.text

	if email.is_empty() or password.is_empty():
		_show_error("Please enter your email and password.")
		return
	if not "@" in email:
		_show_error("Enter a valid email address.")
		return
	if password.length() < 6:
		_show_error("Password must be at least 6 characters.")
		return

	_btn_submit.disabled = true
	_btn_submit.text     = "Please wait…"
	_lbl_error.visible   = false

	if _is_signup:
		var name := _inp_name.text.strip_edges()
		if name.is_empty():
			name = email.split("@")[0]
		SupabaseClient.sign_up(email, password, name)
	else:
		SupabaseClient.sign_in(email, password)

# ── Supabase callbacks ────────────────────────────────────────────────────────

func _on_auth_success(user_id: String, display_name: String) -> void:
	var is_new_login := not GameManager.is_logged_in
	GameManager.is_logged_in = true
	GameManager.is_guest     = false
	GameManager.player_name  = display_name
	if is_new_login:
		SaveManager.add_coins(50)
	EventBus.login_completed.emit(true)

	# Check if account has a pending deletion before proceeding
	SupabaseClient.check_deletion_status(func(deletion_date) -> void:
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

func _show_deletion_recovery(deletion_date: String) -> void:
	# User's account is scheduled for deletion — offer to cancel it
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.72)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var dw := 420.0; var dh := 300.0
	var dp := Panel.new()
	dp.position = Vector2((480.0 - dw) * 0.5, (854.0 - dh) * 0.5)
	dp.size     = Vector2(dw, dh)
	var dsb := StyleBoxFlat.new()
	dsb.bg_color = Color(0.04, 0.08, 0.04, 0.99)
	dsb.border_color = Color(0.76, 0.22, 0.14, 0.85)
	dsb.border_width_left = 2; dsb.border_width_right = 2
	dsb.border_width_top = 2; dsb.border_width_bottom = 2
	dsb.corner_radius_top_left = 10; dsb.corner_radius_top_right = 10
	dsb.corner_radius_bottom_left = 10; dsb.corner_radius_bottom_right = 10
	dp.add_theme_stylebox_override("panel", dsb)
	add_child(dp)

	var lbl_title := Label.new()
	lbl_title.text = "Account Pending Deletion"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 17)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 0.38, 0.28))
	lbl_title.size = Vector2(dw, 56); lbl_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dp.add_child(lbl_title)

	var lbl_body := Label.new()
	lbl_body.text = "You requested deletion of this account.\nIt will be permanently deleted after 14 days.\n\nWould you like to cancel and keep it?"
	lbl_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_body.add_theme_font_size_override("font_size", 12)
	lbl_body.add_theme_color_override("font_color", Color(0.90, 0.92, 0.84))
	lbl_body.size = Vector2(dw - 40.0, 110.0); lbl_body.position = Vector2(20.0, 60.0)
	lbl_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_body.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	dp.add_child(lbl_body)

	# Cancel deletion → keep account
	var btn_keep := Button.new()
	btn_keep.text       = "CANCEL DELETION — KEEP ACCOUNT"
	btn_keep.focus_mode = Control.FOCUS_NONE
	btn_keep.custom_minimum_size = Vector2(dw - 40.0, 46.0)
	btn_keep.position   = Vector2(20.0, 182.0)
	btn_keep.add_theme_font_size_override("font_size", 13)
	btn_keep.add_theme_color_override("font_color", Color(0.96, 0.82, 0.26))
	dp.add_child(btn_keep)
	btn_keep.pressed.connect(func():
		btn_keep.disabled = true
		SupabaseClient.cancel_deletion(func(_ok: bool) -> void:
			overlay.queue_free()
			dp.queue_free()
			_proceed_after_login()
		)
	)

	# Sign out → respect the deletion
	var btn_out := Button.new()
	btn_out.text       = "SIGN OUT"
	btn_out.focus_mode = Control.FOCUS_NONE
	btn_out.custom_minimum_size = Vector2(dw - 40.0, 46.0)
	btn_out.position   = Vector2(20.0, 238.0)
	btn_out.flat       = true
	btn_out.add_theme_font_size_override("font_size", 13)
	btn_out.add_theme_color_override("font_color", Color(0.46, 0.48, 0.40))
	dp.add_child(btn_out)
	btn_out.pressed.connect(func():
		SupabaseClient.sign_out()
		GameManager.is_logged_in = false
		GameManager.is_guest     = true
		GameManager.player_name  = "Explorer"
		overlay.queue_free()
		dp.queue_free()
		GameManager.go_to_menu()
	)

func _on_auth_error(message: String) -> void:
	_btn_submit.disabled = false
	_btn_submit.text     = "Sign Up" if _is_signup else "Sign In"
	_show_error(message)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _show_error(msg: String) -> void:
	_lbl_error.text    = msg
	_lbl_error.visible = true

func _show_status(msg: String, color: Color) -> void:
	var lbl := $Panel/VBox.get_node_or_null("StatusLbl") as Label
	if lbl == null:
		return
	lbl.text               = msg
	lbl.modulate           = color
	lbl.visible            = true
	get_tree().create_timer(3.0).timeout.connect(func(): if is_instance_valid(lbl): lbl.visible = false)
