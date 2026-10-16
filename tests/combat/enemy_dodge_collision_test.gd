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
	enemy.global_position = player.global_position + Vector2(82.0, 0.0)
	var enemy_start_y := enemy.global_position.y
	var enemy_start_x := enemy.global_position.x
	await physics_frame

	player._start_dodge(1.0)
	for _frame: int in range(20):
		await physics_frame

	var separation := enemy.global_position.x - player.global_position.x
	if separation < 80.0:
		failures.append("Player passed into the enemy body during dodge.")
	if absf(enemy.global_position.y - enemy_start_y) > 0.5:
		failures.append("Enemy model sank or lifted vertically during player collision.")
	if absf(enemy.global_position.x - enemy_start_x) > 2.0:
		failures.append("Enemy was pushed horizontally instead of blocking the player.")

	if failures.is_empty():
		print("ENEMY DODGE COLLISION TEST PASS: enemy body remains grounded.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
