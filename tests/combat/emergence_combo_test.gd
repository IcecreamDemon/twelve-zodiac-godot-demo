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
	var weapon := player._current_weapon()
	player.shi.current_shi = 40.0
	if not player._start_burrow():
		failures.append("Player could not enter burrow.")
		_finish(failures)
		return

	player._exit_burrow(true)
	if player.attack_mode != PlayerController.ATTACK_BURROW_EMERGE:
		failures.append("Exit attack did not enter the burrow-emerge mode.")
	if player.current_attack_data != weapon.burrow_emerge:
		failures.append("Exit attack did not use the weapon's emergence attack.")
	if player.collision_layer != 2:
		failures.append("Emerge did not restore the normal collision layer.")

	player.buffered_input = PlayerController.INPUT_LIGHT
	for _frame: int in range(30):
		await physics_frame
		if player.current_attack_data == weapon.light_chain[0]:
			break
	if player.current_attack_data != weapon.light_chain[0]:
		failures.append("Burrow emergence did not chain into Light1.")

	_finish(failures)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("EMERGENCE TEST PASS: upward attack and light-chain entry are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
