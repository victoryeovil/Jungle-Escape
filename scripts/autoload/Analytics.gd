extends Node

# Anonymous play-event tracker.
# Sends structured events to Supabase so level designers can see
# exactly where players fail, how long levels take, and what's too hard.
#
# Fill in URL and KEY after running supabase_schema.sql.
# Leave them empty and nothing is sent — game works 100% offline.

const SUPABASE_URL := ""   # e.g. "https://abcdefgh.supabase.co"
const SUPABASE_KEY := ""   # anon / public key (INSERT-only policy — safe to ship)

const FLUSH_INTERVAL := 30.0   # seconds between automatic batch sends
const MAX_QUEUE     := 20      # force-flush when queue hits this size
const QUEUE_PATH    := "user://analytics_queue.json"
const DEVICE_ID_PATH := "user://device_id.json"

var _device_id  := ""
var _session_id := ""
var _queue: Array = []
var _timer  := 0.0
var _flushing := false

func _ready() -> void:
	_device_id  = _load_or_create_device_id()
	_session_id = "%d_%d" % [int(Time.get_unix_time_from_system()), randi()]
	_load_queue()
	# Report this session so we get daily-active counts
	event("session_start", {
		"app_version": "1.0",
		"platform": OS.get_name().to_lower(),
	})

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= FLUSH_INTERVAL:
		_timer = 0.0
		_flush()

# ── Public event API ──────────────────────────────────────────────────────────
# Call these from GameManager; payload keys must match supabase_schema.sql comments.

func event(type: String, payload: Dictionary = {}) -> void:
	_queue.append({
		"device_id":  _device_id,
		"session_id": _session_id,
		"event_type": type,
		"payload":    payload,
	})
	_save_queue()
	if _queue.size() >= MAX_QUEUE:
		_flush()

# Convenience wrappers so call-sites stay readable
func level_start(level_id: int, character: String, attempt: int) -> void:
	event("level_start", {"level_id": level_id, "character": character, "attempt": attempt})

func level_complete(level_id: int, stars: int, coins: int, time_sec: float, attempt: int) -> void:
	event("level_complete", {
		"level_id": level_id, "stars": stars,
		"coins": coins, "time_sec": snappedf(time_sec, 0.1), "attempt": attempt,
	})

func level_fail(level_id: int, fail_reason: String, row_reached: int, time_sec: float, attempt: int) -> void:
	event("level_fail", {
		"level_id": level_id, "fail_reason": fail_reason,
		"row_reached": row_reached, "time_sec": snappedf(time_sec, 0.1), "attempt": attempt,
	})

func obstacle_hit(level_id: int, obstacle_type: String, row: int, lane: int) -> void:
	event("obstacle_hit", {"level_id": level_id, "obstacle_type": obstacle_type, "row": row, "lane": lane})

func resource_pick(level_id: int, resource_type: String, row: int) -> void:
	event("resource_pick", {"level_id": level_id, "resource_type": resource_type, "row": row})

# ── HTTP flush ────────────────────────────────────────────────────────────────

func _flush() -> void:
	if _queue.is_empty() or _flushing or SUPABASE_URL.is_empty() or SUPABASE_KEY.is_empty():
		return
	_flushing = true
	var batch := _queue.duplicate()
	_queue.clear()
	_save_queue()

	var req := HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(func(_result, code, _headers, _body):
		_flushing = false
		req.queue_free()
		if code < 200 or code >= 300:
			# Re-queue the batch so nothing is lost
			for ev in batch:
				_queue.push_front(ev)
			_save_queue()
	)

	var headers := PackedStringArray([
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Prefer: return=minimal",
	])
	req.request(
		SUPABASE_URL + "/rest/v1/game_events",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(batch)
	)

# ── Persistence helpers ───────────────────────────────────────────────────────

func _load_or_create_device_id() -> String:
	if FileAccess.file_exists(DEVICE_ID_PATH):
		var f := FileAccess.open(DEVICE_ID_PATH, FileAccess.READ)
		if f:
			var r = JSON.parse_string(f.get_as_text())
			f.close()
			if r is Dictionary and r.has("id"):
				return str(r["id"])
	# First launch: generate a random anonymous ID (no personal data)
	var new_id := "d%d%d" % [int(Time.get_unix_time_from_system()), randi() % 100000]
	var f := FileAccess.open(DEVICE_ID_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"id": new_id}))
		f.close()
	return new_id

func _save_queue() -> void:
	var f := FileAccess.open(QUEUE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_queue))
		f.close()

func _load_queue() -> void:
	if not FileAccess.file_exists(QUEUE_PATH):
		return
	var f := FileAccess.open(QUEUE_PATH, FileAccess.READ)
	if f:
		var r = JSON.parse_string(f.get_as_text())
		f.close()
		if r is Array:
			_queue = r
