extends SceneTree

const COMBAT_LAB_SCENE := preload("res://scenes/tests/combat_lab.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var lab := COMBAT_LAB_SCENE.instantiate()
	root.add_child(lab)
	await process_frame
	await physics_frame

	var player := lab.get_node("Player") as PlayerController
	if not player.weapon_short.visible or player.weapon_spear.visible:
		failures.append("Starting short blade is not visible correctly.")

	player.shi.current_shi = player.shi.max_shi
	player._switch_weapon(false)
	if player._current_weapon().weapon_id != &"spear":
		failures.append("Weapon switch did not select the spear.")
	if not player.weapon_spear.visible or player.weapon_short.visible:
		failures.append("Spear visual was not shown after switching.")
	if player.attack_mode != PlayerController.ATTACK_SWITCH:
		failures.append("Weapon switch did not play the switch attack.")

	if failures.is_empty():
		print("WEAPON SWITCH TEST PASS: silhouette and switch action change visibly.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
