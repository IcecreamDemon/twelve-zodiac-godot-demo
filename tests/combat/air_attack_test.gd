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
	player.global_position.y -= 120.0
	player.state_machine.transition_to(PlayerController.STATE_FALL)
	player._start_air_attack(false)

	if player.attack_mode != PlayerController.ATTACK_AIR_LIGHT:
		failures.append("Air light did not enter the air-light attack mode.")
	if player.air_actions_remaining != player.max_air_actions - 1:
		failures.append("Air light did not consume an air action.")

	player.hitbox.cancel_attack()
	player.current_attack_data = null
	player.attack_mode = &""
	player.state_machine.transition_to(PlayerController.STATE_FALL)
	player._start_air_attack(true)

	if player.attack_mode != PlayerController.ATTACK_AIR_SLAM:
		failures.append("Air heavy did not enter the air-slam mode.")
	if player.current_attack_data != player._current_weapon().air_slam:
		failures.append("Air heavy did not use the weapon's slam attack.")

	if failures.is_empty():
		print("AIR ATTACK TEST PASS: air light and air slam are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
