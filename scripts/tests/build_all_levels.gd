extends Node

# Headless smoke test: builds every level through the real LevelManager3D and
# reports node/draw statistics. Autoloads are available because this runs as a
# normal scene:
#   godot --headless --path . res://scenes/tests/BuildAllLevels.tscn

const LEVEL_PATH := "res://data/levels3d/level3d_%03d.json"

func _ready() -> void:
	var failures := 0
	for level_id in range(1, 21):
		var path := LEVEL_PATH % level_id
		if not FileAccess.file_exists(path):
			print("MISSING  level %d" % level_id)
			failures += 1
			continue
		var file := FileAccess.open(path, FileAccess.READ)
		var data: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if not (data is Dictionary):
			print("BADJSON  level %d" % level_id)
			failures += 1
			continue

		var mgr := LevelManager3D.new()
		add_child(mgr)
		var t0 := Time.get_ticks_msec()
		mgr.build(data)
		var build_ms := Time.get_ticks_msec() - t0

		var stats := {"nodes": 0, "mesh": 0, "multimesh": 0, "mm_instances": 0, "areas": 0, "bodies": 0}
		_walk(mgr, stats)
		print("OK  level %2d  len=%3d  build=%4dms  nodes=%5d  meshinst=%4d  multimesh=%2d (x%4d)  areas=%3d  bodies=%3d" % [
			level_id, int(data.get("length", 0)), build_ms,
			stats["nodes"], stats["mesh"], stats["multimesh"], stats["mm_instances"],
			stats["areas"], stats["bodies"],
		])
		remove_child(mgr)
		mgr.free()
	print("DONE failures=%d" % failures)
	get_tree().quit(1 if failures > 0 else 0)

func _walk(node: Node, stats: Dictionary) -> void:
	stats["nodes"] += 1
	if node is MultiMeshInstance3D:
		stats["multimesh"] += 1
		var mm := (node as MultiMeshInstance3D).multimesh
		if mm != null:
			stats["mm_instances"] += mm.instance_count
	elif node is MeshInstance3D:
		stats["mesh"] += 1
	elif node is Area3D:
		stats["areas"] += 1
	elif node is StaticBody3D:
		stats["bodies"] += 1
	for child in node.get_children():
		_walk(child, stats)
