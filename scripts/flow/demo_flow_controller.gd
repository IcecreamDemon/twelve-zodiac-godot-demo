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

var flow_state: FlowState = FlowState.PROLOGUE
var behavior_recorder: BehaviorRecorder
var incense_returned: bool = false
var active_enemy: EnemyController
var retrying: bool = false


func _ready() -> void:
	behavior_recorder = BehaviorRecorder.new()
	player.behavior_recorder = behavior_recorder
	player.health.died.connect(_on_player_died)
	continue_button.pressed.connect(_on_continue_pressed)
	return_button.pressed.connect(_on_return_incense)
	shop_button.pressed.connect(_on_spend_incense)
	_set_state(FlowState.PROLOGUE)


func _set_state(next_state: FlowState) -> void:
	flow_state = next_state
	retrying = false
	_clear_encounter()
	choice_panel.visible = false
	dialogue_panel.visible = false
	ending_label.visible = false

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
			_set_state(FlowState.TUTORIAL)
		FlowState.TUTORIAL, FlowState.ELITE, FlowState.OLD_SELF, FlowState.BOSS:
			dialogue_panel.visible = false
		FlowState.COMPLETE:
			get_tree().reload_current_scene()


func _on_return_incense() -> void:
	incense_returned = true
	player.shi.add(20.0)
	_set_state(FlowState.ELITE)


func _on_spend_incense() -> void:
	incense_returned = false
	player.health.restore(25.0)
	player.qi.restore(20.0)
	_set_state(FlowState.ELITE)


func _on_enemy_died(enemy: EnemyController) -> void:
	if enemy != active_enemy:
		return
	active_enemy = null
	match flow_state:
		FlowState.TUTORIAL:
			_set_state(FlowState.CHOICE)
		FlowState.ELITE:
			_set_state(FlowState.OLD_SELF)
		FlowState.OLD_SELF:
			_set_state(FlowState.BOSS)
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
