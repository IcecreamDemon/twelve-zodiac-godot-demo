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
	if player.shi.recovery_per_second > 2.0:
		failures.append("Shi passive recovery is too fast for the current balance.")
	player.shi.current_shi = 10.0
	var starting_shi := player.shi.current_shi

	for _frame: int in range(60):
		await physics_frame

	if player.shi.current_shi <= starting_shi:
		failures.append("Shi did not recover over time.")
	if player.shi.current_shi > player.shi.max_shi:
		failures.append("Shi recovery exceeded the maximum.")

	if failures.is_empty():
		print("SHI RECOVERY TEST PASS: shi recovers over time.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
