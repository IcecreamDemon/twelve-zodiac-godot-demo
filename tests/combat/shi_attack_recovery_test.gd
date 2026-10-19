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
	player.shi.current_shi = 50.0
	player._start_ground_light()
	var shi_during_attack := player.shi.current_shi

	for _frame: int in range(6):
		await physics_frame

	if not is_equal_approx(player.shi.current_shi, shi_during_attack):
		failures.append("Shi recovered during an active attack.")

	for _frame: int in range(30):
		await physics_frame

	if player.shi.current_shi <= shi_during_attack:
		failures.append("Shi recovery did not resume after the attack ended.")

	if failures.is_empty():
		print("SHI ATTACK RECOVERY TEST PASS: recovery pauses during attacks.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
