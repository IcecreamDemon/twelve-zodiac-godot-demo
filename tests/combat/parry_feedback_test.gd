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

	var feedback := root.get_node_or_null("ParryFeedback")
	if feedback == null:
		failures.append("ParryFeedback autoload is missing.")
	else:
		var events := root.get_node_or_null("GameEvents")
		events.emit_parry_succeeded(Vector2(700.0, 500.0), &"spear")
		await process_frame
		if not feedback.stamp.visible:
			failures.append("Parry stamp did not become visible.")
		if not feedback.ink_ring.visible:
			failures.append("Parry ink ring did not become visible.")
		if feedback.flash.modulate.a <= 0.0:
			failures.append("Parry screen flash did not start.")

	if failures.is_empty():
		print("PARRY FEEDBACK TEST PASS: stamp, flash, and ink ring are active.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
