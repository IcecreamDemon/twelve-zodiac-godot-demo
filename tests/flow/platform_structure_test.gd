extends SceneTree

const FLOW_SCENE := preload("res://scenes/flow/demo_flow.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var flow := FLOW_SCENE.instantiate()
	await process_frame
	var platform := flow.get_node_or_null("Platform") as StaticBody2D
	if platform == null:
		failures.append("Demo Flow is missing its platform.")
	else:
		var shape := platform.get_node("CollisionShape2D") as CollisionShape2D
		if shape == null or not shape.one_way_collision:
			failures.append("Demo Flow platform is not one-way collision.")
	flow.free()

	if failures.is_empty():
		print("PLATFORM TEST PASS: Demo Flow platform uses one-way collision.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
