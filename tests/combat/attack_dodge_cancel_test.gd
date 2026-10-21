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
	var attack := player._current_weapon().light_chain[0]
	player._start_ground_light()
	for _frame: int in range(attack.startup_frames + attack.active_frames + 1):
		await physics_frame

	if not player.try_dodge_cancel(1.0):
		failures.append("Dodge could not cancel attack recovery.")
	if not player.state_machine.is_state(PlayerController.STATE_DODGE):
		failures.append("Dodge cancel did not enter the dodge state.")
	if player.current_attack_data != null:
		failures.append("Attack data was not cleared by dodge cancel.")

	if failures.is_empty():
		print("ATTACK CANCEL TEST PASS: recovery can cancel into dodge.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
