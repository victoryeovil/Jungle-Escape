extends Node

# ── Config (fill after creating your Supabase project) ────────────────────────
# Dashboard → Project Settings → API
const _URL := "http://192.168.1.67:54321"
const _KEY := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzQxODI0MDAwLCJleHAiOjE4OTk1OTA0MDB9.rdpDFdPRK_GXBl2XJ0IxMQbFd8kRPm4EnDVFsDVy5jA"

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

const _REG_KEY_PATH := "user://registration_key.json"

const _OAUTH_PORT := 9876   # local redirect listener

var _oauth_server  : TCPServer = null
var _oauth_timeout : float     = 0.0

func _ready() -> void:
	_load_tokens()

func _process(delta: float) -> void:
	if _oauth_server == null or not _oauth_server.is_listening():
		return
	_oauth_timeout -= delta
	if _oauth_timeout <= 0.0:
		_oauth_server.stop()
		_oauth_server = null
		auth_error.emit("Google sign-in timed out. Please try again.")
		return
	if not _oauth_server.is_connection_available():
		return
	var peer := _oauth_server.take_connection()
	if peer == null:
		return
	# Read the HTTP request line
	var raw := ""
	var deadline := Time.get_ticks_msec() + 1000
	while peer.get_status() == StreamPeerTCP.STATUS_CONNECTED and Time.get_ticks_msec() < deadline:
		var avail := peer.get_available_bytes()
		if avail > 0:
			raw += peer.get_string(avail)
			if "\r\n\r\n" in raw:
				break
	var request_line := raw.split("\r\n")[0] if raw.length() > 0 else ""
	if "/token?" in request_line:
		# Second leg — browser sent real params via JS redirect
		var qs := request_line.split("?")[1].split(" ")[0] if "?" in request_line else ""
		var params := _parse_qs(qs)
		var at  := params.get("access_token",  "")
		var rt  := params.get("refresh_token", "")
		var uid := params.get("user_id",       "")
		_serve_peer(peer, "<h1 style='font-family:sans-serif;color:#2d7a2d'>Login successful! Return to the game.</h1>")
		_oauth_server.stop()
		_oauth_server = null
		if not at.is_empty():
			_complete_oauth(at, rt, uid)
		else:
			auth_error.emit("Google sign-in failed — no token received.")
	else:
		# First leg — browser lands here with fragment; serve JS that forwards it
		var html := """<!DOCTYPE html><html><head><meta charset='utf-8'>
<style>body{font-family:sans-serif;text-align:center;margin-top:80px;color:#444}</style>
</head><body><p>Completing sign-in…</p>
<script>
var h=window.location.hash.slice(1);
var p=new URLSearchParams(h);
var q=new URLSearchParams(window.location.search);
var at=p.get('access_token')||q.get('access_token')||'';
var rt=p.get('refresh_token')||q.get('refresh_token')||'';
if(at){window.location.href='/token?access_token='+at+'&refresh_token='+rt;}
else{document.body.innerHTML='<p style=color:red>Sign-in failed — no token. Close this window and try again.</p>';}
</script></body></html>"""
		_serve_peer(peer, html)

func sign_in_google() -> void:
	if _oauth_server != null:
		return  # already waiting
	_oauth_server = TCPServer.new()
	var err := _oauth_server.listen(_OAUTH_PORT, "127.0.0.1")
	if err != OK:
		auth_error.emit("Could not start local auth server (port %d in use?)." % _OAUTH_PORT)
		_oauth_server = null
		return
	_oauth_timeout = 300.0  # 5 minute window
	var redirect := "http://localhost:%d" % _OAUTH_PORT
	var url := "%s/auth/v1/authorize?provider=google&redirect_to=%s" % [_URL, redirect]
	OS.shell_open(url)

func _complete_oauth(access_token: String, refresh_token: String, _uid_hint: String) -> void:
	# Exchange/verify the token to get full user info
	_access_token  = access_token
	_refresh_token = refresh_token
	_expires_at    = int(Time.get_unix_time_from_system()) + 3600 - 60
	_http("GET", "/auth/v1/user", {}, [], func(r: Variant) -> void:
		if r is Dictionary and r.has("id"):
			_user_id      = str(r.get("id", ""))
			var meta: Dictionary = r.get("user_metadata", {})
			_display_name = str(meta.get("full_name", meta.get("name", meta.get("display_name",
								str(r.get("email", "Explorer"))))))
			_save_tokens()
			_save_registration_key()
			_ensure_account_row()
			auth_success.emit(_user_id, _display_name)
		else:
			_clear_tokens()
			auth_error.emit("Could not fetch user info after Google sign-in.")
	)

func _serve_peer(peer: StreamPeerTCP, body: String) -> void:
	var resp := "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\nContent-Length: %d\r\n\r\n%s" % [body.length(), body]
	peer.put_data(resp.to_utf8_buffer())

func _parse_qs(qs: String) -> Dictionary:
	var out := {}
	for pair in qs.split("&"):
		var kv := pair.split("=")
		if kv.size() == 2:
			out[kv[0]] = kv[1].uri_decode()
	return out

# Returns true even when offline — proves the user registered at some point.
static func has_registration_key() -> bool:
	if not FileAccess.file_exists("user://registration_key.json"):
		return false
	var f := FileAccess.open("user://registration_key.json", FileAccess.READ)
	if not f:
		return false
	var r = JSON.parse_string(f.get_as_text())
	f.close()
	return r is Dictionary and bool(r.get("registered", false))

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
	if not result is Dictionary:
		auth_error.emit("Unexpected server response")
		return
	var err := str(result.get("error_description", result.get("msg", result.get("error", ""))))
	if not err.is_empty() and err != "null":
		auth_error.emit(err)
		return
	var token := str(result.get("access_token", ""))
	if token.is_empty():
		auth_error.emit("No token received — check that email confirmation is disabled in Supabase Auth settings.")
		return
	var user: Dictionary = result.get("user", {})
	_access_token  = token
	_refresh_token = str(result.get("refresh_token", ""))
	_user_id       = str(user.get("id", ""))
	var meta: Dictionary = user.get("user_metadata", {})
	_display_name  = str(meta.get("display_name", fallback_name if not fallback_name.is_empty() else str(user.get("email", "Explorer"))))
	_expires_at    = int(Time.get_unix_time_from_system()) + int(result.get("expires_in", 3600)) - 60
	_save_tokens()
	_save_registration_key()
	_ensure_account_row()
	auth_success.emit(_user_id, _display_name)

func _refresh_if_needed(then: Callable) -> void:
	if _refresh_token.is_empty() or int(Time.get_unix_time_from_system()) < _expires_at:
		then.call()
		return
	_post("/auth/v1/token?grant_type=refresh_token", {"refresh_token": _refresh_token},
		func(r):
			if r is Dictionary:
				var tok := str(r.get("access_token", ""))
				if not tok.is_empty():
					_access_token  = tok
					_refresh_token = str(r.get("refresh_token", _refresh_token))
					_expires_at    = int(Time.get_unix_time_from_system()) + int(r.get("expires_in", 3600)) - 60
					_save_tokens()
			then.call()
	)

# ── Cloud save (cross-device progress backup) ─────────────────────────────────

func upload_save(data: Dictionary) -> void:
	if not is_authenticated() or _URL.is_empty():
		return
	_refresh_if_needed(func():
		_http("POST", "/rest/v1/cloud_saves",
			{"user_id": _user_id, "save_json": data},
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
		_http("GET", "/rest/v1/cloud_saves?user_id=eq." + _user_id + "&select=save_json",
			{}, [],
			func(r):
				if r is Array and r.size() > 0:
					var save_json = r[0].get("save_json", {})
					callback.call(save_json if save_json is Dictionary else {})
				else:
					callback.call({})
		)
	)

# ── Account row (created/refreshed on every login) ────────────────────────────

func _ensure_account_row() -> void:
	if not is_authenticated() or _URL.is_empty():
		return
	_refresh_if_needed(func():
		_http("POST", "/rest/v1/user_accounts",
			{"id": _user_id, "display_name": _display_name},
			["Prefer: resolution=merge-duplicates"],
			func(_r): pass
		)
	)

# ── Account deletion (14-day grace window) ────────────────────────────────────

# Returns the ISO timestamp of deletion_requested_at (String), or null if active.
func check_deletion_status(callback: Callable) -> void:
	if not is_authenticated() or _URL.is_empty():
		callback.call(null)
		return
	_refresh_if_needed(func():
		_http("GET",
			"/rest/v1/user_accounts?id=eq." + _user_id + "&select=deletion_requested_at",
			{}, [],
			func(r):
				if r is Array and r.size() > 0:
					callback.call(r[0].get("deletion_requested_at", null))
				else:
					callback.call(null)
		)
	)

# Schedules the account for deletion.  User has 14 days to cancel.
func request_deletion(callback: Callable) -> void:
	if not is_authenticated() or _URL.is_empty():
		callback.call(false)
		return
	_refresh_if_needed(func():
		var now := Time.get_datetime_string_from_system(true).replace(" ", "T") + "Z"
		_http("PATCH",
			"/rest/v1/user_accounts?id=eq." + _user_id,
			{"deletion_requested_at": now},
			["Prefer: return=minimal"],
			func(_r): callback.call(true)
		)
	)

# Cancels a pending deletion — reactivates the account.
func cancel_deletion(callback: Callable) -> void:
	if not is_authenticated() or _URL.is_empty():
		callback.call(false)
		return
	_refresh_if_needed(func():
		_http("PATCH",
			"/rest/v1/user_accounts?id=eq." + _user_id,
			{"deletion_requested_at": null},
			["Prefer: return=minimal"],
			func(_r): callback.call(true)
		)
	)

# ── HTTP helpers ──────────────────────────────────────────────────────────────

func _post(endpoint: String, body: Dictionary, callback: Callable) -> void:
	_http("POST", endpoint, body, [], callback)

func _http(method_str: String, endpoint: String, body: Variant,
		extra_headers: Array, callback: Callable) -> void:
	if _URL.is_empty() or _KEY.is_empty():
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

	var method_enum: int
	match method_str:
		"GET":    method_enum = HTTPClient.METHOD_GET
		"PATCH":  method_enum = HTTPClient.METHOD_PATCH
		"DELETE": method_enum = HTTPClient.METHOD_DELETE
		_:        method_enum = HTTPClient.METHOD_POST

	var body_str := ""
	if body != null and ((body is Dictionary and not body.is_empty()) or body is Array):
		body_str = JSON.stringify(body)

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
		f.close()

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

func _save_registration_key() -> void:
	var f := FileAccess.open(_REG_KEY_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"registered": true}))
		f.close()

func _clear_tokens() -> void:
	_access_token = ""; _refresh_token = ""; _user_id = ""; _display_name = ""; _expires_at = 0
	if FileAccess.file_exists("user://auth_token.json"):
		DirAccess.remove_absolute("user://auth_token.json")
	if FileAccess.file_exists(_REG_KEY_PATH):
		DirAccess.remove_absolute(_REG_KEY_PATH)
