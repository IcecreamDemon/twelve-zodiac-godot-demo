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

	flow.incense_currency = 50
	flow._open_shop()
	if not flow.node_map.visible:
		failures.append("Shop did not open through the node map.")
	flow._buy_shop_option(&"shop_damage")
	if flow.incense_currency != 30:
		failures.append("Shop purchase did not spend incense currency.")
	if flow.player.bonus_damage < 2.0:
		failures.append("Shop weapon purchase did not increase player damage.")

	flow._buy_shop_option(&"shop_health")
	if flow.player.health.max_health <= 100.0:
		failures.append("Shop armor purchase did not increase maximum health.")

	if failures.is_empty():
		print("SHOP REWARD TEST PASS: shop purchases apply real upgrades.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
