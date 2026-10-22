extends SceneTree

const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"jump",
	&"light_attack",
	&"heavy_attack",
	&"dodge",
	&"guard",
	&"perfect_parry",
	&"switch_weapon",
	&"heavy_technique",
	&"burrow",
	&"aim_up",
	&"pause",
]


func _initialize() -> void:
	var failures: Array[String] = []

	for action: StringName in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			failures.append("Missing InputMap action: %s" % action)

	for autoload_name: String in ["GameEvents", "DebugFlags"]:
		if not ProjectSettings.has_setting("autoload/%s" % autoload_name):
			failures.append("Missing autoload: %s" % autoload_name)

	if failures.is_empty():
		print("SMOKE TEST PASS: project baseline is valid.")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)
