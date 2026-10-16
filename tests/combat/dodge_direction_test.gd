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

	var player := lab.get_node("Player") as PlayerController
	var start_x := player.global_position.x
	if not player._start_dodge(-1.0):
		failures.append("Reverse dodge did not start.")
	if player.facing_direction != -1:
		failures.append("Reverse dodge did not flip the facing direction.")
	if player.velocity.x >= 0.0:
		failures.append("Reverse dodge velocity is not negative.")

	for _frame: int in range(6):
		await physics_frame
	if player.global_position.x >= start_x:
		failures.append("Player did not move left during reverse dodge.")

	if failures.is_empty():
		print("DODGE DIRECTION TEST PASS: reverse input controls dodge direction.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
