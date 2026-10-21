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

	var enemy := lab.get_node("TianBing") as EnemyController
	enemy.decision_cooldown = 999.0
	var attack := enemy.profile.melee_attacks[0]
	enemy._start_melee(attack)
	enemy.visual.modulate = Color.WHITE
	for _frame: int in range(maxi(attack.startup_frames / 2, 1)):
		await physics_frame

	if enemy.visual.modulate.is_equal_approx(Color.WHITE):
		failures.append("Enemy did not show an attack telegraph color.")

	if failures.is_empty():
		print("ENEMY TELEGRAPH TEST PASS: attack startup changes the enemy silhouette color.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
