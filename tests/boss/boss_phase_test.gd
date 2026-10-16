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
	await physics_frame

	var player := lab.get_node("Player") as PlayerController
	var boss := lab.get_node("DuoYuanShen") as DuoYuanShenAI
	player.shi.current_shi = 40.0
	boss.health.current_health = boss.health.max_health * 0.6
	await physics_frame

	if boss.phase != 1:
		failures.append("Boss did not enter phase 1 at the health threshold.")
	if boss.shield < boss.shield_minimum:
		failures.append("Boss did not create a shield in phase 1.")
	if player.shi.current_shi != 0.0:
		failures.append("Boss did not steal the player's shi for its shield.")

	var health_before := boss.health.current_health
	var shield_before := boss.shield
	var hit := AttackData.new()
	hit.damage = 20.0
	boss.receive_hit(player, hit, 1)
	if boss.shield >= shield_before:
		failures.append("Damage did not reduce the boss shield.")
	if boss.health.current_health != health_before:
		failures.append("Shield damage leaked into boss health.")

	boss.health.current_health = boss.health.max_health * 0.2
	await physics_frame
	if boss.phase != 2:
		failures.append("Boss did not enter phase 2 at the final health threshold.")

	if failures.is_empty():
		print("BOSS PHASE TEST PASS: shield, shi theft, and phase transitions are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
