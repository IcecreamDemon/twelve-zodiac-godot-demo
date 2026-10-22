extends Node

const AUDIO_DIR := "res://assets/audio/"
const SETTINGS_PATH := "user://settings.cfg"
const PLAYER_POOL_SIZE := 12

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0


func _ready() -> void:
	for sound_id: StringName in [
		&"hit_light",
		&"hit_heavy",
		&"block",
		&"parry",
		&"dodge",
		&"burrow",
		&"emerge",
		&"ui",
		&"enemy_death",
	]:
		var stream := load("%s%s.res" % [AUDIO_DIR, sound_id]) as AudioStream
		if stream != null:
			_streams[sound_id] = stream

	for index: int in range(PLAYER_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % index
		add_child(player)
		_players.append(player)

	var events := get_node_or_null("/root/GameEvents")
	if events != null:
		events.hit_resolved.connect(_on_hit_resolved)
		events.block_succeeded.connect(_on_block_succeeded)
		events.parry_succeeded.connect(_on_parry_succeeded)
		events.dodge_started.connect(_on_dodge_started)
		events.burrow_started.connect(_on_burrow_started)
		events.burrow_emerged.connect(_on_burrow_emerged)
		events.actor_died.connect(_on_actor_died)

	_load_settings()


func play(
	sound_id: StringName,
	pitch_variation: float = 0.04,
	volume_db: float = 0.0,
) -> void:
	if not _streams.has(sound_id) or _players.is_empty():
		return

	var selected := _find_player()
	selected.stop()
	selected.stream = _streams[sound_id]
	selected.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	selected.volume_db = volume_db
	selected.play()


func play_ui() -> void:
	play(&"ui", 0.02, -3.0)


func set_master_volume(percent: float) -> void:
	var normalized := clampf(percent / 100.0, 0.0, 1.0)
	var volume_db := -80.0 if normalized <= 0.0 else linear_to_db(normalized)
	AudioServer.set_bus_volume_db(0, volume_db)
	_save_settings(normalized * 100.0)


func get_master_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0


func _find_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _players:
		if not player.playing:
			return player
	var player := _players[_next_player % _players.size()]
	_next_player = (_next_player + 1) % _players.size()
	return player


func _on_hit_resolved(_world_position: Vector2, strength: float) -> void:
	if strength >= 0.22:
		play(&"hit_heavy", 0.05, -2.0)
	else:
		play(&"hit_light", 0.07, -3.0)


func _on_block_succeeded(_world_position: Vector2) -> void:
	play(&"block", 0.04, -3.0)


func _on_parry_succeeded(_world_position: Vector2, _weapon_id: StringName) -> void:
	play(&"parry", 0.025, 0.0)


func _on_dodge_started(_world_position: Vector2) -> void:
	play(&"dodge", 0.08, -7.0)


func _on_burrow_started(_world_position: Vector2) -> void:
	play(&"burrow", 0.05, -5.0)


func _on_burrow_emerged(_world_position: Vector2) -> void:
	play(&"emerge", 0.04, -2.0)


func _on_actor_died(actor: Node, _context: Dictionary) -> void:
	if actor.is_in_group(&"enemy"):
		play(&"enemy_death", 0.04, -4.0)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		set_master_volume(80.0)
		return
	var percent := float(config.get_value("audio", "master_volume", 80.0))
	var normalized := clampf(percent / 100.0, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, -80.0 if normalized <= 0.0 else linear_to_db(normalized))


func _save_settings(percent: float) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", "master_volume", clampf(percent, 0.0, 100.0))
	config.save(SETTINGS_PATH)
