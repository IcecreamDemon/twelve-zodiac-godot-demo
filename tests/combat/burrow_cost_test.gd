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
	if not player._start_burrow():
		failures.append("Player could not enter burrow.")
		_finish(failures)
		return

	var qi_after_entry := player.qi.current_qi
	for _frame: int in range(30):
		await physics_frame
	if player.qi.current_qi >= qi_after_entry:
		failures.append("Burrow did not continuously consume qi.")
	if not player.is_burrowed():
		failures.append("Player exited burrow before qi was exhausted.")

	player.qi.current_qi = 0.1
	await physics_frame
	if player.is_burrowed():
		failures.append("Zero qi did not force the player out of burrow.")

	_finish(failures)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("BURROW COST TEST PASS: continuous qi drain and forced exit are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
