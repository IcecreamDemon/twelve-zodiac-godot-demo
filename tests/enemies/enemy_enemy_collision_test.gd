extends SceneTree

const ENEMY_LAB_SCENE := preload("res://scenes/tests/enemy_lab.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var lab := ENEMY_LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	await physics_frame
	await physics_frame

	var tian := lab.get_node("TianBing") as EnemyController
	var guardian := lab.get_node("Guardian") as EnemyController
	tian.decision_cooldown = 999.0
	guardian.decision_cooldown = 999.0
	guardian.global_position = tian.global_position + Vector2(8.0, 0.0)
	var tian_start_y := tian.global_position.y
	var guardian_start_y := guardian.global_position.y

	for _frame: int in range(30):
		await physics_frame

	if absf(guardian.global_position.x - tian.global_position.x) < 50.0:
		failures.append("Enemy bodies remain overlapped instead of separating horizontally.")
	if absf(tian.global_position.y - tian_start_y) > 0.5:
		failures.append("First enemy moved vertically during enemy-enemy collision.")
	if absf(guardian.global_position.y - guardian_start_y) > 0.5:
		failures.append("Second enemy moved vertically during enemy-enemy collision.")

	if failures.is_empty():
		print("ENEMY ENEMY COLLISION TEST PASS: enemies separate without sinking.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
