extends SceneTree

const FLOW_SCENE := preload("res://scenes/flow/demo_flow.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var flow := FLOW_SCENE.instantiate() as DemoFlowController
	root.add_child(flow)
	await process_frame
	await physics_frame

	flow._set_state(DemoFlowController.FlowState.TUTORIAL)
	await process_frame
	flow.player.health.take_damage(35.0)
	if flow.player.health.current_health >= flow.player.health.max_health:
		failures.append("Test setup did not damage the player.")
	flow.pause_menu.restart_requested.emit()
	await process_frame
	if flow.player.health.current_health != flow.player.health.max_health:
		failures.append("Pause restart did not restore player health.")
	if flow.flow_state != DemoFlowController.FlowState.TUTORIAL:
		failures.append("Pause restart changed the current node.")
	if flow.get_node("DebugOverlay").visible:
		failures.append("Debug overlay is visible in the main demo flow.")

	if failures.is_empty():
		print("PAUSE RESTART TEST PASS: current node restarts and debug UI is hidden.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
