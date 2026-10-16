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
	await physics_frame

	var player := lab.get_node("Player") as PlayerController
	var dummy := lab.get_node("TrainingDummy") as TrainingDummy
	dummy.global_position = player.global_position + Vector2(82.0, 0.0)
	var dummy_start_x := dummy.global_position.x
	var dummy_start_y := dummy.global_position.y
	await physics_frame

	player._start_dodge(1.0)
	for _frame: int in range(20):
		await physics_frame

	var separation := dummy.global_position.x - player.global_position.x
	if separation < 42.0:
		failures.append("Player passed into or through the enemy body during dodge.")
	if absf(dummy.global_position.x - dummy_start_x) > 2.0:
		failures.append("Player pushed the enemy while dodging.")
	if absf(dummy.global_position.y - dummy_start_y) > 0.5:
		failures.append("Enemy moved vertically during a dodge collision.")

	if failures.is_empty():
		print("DODGE COLLISION TEST PASS: enemy bodies block dodge movement.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
