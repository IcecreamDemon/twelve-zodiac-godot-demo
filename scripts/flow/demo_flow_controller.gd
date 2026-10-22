class_name DemoFlowController
extends Node2D

enum FlowState {
	PROLOGUE,
	TUTORIAL,
	CHOICE,
	ELITE,
	OLD_SELF,
	BOSS,
	COMPLETE,
}

const TIAN_BING_SCENE := preload("res://scenes/actors/enemies/tian_bing.tscn")
const GUARDIAN_SCENE := preload("res://scenes/actors/enemies/guardian.tscn")
const OLD_SELF_SCENE := preload("res://scenes/actors/enemies/old_self.tscn")
const BOSS_SCENE := preload("res://scenes/actors/boss/duo_yuan_shen.tscn")
const BURNER_SCENE := preload("res://scenes/actors/incense_burner.tscn")

@onready var player: PlayerController = $Player
@onready var encounter_root: Node2D = $EncounterRoot
@onready var dialogue_panel: Panel = $Ui/Root/DialoguePanel
@onready var dialogue_label: Label = $Ui/Root/DialoguePanel/DialogueLabel
@onready var continue_button: Button = $Ui/Root/DialoguePanel/ContinueButton
@onready var choice_panel: Panel = $Ui/Root/ChoicePanel
@onready var return_button: Button = $Ui/Root/ChoicePanel/ReturnButton
@onready var shop_button: Button = $Ui/Root/ChoicePanel/ShopButton
@onready var ending_label: Label = $Ui/Root/EndingLabel
@onready var victory_panel: Panel = $Ui/Root/VictoryPanel
@onready var victory_label: Label = $Ui/Root/VictoryPanel/VictoryLabel
@onready var node_map: NodeMapController = $NodeMap

var flow_state: FlowState = FlowState.PROLOGUE
var behavior_recorder: BehaviorRecorder
var incense_returned: bool = false
var incense_currency: int = 20
var evidence_count: int = 0
var active_enemy: EnemyController
var retrying: bool = false
var shop_damage_bought: bool = false
var shop_health_bought: bool = false
var shop_qi_bought: bool = false
var shop_posture_bought: bool = false


func _ready() -> void:
	behavior_recorder = BehaviorRecorder.new()
	player.behavior_recorder = behavior_recorder
	player.health.died.connect(_on_player_died)
	continue_button.pressed.connect(_on_continue_pressed)
	return_button.pressed.connect(_on_return_incense)
	shop_button.pressed.connect(_on_spend_incense)
	node_map.option_selected.connect(_on_node_option_selected)
	_set_state(FlowState.PROLOGUE)


func _set_state(next_state: FlowState) -> void:
	flow_state = next_state
	retrying = false
	_clear_encounter()
	choice_panel.visible = false
	dialogue_panel.visible = false
	ending_label.visible = false
	victory_panel.visible = false
	node_map.hide_options()

	match flow_state:
		FlowState.PROLOGUE:
			_show_dialogue("鼠光战死，阎王递来一纸还魂契。继续登天，先活着走过第一座哨站。")
		FlowState.TUTORIAL:
			_spawn_enemy(TIAN_BING_SCENE, Vector2(1320.0, 860.0), "天兵挡住去路。")
		FlowState.CHOICE:
			_show_choice()
		FlowState.ELITE:
			_spawn_enemy(GUARDIAN_SCENE, Vector2(1360.0, 860.0), "断雨校尉的盾阵封住了山路。")
		FlowState.OLD_SELF:
			_spawn_old_self()
		FlowState.BOSS:
			_spawn_boss()
		FlowState.COMPLETE:
			ending_label.text = "夺愿神倒下。那张借来的脸，属于许安。"
			ending_label.visible = true


func _spawn_enemy(scene: PackedScene, spawn_position: Vector2, message: String) -> void:
	var enemy := scene.instantiate() as EnemyController
	enemy.global_position = spawn_position
	encounter_root.add_child(enemy)
	enemy.health.died.connect(_on_enemy_died.bind(enemy))
	active_enemy = enemy
	_show_dialogue(message)


func _spawn_old_self() -> void:
	var old_self := OLD_SELF_SCENE.instantiate() as OldSelfAI
	old_self.behavior_profile = behavior_recorder.build_profile()
	old_self.global_position = Vector2(1380.0, 860.0)
	encounter_root.add_child(old_self)
	old_self.health.died.connect(_on_enemy_died.bind(old_self))
	active_enemy = old_self
	_show_dialogue("被困的宿主以鼠光的招式站了起来。")


func _spawn_boss() -> void:
	var boss := BOSS_SCENE.instantiate() as DuoYuanShenAI
	boss.global_position = Vector2(1450.0, 860.0)
	encounter_root.add_child(boss)
	boss.health.died.connect(_on_enemy_died.bind(boss))
	active_enemy = boss
	_spawn_burner(Vector2(820.0, 828.0))
	_spawn_burner(Vector2(1080.0, 828.0))
	_show_dialogue("夺愿神把香火收进护盾。击破香炉，夺回势。")


func _spawn_burner(spawn_position: Vector2) -> void:
	var burner := BURNER_SCENE.instantiate() as IncenseBurner
	burner.global_position = spawn_position
	encounter_root.add_child(burner)


func _show_dialogue(message: String) -> void:
	dialogue_label.text = message
	dialogue_panel.visible = true


func _show_choice() -> void:
	player.health.restore(35.0)
	choice_panel.visible = true


func _on_continue_pressed() -> void:
	if retrying:
		_set_state(flow_state)
		return

	match flow_state:
		FlowState.PROLOGUE:
			_show_node_selection(
				"无雨乡 · 第一节点",
				[{"id": "tutorial", "title": "进入天兵哨站"}],
			)
		FlowState.TUTORIAL, FlowState.ELITE, FlowState.OLD_SELF, FlowState.BOSS:
			dialogue_panel.visible = false
		FlowState.COMPLETE:
			get_tree().reload_current_scene()


func _on_return_incense() -> void:
	incense_returned = true
	evidence_count += 1
	incense_currency = maxi(incense_currency - 15, 0)
	player.shi.add(20.0)
	_set_state(FlowState.ELITE)


func _on_spend_incense() -> void:
	incense_returned = false
	_open_shop()


func _open_shop() -> void:
	var options: Array[Dictionary] = []
	if not shop_damage_bought:
		options.append({"id": "shop_damage", "title": "兵刃开锋（20 香火）：伤害 +2"})
	if not shop_health_bought:
		options.append({"id": "shop_health", "title": "粗布护甲（20 香火）：最大生命 +20"})
	if not shop_qi_bought:
		options.append({"id": "shop_qi", "title": "静心符（20 香火）：最大气 +20"})
	if not shop_posture_bought:
		options.append({"id": "shop_posture", "title": "护脊木牌（20 香火）：最大架势 +20"})
	options.append({"id": "shop_leave", "title": "离开商店，继续登天"})
	_show_node_selection("祝安商店 · 香火 %d" % incense_currency, options)


func _buy_shop_option(option_id: StringName) -> void:
	if incense_currency < 20:
		_open_shop()
		return
	match option_id:
		&"shop_damage":
			shop_damage_bought = true
			player.bonus_damage += 2.0
		&"shop_health":
			shop_health_bought = true
			player.health.max_health += 20.0
			player.health.restore(20.0)
		&"shop_qi":
			shop_qi_bought = true
			player.qi.max_qi += 20.0
			player.qi.restore(20.0)
		&"shop_posture":
			shop_posture_bought = true
			player.posture.max_posture += 20.0
			player.posture.reset()
	incense_currency -= 20
	_open_shop()


func _on_enemy_died(enemy: EnemyController) -> void:
	if enemy != active_enemy:
		return
	active_enemy = null
	await _play_victory_animation()
	_clear_encounter()
	match flow_state:
		FlowState.TUTORIAL:
			incense_currency += 20
			_show_node_selection(
				"香火归属 · 当前香火 %d" % incense_currency,
				[
					{"id": "return_incense", "title": "归还香火：获得关键线索"},
					{"id": "spend_incense", "title": "进入祝安商店：购买局内强化"},
					{"id": "rest_at_shrine", "title": "在破庙休整：恢复 40 生命"},
				],
			)
		FlowState.ELITE:
			incense_currency += 30
			_show_node_selection(
				"战利品三选一 · 当前香火 %d" % incense_currency,
				[
					{"id": "elite_reward_damage", "title": "磨砺兵刃：所有攻击伤害 +2"},
					{"id": "elite_reward_health", "title": "披上旧甲：最大生命 +20"},
					{"id": "elite_reward_qi", "title": "静气凝神：最大气 +20"},
				],
			)
		FlowState.OLD_SELF:
			incense_currency += 20
			_show_node_selection(
				"旧我残页 · 当前香火 %d" % incense_currency,
				[{"id": "accept_evidence", "title": "收下残页：证据 +1，直面夺愿神"}],
			)
		FlowState.BOSS:
			_set_state(FlowState.COMPLETE)


func _on_player_died() -> void:
	retrying = true
	player.health.reset()
	player.posture.reset()
	player.qi.reset()
	player.shi.reset()
	dialogue_label.text = "鼠光倒下。宿主留在原地，当前节点重新开始。"
	dialogue_panel.visible = true


func _clear_encounter() -> void:
	active_enemy = null
	for child: Node in encounter_root.get_children():
		child.queue_free()


func _show_node_selection(title: String, options: Array[Dictionary]) -> void:
	dialogue_panel.visible = false
	node_map.show_options(title, options)


func _on_node_option_selected(option_id: StringName) -> void:
	match option_id:
		&"tutorial":
			_set_state(FlowState.TUTORIAL)
		&"return_incense":
			_on_return_incense()
		&"spend_incense":
			_open_shop()
		&"rest_at_shrine":
			player.health.restore(40.0)
			_set_state(FlowState.ELITE)
		&"shop_damage", &"shop_health", &"shop_qi", &"shop_posture":
			_buy_shop_option(option_id)
		&"shop_leave":
			_set_state(FlowState.ELITE)
		&"elite_reward_damage":
			player.bonus_damage += 2.0
			_set_state(FlowState.OLD_SELF)
		&"elite_reward_health":
			player.health.max_health += 20.0
			player.health.restore(20.0)
			_set_state(FlowState.OLD_SELF)
		&"elite_reward_qi":
			player.qi.max_qi += 20.0
			player.qi.restore(20.0)
			_set_state(FlowState.OLD_SELF)
		&"accept_evidence":
			evidence_count += 1
			_set_state(FlowState.BOSS)


func _play_victory_animation() -> void:
	victory_label.text = "战斗结束"
	victory_panel.visible = true
	victory_panel.modulate.a = 0.0
	victory_panel.scale = Vector2(0.92, 0.92)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(victory_panel, "modulate:a", 1.0, 0.22)
	tween.tween_property(victory_panel, "scale", Vector2.ONE, 0.22)
	await get_tree().create_timer(0.8).timeout
	var fade := create_tween()
	fade.tween_property(victory_panel, "modulate:a", 0.0, 0.22)
	await fade.finished
	victory_panel.visible = false
