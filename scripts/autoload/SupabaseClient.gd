extends Node

# ── Config (fill these in after creating your Supabase project) ───────────────
# Dashboard → Project Settings → API
const _URL := ""   # e.g. "https://abcdefgh.supabase.co"
const _KEY := ""   # anon / public key

# ── Signals ───────────────────────────────────────────────────────────────────
signal auth_success(user_id: String, display_name: String)
signal auth_error(message: String)
signal sync_done
signal sync_error(message: String)

# ── State ─────────────────────────────────────────────────────────────────────
var _access_token  := ""
var _refresh_token := ""
var _user_id       := ""
var _display_name  := ""
var _expires_at    := 0   # unix timestamp when access token expires

func _ready() -> void:
	_load_tokens()

# ── Public checks ─────────────────────────────────────────────────────────────

func is_authenticated() -> bool:
	return not _user_id.is_empty() and not _access_token.is_empty()

func get_user_id() -> String:
	return _user_id

func get_display_name() -> String:
	return _display_name

# ── Auth ──────────────────────────────────────────────────────────────────────

func sign_up(email: String, password: String, display_name: String) -> void:
	_post("/auth/v1/signup", {
		"email": email,
		"password": password,
		"data": {"display_name": display_name}
	}, _on_auth_response.bind(display_name))

func sign_in(email: String, password: String) -> void:
	_post("/auth/v1/token?grant_type=password", {
		"email": email,
		"password": password
	}, _on_auth_response.bind(""))

func sign_out() -> void:
	if is_authenticated():
		_http("POST", "/auth/v1/logout", {}, [], func(_r): pass)
	_clear_tokens()

func _on_auth_response(result: Variant, fallback_name: String) -> void:
	if result is Dictionary:
		var err := str(result.get("error_description", result.get("msg", result.get("error", ""))))
		if not err.is_empty() and err != "null":
			auth_error.emit(err)
			return
		var token := str(result.get("access_token", ""))
		if token.is_empty():
			auth_error.emit("No token in response — check email confirmation is disabled in Supabase.")
			return
		var user: Dictionary = result.get("user", {})
		_access_token  = token
		_refresh_token = str(result.get("refresh_token", ""))
		_user_id       = str(user.get("id", ""))
		var meta: Dictionary = user.get("user_metadata", {})
		_display_name  = str(meta.get("display_name", fallback_name if not fallback_name.is_empty() else str(user.get("email", "Explorer"))))
		_expires_at    = int(Time.get_unix_time_from_system()) + int(result.get("expires_in", 3600)) - 60
		_save_tokens()
		auth_success.emit(_user_id, _display_name)
	else:
		auth_error.emit("Unexpected server response")

func _refresh_if_needed(then: Callable) -> void:
	if _refresh_token.is_empty() or int(Time.get_unix_time_from_system()) < _expires_at:
		then.call()
		return
	_post("/auth/v1/token?grant_type=refresh_token", {"refresh_token": _refresh_token},
		func(r):
			var tok := str(r.get("access_token", "")) if r is Dictionary else ""
			if not tok.is_empty():
				_access_token  = tok
				_refresh_token = str(r.get("refresh_token", _refresh_token))
				_expires_at    = int(Time.get_unix_time_from_system()) + int(r.get("expires_in", 3600)) - 60
				_save_tokens()
			then.call()
	)

# ── Cloud Save ────────────────────────────────────────────────────────────────

func upload_save(data: Dictionary) -> void:
	if not is_authenticated() or _URL.is_empty():
		return
	_refresh_if_needed(func():
		var body := {
			"id":               _user_id,
			"display_name":     _display_name,
			"coins":            data.get("coins", 0),
			"gems":             data.get("gems", 0),
			"hints":            data.get("hints", 3),
			"current_level":    data.get("current_level", 1),
			"completed_levels": data.get("completed_levels", []),
			"stars":            data.get("stars", {}),
			"selected_skin":    data.get("selected_skin", "explorer"),
			"unlocked_skins":   data.get("unlocked_skins", ["explorer"]),
			"resources":        data.get("resources", {}),
			"upgrades":         data.get("upgrades", []),
			"home_stage":       data.get("home_stage", 0),
			"updated_at":       Time.get_datetime_string_from_system(true).replace(" ", "T") + "Z",
		}
		_http("POST", "/rest/v1/save_data", body,
			["Prefer: resolution=merge-duplicates"],
			func(r):
				if r is Dictionary and r.get("message") != null:
					sync_error.emit(str(r.get("message", "Sync failed")))
				else:
					sync_done.emit()
		)
	)

func download_save(callback: Callable) -> void:
	if not is_authenticated() or _URL.is_empty():
		callback.call({})
		return
	_refresh_if_needed(func():
		_http("GET", "/rest/v1/save_data?id=eq." + _user_id + "&select=*", {}, [],
			func(r):
				if r is Array and r.size() > 0:
					callback.call(r[0])
				else:
					callback.call({})
		)
	)

# ── HTTP helpers ──────────────────────────────────────────────────────────────

func _post(endpoint: String, body: Dictionary, callback: Callable) -> void:
	_http("POST", endpoint, body, [], callback)

func _http(method_str: String, endpoint: String, body: Dictionary,
		extra_headers: Array, callback: Callable) -> void:
	if _URL.is_empty() or _KEY.is_empty():
		# Silently skip — backend not configured yet
		callback.call({})
		return

	var http := HTTPRequest.new()
	add_child(http)

	var headers := PackedStringArray([
		"Content-Type: application/json",
		"apikey: " + _KEY,
	])
	if not _access_token.is_empty():
		headers.append("Authorization: Bearer " + _access_token)
	for h: String in extra_headers:
		headers.append(h)

	var method_enum := HTTPClient.METHOD_GET if method_str == "GET" else HTTPClient.METHOD_POST
	var body_str    := "" if body.is_empty() else JSON.stringify(body)

	http.request_completed.connect(func(_res: int, _code: int, _hdrs: PackedStringArray, response: PackedByteArray):
		http.queue_free()
		var text := response.get_string_from_utf8()
		var parsed: Variant = {}
		if not text.is_empty():
			var j := JSON.new()
			if j.parse(text) == OK:
				parsed = j.get_data()
		callback.call(parsed)
	)
	var err := http.request(_URL + endpoint, headers, method_enum, body_str)
	if err != OK:
		http.queue_free()
		callback.call({})

# ── Token persistence ─────────────────────────────────────────────────────────

func _save_tokens() -> void:
	var f := FileAccess.open("user://auth_token.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"access_token":  _access_token,
			"refresh_token": _refresh_token,
			"user_id":       _user_id,
			"display_name":  _display_name,
			"expires_at":    _expires_at,
		}))

func _load_tokens() -> void:
	if not FileAccess.file_exists("user://auth_token.json"):
		return
	var f := FileAccess.open("user://auth_token.json", FileAccess.READ)
	if not f:
		return
	var j := JSON.new()
	if j.parse(f.get_as_text()) != OK:
		return
	var d: Dictionary = j.get_data()
	_access_token  = str(d.get("access_token",  ""))
	_refresh_token = str(d.get("refresh_token", ""))
	_user_id       = str(d.get("user_id",       ""))
	_display_name  = str(d.get("display_name",  ""))
	_expires_at    = int(d.get("expires_at",     0))

func _clear_tokens() -> void:
	_access_token = ""; _refresh_token = ""; _user_id = ""; _display_name = ""; _expires_at = 0
	if FileAccess.file_exists("user://auth_token.json"):
		DirAccess.remove_absolute("user://auth_token.json")
