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

	var player := lab.get_node("Player") as PlayerController
	var enemy := lab.get_node("TianBing") as EnemyController
	enemy.decision_cooldown = 999.0
	enemy.global_position = player.global_position + Vector2(130.0, 0.0)
	var enemy_start_y := enemy.global_position.y

	Input.action_press(&"move_right")
	for _frame: int in range(60):
		await physics_frame
	Input.action_release(&"move_right")

	if enemy.global_position.x - player.global_position.x < 80.0:
		failures.append("Normal movement passed through the enemy contact boundary.")
	if absf(enemy.global_position.y - enemy_start_y) > 0.5:
		failures.append("Enemy moved vertically during normal actor blocking.")

	if failures.is_empty():
		print("ACTOR BLOCKING TEST PASS: normal movement is blocked without vertical drift.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
