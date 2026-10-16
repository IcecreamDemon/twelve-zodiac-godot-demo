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

	if flow.flow_state != DemoFlowController.FlowState.PROLOGUE:
		failures.append("Flow did not start in the prologue.")

	flow._on_continue_pressed()
	if flow.flow_state != DemoFlowController.FlowState.TUTORIAL:
		failures.append("Prologue did not advance to the tutorial.")
	if flow.active_enemy == null:
		failures.append("Tutorial did not spawn an enemy.")

	flow.active_enemy.health.take_damage(9999.0)
	await process_frame
	if flow.flow_state != DemoFlowController.FlowState.CHOICE:
		failures.append("Tutorial defeat did not open the incense choice.")

	flow._on_return_incense()
	if not flow.incense_returned:
		failures.append("Returning incense did not set the narrative choice.")
	if flow.flow_state != DemoFlowController.FlowState.ELITE:
		failures.append("Incense choice did not advance to the elite.")

	flow.active_enemy.health.take_damage(9999.0)
	await process_frame
	if flow.flow_state != DemoFlowController.FlowState.OLD_SELF:
		failures.append("Elite defeat did not advance to the old-self encounter.")

	flow.player.health.take_damage(9999.0)
	await process_frame
	if not flow.retrying:
		failures.append("Player death did not enter the retry state.")
	if flow.player.health.current_health <= 0.0:
		failures.append("Retry did not restore player health.")

	flow._set_state(DemoFlowController.FlowState.BOSS)
	await process_frame
	if flow.active_enemy == null:
		failures.append("Boss state did not spawn the boss.")
	if flow.encounter_root.get_tree().get_nodes_in_group(&"incense_burner").is_empty():
		failures.append("Boss state did not spawn incense burners.")

	flow.active_enemy.health.take_damage(9999.0)
	await process_frame
	if flow.flow_state != DemoFlowController.FlowState.COMPLETE:
		failures.append("Boss defeat did not complete the demo flow.")

	if failures.is_empty():
		print("DEMO FLOW TEST PASS: six-node progression, choice, retry, and boss are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
