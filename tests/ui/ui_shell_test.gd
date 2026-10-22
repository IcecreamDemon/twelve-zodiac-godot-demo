extends SceneTree

const TITLE_SCENE := preload("res://scenes/ui/title_screen.tscn")
const PAUSE_SCENE := preload("res://scenes/ui/pause_menu.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var title := TITLE_SCENE.instantiate()
	root.add_child(title)
	await process_frame
	if title.get_node_or_null("StartButton") == null:
		failures.append("Title screen is missing the start button.")
	if title.get_node_or_null("ControlsPanel") == null:
		failures.append("Title screen is missing the controls panel.")
	title.free()

	var pause_menu := PAUSE_SCENE.instantiate()
	root.add_child(pause_menu)
	await process_frame
	pause_menu.open_menu()
	if not paused or not pause_menu.root.visible:
		failures.append("Pause menu did not pause the tree and become visible.")
	pause_menu.close_menu()
	if paused or pause_menu.root.visible:
		failures.append("Pause menu did not resume the tree.")
	pause_menu.free()

	if failures.is_empty():
		print("UI SHELL TEST PASS: title and pause menu are functional.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
