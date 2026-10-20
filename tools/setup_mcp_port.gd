extends SceneTree

const SETTINGS_MANAGER := preload("res://addons/godot_mcp/native_mcp/settings_manager.gd")


func _initialize() -> void:
	var manager := SETTINGS_MANAGER.new()
	var settings := manager.load_settings()
	settings["http_port"] = 19081
	settings["transport_mode"] = "http"
	settings["auto_start"] = true
	var saved := manager.save_settings(settings)
	print("MCP port updated to 19081: %s" % saved)
	quit(0 if saved else 1)
