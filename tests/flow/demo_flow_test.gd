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
	if not flow.node_map.visible:
		failures.append("Prologue did not open the node selection map.")
	if flow.active_enemy != null:
		failures.append("Tutorial enemy spawned before node selection.")

	flow._on_node_option_selected(&"tutorial")
	if flow.flow_state != DemoFlowController.FlowState.TUTORIAL:
		failures.append("Tutorial node selection did not start the tutorial.")
	if flow.active_enemy == null:
		failures.append("Tutorial node selection did not spawn an enemy.")

	flow.active_enemy.health.take_damage(9999.0)
	await create_timer(2.0).timeout
	if not flow.node_map.visible:
		failures.append("Tutorial victory did not return to the node selection map.")

	flow._on_node_option_selected(&"return_incense")
	if not flow.incense_returned:
		failures.append("Returning incense did not set the narrative choice.")
	if flow.flow_state != DemoFlowController.FlowState.ELITE:
		failures.append("Incense choice did not advance to the elite.")

	flow.active_enemy.health.take_damage(9999.0)
	await create_timer(2.0).timeout
	if not flow.node_map.visible:
		failures.append("Elite victory did not return to the node selection map.")

	var damage_before := flow.player.bonus_damage
	flow._on_node_option_selected(&"elite_reward_damage")
	if flow.flow_state != DemoFlowController.FlowState.OLD_SELF:
		failures.append("Elite reward did not start the old-self encounter.")
	if flow.player.bonus_damage <= damage_before:
		failures.append("Elite damage reward did not increase player damage.")

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
	await create_timer(2.0).timeout
	if flow.flow_state != DemoFlowController.FlowState.COMPLETE:
		failures.append("Boss defeat did not complete the demo flow.")

	if failures.is_empty():
		print("DEMO FLOW TEST PASS: six-node progression, choice, retry, and boss are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
