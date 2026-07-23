extends Node

# Kept under the old autoload name so existing scenes do not need to change.
# Override this setting for release builds with your deployed HTTPS API URL.
const DEFAULT_API_URL := "http://127.0.0.1:8000"
const TOKEN_PATH := "user://auth_token.json"
const REG_KEY_PATH := "user://registration_key.json"

signal auth_success(user_id: String, display_name: String)
signal auth_error(message: String)
signal sync_done
signal sync_error(message: String)

var _access_token := ""
var _refresh_token := ""
var _user_id := ""
var _display_name := ""
var _expires_at := 0
var _oauth_state := ""
var _oauth_elapsed := 0.0
var _oauth_polling := false

func _ready() -> void:
	_load_tokens()

func _process(delta: float) -> void:
	if _oauth_state.is_empty() or _oauth_polling:
		return
	_oauth_elapsed += delta
	if _oauth_elapsed >= 2.0:
		_oauth_elapsed = 0.0
		_oauth_polling = true
		_request("GET", "/api/v1/auth/google/poll/" + _oauth_state.uri_encode() + "/", null, func(code: int, data: Variant):
			_oauth_polling = false
			if code == 200 and data is Dictionary and str(data.get("status", "")) == "complete":
				_oauth_state = ""
				_accept_tokens(data)
			elif code == 410:
				_oauth_state = ""
				auth_error.emit("Google sign-in expired. Please try again.")
		, false)

func _api_url() -> String:
	return str(ProjectSettings.get_setting("jungle_escape/backend_url", DEFAULT_API_URL)).trim_suffix("/")

static func has_registration_key() -> bool:
	return FileAccess.file_exists(REG_KEY_PATH)

func is_authenticated() -> bool:
	return not _access_token.is_empty() and not _user_id.is_empty()

func get_user_id() -> String:
	return _user_id

func sign_up(email: String, password: String, display_name: String) -> void:
	_request("POST", "/api/v1/auth/register/", {"email": email, "password": password, "display_name": display_name}, _auth_response, false)

func sign_in(email: String, password: String) -> void:
	_request("POST", "/api/v1/auth/login/", {"email": email, "password": password}, _auth_response, false)

func sign_in_google() -> void:
	_request("POST", "/api/v1/auth/google/start/", {}, func(code: int, data: Variant):
		if code != 200 or not data is Dictionary:
			auth_error.emit(_error_message(data, "Google sign-in is unavailable."))
			return
		_oauth_state = str(data.get("state", ""))
		_oauth_elapsed = 0.0
		if _oauth_state.is_empty() or OS.shell_open(str(data.get("authorization_url", ""))) != OK:
			_oauth_state = ""
			auth_error.emit("Could not open Google sign-in.")
	, false)

func sign_out() -> void:
	_clear_tokens()

func upload_save(data: Dictionary) -> void:
	_authenticated_request("PUT", "/api/v1/save/", {"save_json": data}, func(code: int, result: Variant):
		if code >= 200 and code < 300:
			sync_done.emit()
		else:
			sync_error.emit(_error_message(result, "Cloud save failed.")))

func download_save(callback: Callable) -> void:
	if not is_authenticated():
		callback.call({})
		return
	_authenticated_request("GET", "/api/v1/save/", null, func(code: int, data: Variant):
		callback.call(data.get("save_json", {}) if code == 200 and data is Dictionary else {}))

func submit_endless_score(distance_m: int) -> void:
	if is_authenticated() and distance_m > 0:
		_authenticated_request("POST", "/api/v1/scores/endless/", {"best_distance_m": distance_m}, func(_c, _d): pass)

func fetch_endless_top(limit: int, callback: Callable) -> void:
	_request("GET", "/api/v1/leaderboards/endless/?limit=" + str(limit), null, func(code: int, data: Variant):
		callback.call(data if code == 200 and data is Array else []), false)

static func week_key(weeks_ago: int = 0) -> String:
	return "W" + str(int((Time.get_unix_time_from_system() + 4 * 86400) / 604800) - weeks_ago)

func submit_weekly_score(distance_m: int) -> void:
	if is_authenticated() and distance_m > 0:
		_authenticated_request("POST", "/api/v1/scores/weekly/", {"week_key": week_key(), "best_distance_m": distance_m}, func(_c, _d): pass)

func fetch_weekly_top(week: String, limit: int, callback: Callable) -> void:
	_request("GET", "/api/v1/leaderboards/weekly/" + week.uri_encode() + "/?limit=" + str(limit), null, func(code: int, data: Variant):
		callback.call(data if code == 200 and data is Array else []), false)

func check_deletion_status(callback: Callable) -> void:
	_authenticated_request("GET", "/api/v1/me/", null, func(code: int, data: Variant):
		callback.call(data.get("deletion_requested_at", null) if code == 200 and data is Dictionary else null))

func request_deletion(callback: Callable) -> void:
	_authenticated_request("POST", "/api/v1/me/deletion/", {}, func(code: int, _data: Variant): callback.call(code == 200))

func cancel_deletion(callback: Callable) -> void:
	_authenticated_request("DELETE", "/api/v1/me/deletion/", null, func(code: int, _data: Variant): callback.call(code == 200))

func send_events(events: Array, callback: Callable = Callable()) -> void:
	_request("POST", "/api/v1/events/", events, func(code: int, _data: Variant):
		if callback.is_valid(): callback.call(code >= 200 and code < 300), is_authenticated())

func _auth_response(code: int, data: Variant) -> void:
	if code >= 200 and code < 300 and data is Dictionary:
		_accept_tokens(data)
	else:
		auth_error.emit(_error_message(data, "Sign-in failed."))

func _accept_tokens(data: Dictionary) -> void:
	var user: Dictionary = data.get("user", {})
	_access_token = str(data.get("access", ""))
	_refresh_token = str(data.get("refresh", ""))
	_user_id = str(user.get("id", ""))
	_display_name = str(user.get("display_name", user.get("email", "Explorer")))
	_expires_at = int(Time.get_unix_time_from_system()) + 25 * 60
	if _access_token.is_empty() or _user_id.is_empty():
		auth_error.emit("The server returned an incomplete login response.")
		return
	_save_tokens()
	_save_registration_key()
	auth_success.emit(_user_id, _display_name)

func _authenticated_request(method: String, endpoint: String, body: Variant, callback: Callable) -> void:
	if not is_authenticated():
		callback.call(401, {"error": "Sign in required."})
		return
	if int(Time.get_unix_time_from_system()) < _expires_at or _refresh_token.is_empty():
		_request(method, endpoint, body, callback, true)
		return
	_request("POST", "/api/v1/auth/refresh/", {"refresh": _refresh_token}, func(code: int, data: Variant):
		if code == 200 and data is Dictionary and not str(data.get("access", "")).is_empty():
			_access_token = str(data.get("access"))
			_refresh_token = str(data.get("refresh", _refresh_token))
			_expires_at = int(Time.get_unix_time_from_system()) + 25 * 60
			_save_tokens()
			_request(method, endpoint, body, callback, true)
		else:
			_clear_tokens()
			callback.call(401, data)
	, false)

func _request(method: String, endpoint: String, body: Variant, callback: Callable, authenticated := true) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	var headers := PackedStringArray(["Content-Type: application/json"])
	if authenticated and not _access_token.is_empty(): headers.append("Authorization: Bearer " + _access_token)
	var method_enum := HTTPClient.METHOD_GET
	match method:
		"POST": method_enum = HTTPClient.METHOD_POST
		"PUT": method_enum = HTTPClient.METHOD_PUT
		"DELETE": method_enum = HTTPClient.METHOD_DELETE
	var body_text := "" if body == null else JSON.stringify(body)
	http.request_completed.connect(func(_result: int, code: int, _headers: PackedStringArray, response: PackedByteArray):
		http.queue_free()
		var parsed: Variant = {}
		if not response.is_empty():
			var decoded = JSON.parse_string(response.get_string_from_utf8())
			parsed = decoded if decoded != null else {}
		callback.call(code, parsed))
	var error := http.request(_api_url() + endpoint, headers, method_enum, body_text)
	if error != OK:
		http.queue_free()
		callback.call(0, {"error": "Could not connect to the game server."})

func _error_message(data: Variant, fallback: String) -> String:
	return str(data.get("error", data.get("detail", fallback))) if data is Dictionary else fallback

func _save_tokens() -> void:
	var file := FileAccess.open(TOKEN_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"access": _access_token, "refresh": _refresh_token, "user_id": _user_id, "display_name": _display_name, "expires_at": _expires_at}))

func _load_tokens() -> void:
	if not FileAccess.file_exists(TOKEN_PATH): return
	var file := FileAccess.open(TOKEN_PATH, FileAccess.READ)
	if not file: return
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		_access_token = str(data.get("access", "")); _refresh_token = str(data.get("refresh", ""))
		_user_id = str(data.get("user_id", "")); _display_name = str(data.get("display_name", "")); _expires_at = int(data.get("expires_at", 0))

func _save_registration_key() -> void:
	var file := FileAccess.open(REG_KEY_PATH, FileAccess.WRITE)
	if file: file.store_string("{\"registered\":true}")

func _clear_tokens() -> void:
	_access_token = ""; _refresh_token = ""; _user_id = ""; _display_name = ""; _expires_at = 0
	if FileAccess.file_exists(TOKEN_PATH): DirAccess.remove_absolute(TOKEN_PATH)
	if FileAccess.file_exists(REG_KEY_PATH): DirAccess.remove_absolute(REG_KEY_PATH)
