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
	var dummy := lab.get_node("TrainingDummy") as TrainingDummy
	dummy.global_position = player.global_position + Vector2(78.0, 0.0)

	var attack := AttackData.new()
	attack.damage = 10.0
	attack.posture_damage = 10.0
	attack.guard_qi_damage = 20.0

	var health_before := player.health.current_health
	player.state_machine.transition_to(PlayerController.STATE_GUARD)
	var guard_result := player.receive_hit(dummy, attack, 1)
	if guard_result != HurtboxComponent.ReceiveResult.BLOCK:
		failures.append("Guard did not return BLOCK.")
	if player.health.current_health != health_before:
		failures.append("Guard should not reduce health.")
	if player.qi.current_qi >= player.qi.max_qi:
		failures.append("Guard should consume qi.")

	player.qi.current_qi = 20.0
	player.shi.reset()
	player.state_machine.transition_to(PlayerController.STATE_PARRY)
	var parry_result := player.receive_hit(dummy, attack, 1)
	if parry_result != HurtboxComponent.ReceiveResult.PARRY:
		failures.append("Perfect parry did not return PARRY.")
	if player.qi.current_qi <= 20.0:
		failures.append("Perfect parry should restore qi.")
	if player.shi.current_shi <= 0.0:
		failures.append("Perfect parry should grant shi.")
	if player.attack_mode != PlayerController.ATTACK_COUNTER:
		failures.append("Close-range parry did not start the counter chain.")

	player.state_machine.transition_to(PlayerController.STATE_HIT)
	player.qi.current_qi = player.emergency_parry_qi_threshold
	if not player.try_emergency_parry():
		failures.append("Emergency parry did not trigger at the qi threshold.")
	if player.state_machine.current_state != PlayerController.STATE_PARRY:
		failures.append("Emergency parry did not enter the parry state.")

	if failures.is_empty():
		print("PARRY TEST PASS: guard, parry, counter, and emergency parry are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
