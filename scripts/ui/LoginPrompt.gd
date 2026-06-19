extends Control

# Shown as a soft-prompt after completing a few levels.
# Never blocks gameplay — has a clear "Maybe Later" button.

@onready var btn_google: Button  = $Panel/VBox/BtnGoogle
@onready var btn_email: Button   = $Panel/VBox/BtnEmail
@onready var btn_skip: Button    = $Panel/VBox/BtnSkip
@onready var lbl_benefits: Label = $Panel/VBox/LblBenefits

const BENEFITS_TEXT := """Log in to unlock:
• Cloud save — never lose progress
• Leaderboards — compete globally
• Daily rewards — free coins every day
• Friend challenges — beat your friends
• +50 Bonus Coins on first login"""

func _ready() -> void:
	UIStyle.apply(self)
	lbl_benefits.text = BENEFITS_TEXT
	btn_google.pressed.connect(_on_google_login)
	btn_email.pressed.connect(_on_email_login)
	btn_skip.pressed.connect(_on_skip)

func _on_google_login() -> void:
	EventBus.play_sfx.emit("button")
	# TODO: Integrate Firebase Auth / Google Sign-In plugin
	# For now, simulate a successful login
	_simulate_login("Google Player")

func _on_email_login() -> void:
	EventBus.play_sfx.emit("button")
	# TODO: Show email/password form
	_simulate_login("Email Player")

func _simulate_login(name: String) -> void:
	GameManager.is_logged_in = true
	GameManager.is_guest = false
	GameManager.player_name = name
	SaveManager.add_coins(50)
	EventBus.login_completed.emit(true)
	GameManager.go_to_menu()

func _on_skip() -> void:
	EventBus.play_sfx.emit("button")
	GameManager.go_to_menu()
