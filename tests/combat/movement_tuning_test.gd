extends SceneTree

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var player_scene := preload("res://scenes/actors/player/player.tscn")
	var player := player_scene.instantiate() as PlayerController
	root.add_child(player)
	await process_frame

	if player.move_speed < 360.0:
		failures.append("Move speed is below the tuned prototype baseline.")
	if player.jump_velocity < 880.0:
		failures.append("Jump velocity is below the tuned prototype baseline.")
	if player.gravity < 2000.0:
		failures.append("Gravity is below the tuned prototype baseline.")
	if player.dodge_speed < 440.0:
		failures.append("Dodge speed is below the tuned prototype baseline.")
	if player.collision_mask != 1:
		failures.append("Player should use manual actor blocking instead of enemy body collisions.")
	var lab_scene := preload("res://scenes/tests/combat_lab.tscn")
	var lab := lab_scene.instantiate()
	var platform := lab.get_node_or_null("Platform") as Node2D
	if platform != null and platform.position.y > 740.0:
		failures.append("Combat Lab platform is still too high.")
	lab.free()

	if failures.is_empty():
		print("MOVEMENT TUNING TEST PASS: speed, jump, dodge, and collision mask are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
