class_name CombatHud
extends CanvasLayer

@onready var player_health_bar: ProgressBar = $Root/PlayerHealthBar
@onready var player_posture_bar: ProgressBar = $Root/PlayerPostureBar
@onready var player_qi_bar: ProgressBar = $Root/PlayerQiBar
@onready var player_shi_bar: ProgressBar = $Root/PlayerShiBar
@onready var player_health_label: Label = $Root/PlayerHealthLabel
@onready var player_posture_label: Label = $Root/PlayerPostureLabel
@onready var player_qi_label: Label = $Root/PlayerQiLabel
@onready var player_shi_label: Label = $Root/PlayerShiLabel
@onready var player_state_label: Label = $Root/PlayerStateLabel
@onready var dummy_health_bar: ProgressBar = $Root/DummyHealthBar
@onready var dummy_posture_bar: ProgressBar = $Root/DummyPostureBar
@onready var dummy_state_label: Label = $Root/DummyStateLabel

var _player: PlayerController
var _dummy: TrainingDummy


func _ready() -> void:
	player_health_bar.max_value = 100.0
	player_posture_bar.max_value = 100.0
	player_qi_bar.max_value = 100.0
	player_shi_bar.max_value = 100.0
	dummy_health_bar.max_value = 100.0
	dummy_posture_bar.max_value = 100.0


func _process(_delta: float) -> void:
	_resolve_actors()
	if _player == null or _dummy == null:
		return

	player_health_bar.value = _player.health.current_health
	player_health_bar.max_value = _player.health.max_health
	player_posture_bar.value = _player.posture.current_posture
	player_posture_bar.max_value = _player.posture.max_posture
	player_qi_bar.value = _player.qi.current_qi
	player_qi_bar.max_value = _player.qi.max_qi
	player_shi_bar.value = _player.shi.current_shi
	player_shi_bar.max_value = _player.shi.max_shi
	player_health_label.text = "生命  %d / %d" % [
		roundi(_player.health.current_health),
		roundi(_player.health.max_health),
	]
	player_posture_label.text = "架势  %d / %d" % [
		roundi(_player.posture.current_posture),
		roundi(_player.posture.max_posture),
	]
	player_qi_label.text = "气  %d / %d" % [
		roundi(_player.qi.current_qi),
		roundi(_player.qi.max_qi),
	]
	player_shi_label.text = "势  %d / %d" % [
		roundi(_player.shi.current_shi),
		roundi(_player.shi.max_shi),
	]
	player_state_label.text = "STATE  %s" % String(_player.state_machine.current_state).to_upper()

	dummy_health_bar.value = _dummy.health.current_health
	dummy_health_bar.max_value = _dummy.health.max_health
	dummy_posture_bar.value = _dummy.posture.current_posture
	dummy_posture_bar.max_value = _dummy.posture.max_posture
	dummy_state_label.text = "STATE  %s" % String(_dummy.state_machine.current_state).to_upper()


func _resolve_actors() -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(&"player") as PlayerController
	if not is_instance_valid(_dummy):
		_dummy = get_tree().get_first_node_in_group(&"training_dummy") as TrainingDummy
