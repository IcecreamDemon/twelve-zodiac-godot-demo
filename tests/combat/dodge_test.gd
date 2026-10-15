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
	var qi_before := player.qi.current_qi
	if not player._start_dodge(1.0):
		failures.append("Dodge did not start with sufficient qi.")
	if not player.state_machine.is_state(PlayerController.STATE_DODGE):
		failures.append("Dodge did not enter the dodge state.")
	if player.qi.current_qi >= qi_before:
		failures.append("Dodge did not consume qi.")

	var attack := AttackData.new()
	attack.damage = 10.0
	if player.receive_hit(null, attack, -1) != HurtboxComponent.ReceiveResult.IGNORED:
		failures.append("Dodge invulnerability did not ignore an incoming attack.")

	if failures.is_empty():
		print("DODGE TEST PASS: dodge state, qi cost, and invulnerability are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
