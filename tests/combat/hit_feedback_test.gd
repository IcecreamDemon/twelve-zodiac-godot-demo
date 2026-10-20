extends SceneTree

const COMBAT_LAB_SCENE := preload("res://scenes/tests/combat_lab.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var lab := COMBAT_LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	await physics_frame

	var camera := lab.get_node("Camera") as CombatCamera
	var events := root.get_node_or_null("GameEvents")
	if events == null:
		failures.append("GameEvents autoload is missing.")
	else:
		events.emit_hit_resolved(Vector2(900.0, 500.0), 0.2)
		await process_frame
		if camera.trauma <= 0.0:
			failures.append("Hit event did not add camera trauma.")

	if failures.is_empty():
		print("HIT FEEDBACK TEST PASS: hit events drive camera shake.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
