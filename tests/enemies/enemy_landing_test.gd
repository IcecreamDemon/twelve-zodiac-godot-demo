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
	var attack := AttackData.new()
	attack.reaction_type = AttackData.ReactionType.KNOCKDOWN
	attack.knockback = Vector2(120.0, -80.0)
	attack.knockdown_frames = 30
	enemy.receive_hit(null, attack, 1)

	for _frame: int in range(150):
		await physics_frame

	if enemy.global_position.y > 860.0:
		failures.append("Enemy sank below the arena ground after hit reaction.")
	if enemy.visual.position.y != -8.0:
		failures.append("Enemy visual offset is not aligned with the ground.")

	if failures.is_empty():
		print("ENEMY LANDING TEST PASS: enemies do not sink into the ground.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
