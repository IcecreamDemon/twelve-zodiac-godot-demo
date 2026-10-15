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

	var player := lab.get_node("Player") as PlayerController
	var tian := lab.get_node("TianBing") as EnemyController
	var initial_distance := tian.global_position.distance_to(player.global_position)

	for _frame: int in range(150):
		await physics_frame

	var final_distance := tian.global_position.distance_to(player.global_position)
	if final_distance >= initial_distance - 30.0:
		failures.append("Tian Bing AI did not approach the player.")
	if tian.profile == null or tian.qi.recovery_per_second <= 0.0:
		failures.append("Tian Bing AI lost its runtime profile.")

	if failures.is_empty():
		print("ENEMY AI TEST PASS: enemy lab runs and Tian Bing approaches.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
