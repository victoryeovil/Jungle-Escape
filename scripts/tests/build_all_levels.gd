extends Node

# Headless smoke test: builds every level through the real LevelManager3D and
# reports node/draw statistics. Autoloads are available because this runs as a
# normal scene:
#   godot --headless --path . res://scenes/tests/BuildAllLevels.tscn

const LEVEL_PATH := "res://data/levels3d/level3d_%03d.json"

func _ready() -> void:
	var failures := 0

	# Compile-check every game script (UI screens aren't exercised by builds)
	for dir_path in ["res://scripts/autoload", "res://scripts/data", "res://scripts/gameplay", "res://scripts/ui"]:
		var dir := DirAccess.open(dir_path)
		if dir == null:
			continue
		for file in dir.get_files():
			if not file.ends_with(".gd"):
				continue
			var script := load(dir_path + "/" + file) as Script
			if script == null or not script.can_instantiate():
				print("COMPILE-FAIL  %s/%s" % [dir_path, file])
				failures += 1
	print("script compile check done")

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

		# Modular paths must retain authored sharp turns. This guards against the
		# regression where declaring path_modules silently discarded `turns`.
		var authored_turns: Array = data.get("turns", [])
		if mgr._turn_rows.size() != authored_turns.size():
			print("TURN-FAIL level %d expected=%d built=%d" % [level_id, authored_turns.size(), mgr._turn_rows.size()])
			failures += 1
		for raw_turn in authored_turns:
			if not (raw_turn is Dictionary):
				continue
			var turn_row := int(raw_turn.get("row", 0))
			if not mgr._turn_rows.has(turn_row) or not mgr._seg_fwd.has(turn_row + 1):
				print("TURN-FAIL level %d missing row=%d" % [level_id, turn_row])
				failures += 1
				continue
			var approach: Vector3 = mgr._seg_fwd[turn_row]
			var exit_dir: Vector3 = mgr._seg_fwd[turn_row + 1]
			if absf(approach.dot(exit_dir)) > 0.30:
				print("TURN-FAIL level %d row=%d heading did not rotate sharply" % [level_id, turn_row])
				failures += 1

		var stats := {"nodes": 0, "mesh": 0, "multimesh": 0, "mm_instances": 0, "areas": 0, "bodies": 0}
		_walk(mgr, stats)
		print("OK  level %2d  len=%3d  build=%4dms  nodes=%5d  meshinst=%4d  multimesh=%2d (x%4d)  areas=%3d  bodies=%3d" % [
			level_id, int(data.get("length", 0)), build_ms,
			stats["nodes"], stats["mesh"], stats["multimesh"], stats["mm_instances"],
			stats["areas"], stats["bodies"],
		])
		remove_child(mgr)
		mgr.free()
	# Endless mode: generate + build a few stages too
	for stage in [1, 3, 6]:
		var edata := EndlessLevel.generate(stage, 12345)
		var emgr := LevelManager3D.new()
		add_child(emgr)
		var et0 := Time.get_ticks_msec()
		emgr.build(edata)
		var estats := {"nodes": 0, "mesh": 0, "multimesh": 0, "mm_instances": 0, "areas": 0, "bodies": 0}
		_walk(emgr, estats)
		print("OK  endless stage %d  len=%3d  build=%4dms  nodes=%5d  meshinst=%4d  multimesh=%2d (x%4d)  obstacles=%d coins=%d" % [
			stage, int(edata.get("length", 0)), Time.get_ticks_msec() - et0,
			estats["nodes"], estats["mesh"], estats["multimesh"], estats["mm_instances"],
			(edata.get("obstacles", []) as Array).size(), (edata.get("coins", []) as Array).size(),
		])
		remove_child(emgr)
		emgr.free()

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
