extends SceneTree

const BOSS_LAB_SCENE := preload("res://scenes/tests/boss_lab.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var lab := BOSS_LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	await physics_frame

	var player := lab.get_node("Player") as PlayerController
	var burner := lab.get_node("BurnerLeft") as IncenseBurner
	player.shi.current_shi = 0.0
	var hit := AttackData.new()
	hit.damage = burner.health.max_health
	hit.posture_damage = 10.0
	var result := burner.receive_hit(player, hit, 1)

	if result != HurtboxComponent.ReceiveResult.HIT:
		failures.append("Burner did not accept the hit.")
	if player.shi.current_shi <= 0.0:
		failures.append("Destroying a burner did not restore shi.")

	if failures.is_empty():
		print("INCENSE BURNER TEST PASS: burners break and restore shi.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
