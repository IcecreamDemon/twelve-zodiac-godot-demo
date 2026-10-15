extends SceneTree

const ENEMY_SCENE := preload("res://scenes/actors/enemies/cleric_officer.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var enemy := ENEMY_SCENE.instantiate() as EnemyController
	root.add_child(enemy)
	await process_frame
	await physics_frame

	enemy._start_projectile(enemy.profile.projectile_attack)
	for _frame: int in range(24):
		await physics_frame

	var projectile_count := 0
	for child: Node in root.get_children():
		if child is EnemyProjectile:
			projectile_count += 1

	if projectile_count == 0:
		failures.append("Cleric officer did not spawn a projectile.")

	if failures.is_empty():
		print("ENEMY PROJECTILE TEST PASS: ranged attack spawns correctly.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
