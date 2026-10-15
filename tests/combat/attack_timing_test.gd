extends SceneTree

const COMBAT_LAB_SCENE := preload("res://scenes/tests/combat_lab.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var attack_data := AttackData.new()
	attack_data.startup_frames = 2
	attack_data.active_frames = 3
	attack_data.recovery_frames = 4
	if attack_data.total_frames != 9:
		failures.append("AttackData.total_frames should be 9.")

	var lab := COMBAT_LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	await physics_frame

	var player := lab.get_node("Player") as PlayerController
	var dummy := lab.get_node("TrainingDummy") as TrainingDummy
	if player == null or dummy == null:
		failures.append("Combat Lab is missing player or training dummy.")
		_finish(failures)
		return

	dummy.global_position = player.global_position + Vector2(78.0, 0.0)
	await physics_frame

	var starting_health := dummy.health.current_health
	var starting_posture := dummy.posture.current_posture
	var starting_shi := player.shi.current_shi
	var test_attack := player._current_weapon().light_chain[0]

	player.facing_direction = 1
	player._start_ground_light()

	for _frame: int in range(40):
		await physics_frame

	var damage_dealt := starting_health - dummy.health.current_health
	var posture_dealt := starting_posture - dummy.posture.current_posture
	var shi_gained := player.shi.current_shi - starting_shi

	if not is_equal_approx(damage_dealt, test_attack.damage):
		failures.append(
			"Expected one hit for %.1f damage, got %.1f." % [
				test_attack.damage,
				damage_dealt,
			],
		)
	if not is_equal_approx(posture_dealt, test_attack.posture_damage):
		failures.append(
			"Expected one posture hit for %.1f, got %.1f." % [
				test_attack.posture_damage,
				posture_dealt,
			],
		)
	if not is_equal_approx(shi_gained, test_attack.shi_gain_on_hit):
		failures.append(
			"Expected %.1f shi, got %.1f." % [
				test_attack.shi_gain_on_hit,
				shi_gained,
			],
		)

	_finish(failures)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("COMBAT TEST PASS: attack timing and single-hit resolution are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
