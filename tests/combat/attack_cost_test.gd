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
	var qi_before := player.qi.current_qi
	var shi_before := player.shi.current_shi

	player._start_ground_light()
	if player.qi.current_qi != qi_before:
		failures.append("Player attack consumed qi instead of shi.")
	if player.shi.current_shi >= shi_before:
		failures.append("Player attack did not consume shi.")
	if attack.qi_cost != 0.0:
		failures.append("Attack resource still contains a qi cost.")
	if attack.shi_cost <= 0.0:
		failures.append("Attack resource does not contain a shi cost.")

	if failures.is_empty():
		print("ATTACK COST TEST PASS: attacks consume shi, not qi.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
