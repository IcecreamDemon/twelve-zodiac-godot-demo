extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var audio := root.get_node_or_null("AudioManager")
	if audio == null:
		failures.append("AudioManager autoload is missing.")
		_finish(failures)
		return

	if audio._streams.size() < 8:
		failures.append("Generated placeholder audio streams were not loaded.")

	var original_volume: float = audio.get_master_volume()
	audio.set_master_volume(37.0)
	if absf(audio.get_master_volume() - 37.0) > 1.0:
		failures.append("Master volume control did not apply.")
	audio.set_master_volume(original_volume)

	audio.play(&"hit_light")
	await process_frame
	var playing := false
	for player: AudioStreamPlayer in audio._players:
		if player.playing:
			playing = true
			break
	if not playing:
		failures.append("AudioManager did not play a requested sound.")
	for player: AudioStreamPlayer in audio._players:
		player.stop()

	_finish(failures)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("AUDIO MANAGER TEST PASS: streams, pooling, and volume work.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
