extends RefCounted
class_name LevelLoader

# Loads level JSON files and returns structured level data.

const LEVELS_PATH := "res://data/levels/"

static func load_level(level_id: int) -> Dictionary:
	var path := LEVELS_PATH + "level_%03d.json" % level_id
	if not FileAccess.file_exists(path):
		push_error("LevelLoader: level file not found: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("LevelLoader: cannot open " + path)
		return {}
	var text := file.get_as_text()
	file.close()
	var data: Variant = JSON.parse_string(text)
	if not data is Dictionary:
		push_error("LevelLoader: invalid JSON in " + path)
		return {}
	return data

# Returns how many levels exist on disk
static func count_levels() -> int:
	var count := 0
	for i in range(1, 101):
		var p := LEVELS_PATH + "level_%03d.json" % i
		if FileAccess.file_exists(p):
			count += 1
		else:
			break
	return count
