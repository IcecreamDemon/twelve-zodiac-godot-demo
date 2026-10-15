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
	var launch := AttackData.new()
	launch.damage = 5.0
	launch.posture_damage = 5.0
	launch.reaction_type = AttackData.ReactionType.LAUNCH
	launch.launch_velocity = Vector2(120.0, -420.0)
	launch.juggle_cost = 1

	dummy.receive_hit(player, launch, 1)
	if not dummy.state_machine.is_state(TrainingDummy.STATE_LAUNCHED):
		failures.append("Launch attack did not enter the launched state.")

	dummy.current_juggle_hits = dummy.max_juggle_hits
	dummy.state_machine.transition_to(TrainingDummy.STATE_LAUNCHED)
	var blocked_extension := dummy.receive_hit(player, launch, 1)
	if blocked_extension != HurtboxComponent.ReceiveResult.IGNORED:
		failures.append("Juggle limit did not reject another launch extension.")

	dummy.current_juggle_hits = 0
	dummy.global_position.y = 0.0
	dummy.global_position.x = player.global_position.x + 70.0
	dummy._enter_knockdown(2)
	if not dummy.is_knockdown():
		failures.append("Knockdown state was not available for ground finisher detection.")
	player._start_heavy_or_ground_finisher()
	if player.attack_mode != PlayerController.ATTACK_GROUND_FINISHER:
		failures.append("Heavy input did not select the ground finisher on a knockdown target.")

	if failures.is_empty():
		print("HIT REACTION TEST PASS: launch, juggle limit, and knockdown are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
