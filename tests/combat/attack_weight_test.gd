extends SceneTree

func _initialize() -> void:
	var failures: Array[String] = []
	var weapon := load("res://resources/weapons/short_blade.tres") as WeaponData
	var light := weapon.light_chain[0]
	var heavy := weapon.heavy_finisher
	var slam := weapon.air_slam

	if heavy.hitstop_frames <= light.hitstop_frames:
		failures.append("Heavy attack hitstop is not stronger than light hitstop.")
	if slam.hitstop_frames <= heavy.hitstop_frames:
		failures.append("Air slam hitstop is not stronger than heavy hitstop.")
	if heavy.screen_shake_strength <= light.screen_shake_strength:
		failures.append("Heavy attack shake is not stronger than light attack shake.")

	if failures.is_empty():
		print("ATTACK WEIGHT TEST PASS: hitstop and shake scale with attack weight.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
