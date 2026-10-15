extends SceneTree

const ENEMY_SCENES: Array[PackedScene] = [
	preload("res://scenes/actors/enemies/tian_bing.tscn"),
	preload("res://scenes/actors/enemies/guardian.tscn"),
	preload("res://scenes/actors/enemies/cleric_officer.tscn"),
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	await process_frame
	for scene: PackedScene in ENEMY_SCENES:
		var enemy := scene.instantiate() as EnemyController
		root.add_child(enemy)
		await process_frame
		if enemy.profile == null:
			failures.append("Enemy scene is missing a profile.")
		if enemy.health.max_health != enemy.profile.max_health:
			failures.append("%s did not apply profile health." % enemy.name)
		if enemy.qi.recovery_per_second <= 0.0:
			failures.append("%s does not recover guard qi." % enemy.name)
		enemy.free()

	if failures.is_empty():
		print("ENEMY ARCHETYPE TEST PASS: profiles and guard qi are valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
