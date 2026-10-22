extends SceneTree

const ACTION_KEYS: Dictionary = {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"jump": KEY_SPACE,
	&"light_attack": KEY_J,
	&"heavy_attack": KEY_K,
	&"dodge": KEY_L,
	&"guard": KEY_U,
	&"perfect_parry": KEY_I,
	&"switch_weapon": KEY_Q,
	&"heavy_technique": KEY_E,
	&"burrow": KEY_F,
	&"aim_up": KEY_W,
	&"pause": KEY_ESCAPE,
}


func _initialize() -> void:
	for action: StringName in ACTION_KEYS:
		var event := InputEventKey.new()
		event.physical_keycode = ACTION_KEYS[action]
		ProjectSettings.set_setting(
			"input/%s" % action,
			{
				"deadzone": 0.5,
				"events": [event],
			},
		)

	var error := ProjectSettings.save()
	if error != OK:
		push_error("Failed to save InputMap settings: %s" % error_string(error))

	quit(error)
