extends SceneTree

const COMBAT_LAB_SCENE := preload("res://scenes/tests/combat_lab.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var lab := COMBAT_LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame

	var events := root.get_node_or_null("GameEvents")
	var audio := root.get_node_or_null("AudioManager")
	if events == null or audio == null:
		failures.append("Audio event bus or manager is missing.")
		_finish(failures)
		return

	for player: AudioStreamPlayer in audio._players:
		player.stop()
	events.emit_parry_succeeded(Vector2(600.0, 400.0), &"short_blade")
	await process_frame
	var parry_playing := false
	for player: AudioStreamPlayer in audio._players:
		if player.playing:
			parry_playing = true
			break
	if not parry_playing:
		failures.append("Parry event did not trigger audio.")
	for player: AudioStreamPlayer in audio._players:
		player.stop()

	_finish(failures)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("AUDIO EVENT TEST PASS: combat events trigger sound.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
