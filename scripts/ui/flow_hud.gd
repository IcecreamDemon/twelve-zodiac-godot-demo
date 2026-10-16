class_name FlowHud
extends CanvasLayer

@onready var player_name: Label = $Root/PlayerName
@onready var player_state: Label = $Root/PlayerState
@onready var player_health: ProgressBar = $Root/PlayerHealth
@onready var player_health_text: Label = $Root/PlayerHealthText
@onready var player_posture: ProgressBar = $Root/PlayerPosture
@onready var player_posture_text: Label = $Root/PlayerPostureText
@onready var player_qi: ProgressBar = $Root/PlayerQi
@onready var player_qi_text: Label = $Root/PlayerQiText
@onready var player_shi: ProgressBar = $Root/PlayerShi
@onready var player_shi_text: Label = $Root/PlayerShiText

@onready var enemy_name: Label = $Root/EnemyName
@onready var enemy_state: Label = $Root/EnemyState
@onready var enemy_health: ProgressBar = $Root/EnemyHealth
@onready var enemy_health_text: Label = $Root/EnemyHealthText
@onready var enemy_posture: ProgressBar = $Root/EnemyPosture
@onready var enemy_posture_text: Label = $Root/EnemyPostureText
@onready var enemy_qi: ProgressBar = $Root/EnemyQi
@onready var enemy_qi_text: Label = $Root/EnemyQiText
@onready var enemy_shi: ProgressBar = $Root/EnemyShi
@onready var enemy_shi_text: Label = $Root/EnemyShiText


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as PlayerController
	if player != null:
		_update_actor(player, player_name, player_state, player_health, player_health_text,
			player_posture, player_posture_text, player_qi, player_qi_text,
			player_shi, player_shi_text, "鼠光")
	else:
		_clear_actor(player_name, player_state, player_health, player_health_text,
			player_posture, player_posture_text, player_qi, player_qi_text,
			player_shi, player_shi_text, "PLAYER")

	var enemy := _find_enemy()
	if enemy != null:
		_update_actor(enemy, enemy_name, enemy_state, enemy_health, enemy_health_text,
			enemy_posture, enemy_posture_text, enemy_qi, enemy_qi_text,
			enemy_shi, enemy_shi_text, enemy.display_name())
	else:
		_clear_actor(enemy_name, enemy_state, enemy_health, enemy_health_text,
			enemy_posture, enemy_posture_text, enemy_qi, enemy_qi_text,
			enemy_shi, enemy_shi_text, "ENEMY")


func _find_enemy() -> Node:
	var enemies := get_tree().get_nodes_in_group(&"enemy")
	for node: Node in enemies:
		var health := node.get_node_or_null("HealthComponent") as HealthComponent
		if health != null and health.current_health > 0.0:
			return node
	return null


func _update_actor(
	actor: Node,
	name_label: Label,
	state_label: Label,
	health_bar: ProgressBar,
	health_text: Label,
	posture_bar: ProgressBar,
	posture_text: Label,
	qi_bar: ProgressBar,
	qi_text: Label,
	shi_bar: ProgressBar,
	shi_text: Label,
	display_name: String,
) -> void:
	var health := actor.get_node("HealthComponent") as HealthComponent
	var posture := actor.get_node("PostureComponent") as PostureComponent
	var qi := actor.get_node("QiComponent") as QiComponent
	var shi := actor.get_node("ShiComponent") as ShiComponent
	var machine := actor.get_node("StateMachine") as ActorStateMachine

	name_label.text = display_name
	state_label.text = "状态  %s" % String(machine.current_state).to_upper()
	_update_bar(health_bar, health_text, "生命", health.current_health, health.max_health)
	_update_bar(posture_bar, posture_text, "架势", posture.current_posture, posture.max_posture)
	_update_bar(qi_bar, qi_text, "气", qi.current_qi, qi.max_qi)
	_update_bar(shi_bar, shi_text, "势", shi.current_shi, shi.max_shi)


func _update_bar(
	bar: ProgressBar,
	label: Label,
	prefix: String,
	current: float,
	maximum: float,
) -> void:
	bar.max_value = maximum
	bar.value = current
	label.text = "%s  %d / %d" % [prefix, roundi(current), roundi(maximum)]


func _clear_actor(
	name_label: Label,
	state_label: Label,
	health_bar: ProgressBar,
	health_text: Label,
	posture_bar: ProgressBar,
	posture_text: Label,
	qi_bar: ProgressBar,
	qi_text: Label,
	shi_bar: ProgressBar,
	shi_text: Label,
	display_name: String,
) -> void:
	name_label.text = display_name
	state_label.text = "状态  --"
	for bar: ProgressBar in [health_bar, posture_bar, qi_bar, shi_bar]:
		bar.value = 0.0
	for label: Label in [health_text, posture_text, qi_text, shi_text]:
		label.text = ""
