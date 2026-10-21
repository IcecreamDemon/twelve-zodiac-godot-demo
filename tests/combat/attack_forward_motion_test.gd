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
	var attack := player._current_weapon().forward_finisher
	player.shi.current_shi = player.shi.max_shi
	player.facing_direction = 1
	var start_x := player.global_position.x
	player._start_attack(attack, PlayerController.ATTACK_LIGHT, false)

	for _frame: int in range(attack.startup_frames + attack.active_frames):
		await physics_frame

	if player.global_position.x < start_x + 15.0:
		failures.append("Forward finisher did not move the player forward visibly.")
	if attack.forward_motion_speed <= 0.0:
		failures.append("Forward finisher has no configured attack motion.")

	if failures.is_empty():
		print("ATTACK MOTION TEST PASS: attacks move the player forward.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
