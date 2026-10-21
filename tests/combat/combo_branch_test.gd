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
	var weapon := player._current_weapon()
	player.shi.current_shi = player.shi.max_shi
	player._switch_weapon(false)
	if player._current_weapon().weapon_id != &"spear":
		failures.append("Weapon switch did not select the spear.")
	player._switch_weapon(false)

	player._start_ground_light()
	if not player.state_machine.is_state(PlayerController.STATE_ATTACK):
		failures.append("Ground light did not enter the attack state.")

	await _wait_frames(weapon.light_chain[0].startup_frames + 2)
	player.buffered_input = PlayerController.INPUT_LIGHT
	for _frame: int in range(30):
		await physics_frame
		if player.current_attack_data == weapon.light_chain[1]:
			break

	if player.combo_step != 1 or player.current_attack_data != weapon.light_chain[1]:
		failures.append(
			"Light1 did not branch into Light2. state=%s combo=%d buffer=%s attack=%s" % [
				player.state_machine.current_state,
				player.combo_step,
				player.buffered_input,
				player.current_attack_data.attack_id if player.current_attack_data != null else &"<null>",
			],
		)

	player.buffered_input = PlayerController.INPUT_UP_LIGHT
	for _frame: int in range(30):
		await physics_frame
		if player.current_attack_data == weapon.up_finisher:
			break

	if player.current_attack_data != weapon.up_finisher:
		failures.append(
			"Light2 did not branch into the up finisher. state=%s combo=%d buffer=%s attack=%s" % [
				player.state_machine.current_state,
				player.combo_step,
				player.buffered_input,
				player.current_attack_data.attack_id if player.current_attack_data != null else &"<null>",
			],
		)

	if failures.is_empty():
		print("COMBO TEST PASS: shared starter and directional branch are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)


func _wait_frames(count: int) -> void:
	for _frame: int in range(count):
		await physics_frame
