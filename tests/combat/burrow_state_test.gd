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
	var starting_qi := player.qi.current_qi
	if not player._start_burrow():
		failures.append("Player could not enter burrow on the main ground.")
	if not player.state_machine.is_state(PlayerController.STATE_BURROW):
		failures.append("Burrow did not enter the burrow state.")
	if player.collision_layer != 0:
		failures.append("Burrow did not disable the normal body collision layer.")
	if player.qi.current_qi >= starting_qi:
		failures.append("Burrow entry did not consume qi.")
	if not player.burrow_crack.visible:
		failures.append("Burrow crack marker is not visible.")

	var normal_attack := AttackData.new()
	normal_attack.attack_type = AttackData.AttackType.NORMAL
	if player.receive_hit(null, normal_attack, 1) != HurtboxComponent.ReceiveResult.IGNORED:
		failures.append("Normal attack incorrectly hit a burrowed player.")

	var anti_attack := AttackData.new()
	anti_attack.attack_type = AttackData.AttackType.ANTI_BURROW
	anti_attack.damage = 5.0
	anti_attack.posture_damage = 5.0
	if player.receive_hit(null, anti_attack, 1) == HurtboxComponent.ReceiveResult.IGNORED:
		failures.append("Anti-burrow attack was ignored.")
	if player.is_burrowed():
		failures.append("Anti-burrow hit did not force the player out of the ground.")

	if failures.is_empty():
		print("BURROW STATE TEST PASS: ground entry and anti-burrow collision are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
