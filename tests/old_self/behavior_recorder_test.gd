extends SceneTree

func _initialize() -> void:
	var failures: Array[String] = []
	var recorder := BehaviorRecorder.new()
	var attack_a := AttackData.new()
	attack_a.attack_id = &"attack_a"
	var attack_b := AttackData.new()
	attack_b.attack_id = &"attack_b"

	for index: int in range(4):
		recorder.record_attack(attack_a, 70.0)
	recorder.record_dodge(-1)
	recorder.record_attack(attack_b, 190.0)

	var profile := recorder.build_profile()
	if profile.preferred_distance_min != 0.0 or profile.preferred_distance_max != 80.0:
		failures.append("Recorder did not select the most common distance bucket.")
	if profile.combo_sequence.is_empty() or profile.combo_sequence.back() != attack_b:
		failures.append("Recorder did not retain the latest combo sequence.")
	if profile.dodge_direction != -1:
		failures.append("Recorder did not retain the most common dodge direction.")

	if failures.is_empty():
		print("BEHAVIOR RECORDER TEST PASS: distance, combo, and dodge are recorded.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
