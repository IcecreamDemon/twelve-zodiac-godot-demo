extends SceneTree

const OLD_SELF_SCENE := preload("res://scenes/actors/enemies/old_self.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var recorder := BehaviorRecorder.new()
	var attack_a := AttackData.new()
	attack_a.attack_id = &"first"
	var attack_b := AttackData.new()
	attack_b.attack_id = &"second"
	recorder.record_attack(attack_a, 65.0)
	recorder.record_attack(attack_b, 65.0)
	recorder.record_dodge(1)

	var profile := recorder.build_profile()
	var old_self := OLD_SELF_SCENE.instantiate() as OldSelfAI
	old_self.behavior_profile = profile
	root.add_child(old_self)
	await process_frame

	old_self._choose_action(70.0)
	if old_self.current_attack_data != attack_a:
		failures.append("Old self did not replay the first recorded attack.")
	old_self.hitbox.cancel_attack()
	old_self.state_machine.transition_to(OldSelfAI.STATE_APPROACH)
	old_self._choose_action(70.0)
	if old_self.current_attack_data != attack_b:
		failures.append("Old self did not replay the second recorded attack.")

	recorder.reset()
	if old_self.behavior_profile.combo_sequence.is_empty():
		failures.append("Old self profile was not isolated from later recorder resets.")

	old_self._on_died()
	var face_reveal := old_self.get_node("FaceReveal") as Polygon2D
	if not face_reveal.visible:
		failures.append("Old self did not reveal the host face on defeat.")

	if failures.is_empty():
		print("OLD SELF TEST PASS: replay sequence, profile isolation, and face reveal are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
