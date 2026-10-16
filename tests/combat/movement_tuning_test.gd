extends SceneTree

func _initialize() -> void:
	var failures: Array[String] = []
	var player_scene := preload("res://scenes/actors/player/player.tscn")
	var player := player_scene.instantiate() as PlayerController
	root.add_child(player)

	if player.move_speed < 360.0:
		failures.append("Move speed is below the tuned prototype baseline.")
	if player.jump_velocity < 800.0:
		failures.append("Jump velocity is below the tuned prototype baseline.")
	if player.dodge_speed < 440.0:
		failures.append("Dodge speed is below the tuned prototype baseline.")
	if player.collision_mask != 5:
		failures.append("Player collision mask does not include ground and enemies.")

	if failures.is_empty():
		print("MOVEMENT TUNING TEST PASS: speed, jump, dodge, and collision mask are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
