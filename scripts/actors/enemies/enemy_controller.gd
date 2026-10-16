class_name EnemyController
extends CharacterBody2D

const STATE_IDLE: StringName = &"idle"
const STATE_APPROACH: StringName = &"approach"
const STATE_RETREAT: StringName = &"retreat"
const STATE_GUARD: StringName = &"guard"
const STATE_ATTACK: StringName = &"attack"
const STATE_HIT: StringName = &"hit"
const STATE_LAUNCHED: StringName = &"launched"
const STATE_KNOCKDOWN: StringName = &"knockdown"
const STATE_DEAD: StringName = &"dead"

const JUGGLE_DAMAGE_SCALE: Array[float] = [1.0, 0.85, 0.7, 0.55]

@export var profile: EnemyProfile
@export_range(1, 6, 1) var max_juggle_hits: int = 3
@export_range(0.0, 5000.0, 1.0) var gravity: float = 1500.0
@export_range(0.0, 10.0, 0.1) var guard_duration: float = 0.65
@export_range(0.0, 100.0, 0.1) var guard_qi_per_second: float = 18.0
@export_range(0.0, 200.0, 1.0) var actor_contact_distance: float = 54.0

@onready var state_machine: ActorStateMachine = $StateMachine
@onready var health: HealthComponent = $HealthComponent
@onready var posture: PostureComponent = $PostureComponent
@onready var qi: QiComponent = $QiComponent
@onready var shi: ShiComponent = $ShiComponent
@onready var hitbox: HitboxComponent = $AttackHitbox
@onready var visual: Polygon2D = $Visual
@onready var hurtbox: HurtboxComponent = $Hurtbox

var facing_direction: int = -1
var current_attack_data: AttackData
var attack_mode: StringName = &"melee"
var projectile_spawned: bool = false
var hitstun_frames_remaining: int = 0
var knockdown_frames_remaining: int = 0
var guard_frames_remaining: int = 0
var current_juggle_hits: int = 0
var decision_cooldown: float = 0.0
var _player: PlayerController


func _ready() -> void:
	floor_snap_length = 8.0
	floor_stop_on_slope = true
	_apply_profile()
	health.died.connect(_on_died)
	state_machine.transition_to(STATE_IDLE)


func _physics_process(delta: float) -> void:
	state_machine.tick()
	decision_cooldown = maxf(decision_cooldown - delta, 0.0)
	_resolve_player()

	if not is_on_floor():
		velocity.y += gravity * delta

	match state_machine.current_state:
		STATE_IDLE:
			_process_idle()
		STATE_APPROACH:
			_process_approach(delta)
		STATE_RETREAT:
			_process_retreat(delta)
		STATE_GUARD:
			_process_guard(delta)
		STATE_ATTACK:
			_process_attack(delta)
		STATE_HIT:
			_process_hit(delta)
		STATE_LAUNCHED:
			if is_on_floor():
				_enter_knockdown(28)
		STATE_KNOCKDOWN:
			_process_knockdown(delta)
		STATE_DEAD:
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)

	_prevent_player_overlap()
	move_and_slide()
	visual.scale.x = float(facing_direction)


func _apply_profile() -> void:
	if profile == null:
		push_warning("Enemy has no profile: %s" % name)
		return
	health.max_health = profile.max_health
	health.reset()
	posture.max_posture = profile.max_posture
	posture.reset()
	qi.max_qi = profile.max_qi
	qi.recovery_per_second = profile.qi_recovery_per_second
	qi.reset()


func _process_idle() -> void:
	if _player == null:
		return
	if global_position.distance_to(_player.global_position) < 720.0:
		state_machine.transition_to(STATE_APPROACH)


func _process_approach(delta: float) -> void:
	if _player == null:
		state_machine.transition_to(STATE_IDLE)
		return

	var distance := global_position.distance_to(_player.global_position)
	face_position(_player.global_position)

	if distance <= profile.preferred_range_min:
		velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
	else:
		velocity.x = profile.move_speed * float(facing_direction)

	if decision_cooldown <= 0.0 and _can_act_from_distance(distance):
		_choose_action(distance)


func _process_retreat(delta: float) -> void:
	if _player == null:
		state_machine.transition_to(STATE_IDLE)
		return

	var distance := global_position.distance_to(_player.global_position)
	face_position(_player.global_position)
	if distance >= profile.preferred_range_min:
		state_machine.transition_to(STATE_APPROACH)
		return
	velocity.x = -profile.move_speed * float(facing_direction)


func _process_guard(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	guard_frames_remaining -= 1
	if guard_frames_remaining <= 0 or qi.current_qi <= 0.0:
		state_machine.transition_to(STATE_APPROACH)
		return
	if not qi.consume(guard_qi_per_second * delta):
		state_machine.transition_to(STATE_HIT)


func _process_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 1000.0 * delta)
	if attack_mode == &"projectile" and not projectile_spawned:
		if state_machine.frames_in_state >= current_attack_data.startup_frames:
			_spawn_projectile()

	if state_machine.frames_in_state >= current_attack_data.total_frames:
		current_attack_data = null
		attack_mode = &"melee"
		hitbox.cancel_attack()
		decision_cooldown = 0.35
		state_machine.transition_to(STATE_APPROACH)


func _process_hit(delta: float) -> void:
	hitstun_frames_remaining -= 1
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	if hitstun_frames_remaining <= 0:
		state_machine.transition_to(STATE_APPROACH)


func _process_knockdown(delta: float) -> void:
	knockdown_frames_remaining -= 1
	velocity.x = move_toward(velocity.x, 0.0, 1000.0 * delta)
	if knockdown_frames_remaining <= 0:
		current_juggle_hits = 0
		state_machine.transition_to(STATE_APPROACH)


func _can_act_from_distance(distance: float) -> bool:
	if _player != null and _player.is_burrowed():
		return distance <= 190.0
	if profile.archetype == EnemyProfile.Archetype.CLERIC_OFFICER:
		return distance <= profile.preferred_range_max + 80.0
	return distance <= profile.preferred_range_max


func _choose_action(distance: float) -> void:
	if profile == null or _player == null:
		return

	if _player.is_burrowed() and profile.anti_burrow_attack != null:
		_start_melee(profile.anti_burrow_attack)
		return

	if profile.uses_guard and qi.current_qi > 25.0 and randf() < profile.guard_chance:
		guard_frames_remaining = maxi(1, roundi(guard_duration * 60.0))
		state_machine.transition_to(STATE_GUARD)
		return

	if profile.archetype == EnemyProfile.Archetype.CLERIC_OFFICER:
		if distance <= 130.0 and not profile.melee_attacks.is_empty():
			_start_melee(profile.melee_attacks.pick_random())
			return
		if distance <= profile.preferred_range_max + 80.0 and profile.projectile_attack != null:
			_start_projectile(profile.projectile_attack)
			return
		if distance < profile.preferred_range_min:
			state_machine.transition_to(STATE_RETREAT)
			return

	if profile.unblockable_attack != null and randf() < 0.18:
		_start_melee(profile.unblockable_attack)
		return
	if not profile.melee_attacks.is_empty():
		_start_melee(profile.melee_attacks.pick_random())


func _start_melee(attack_data: AttackData) -> void:
	if attack_data == null:
		return
	current_attack_data = attack_data
	attack_mode = &"melee"
	projectile_spawned = false
	state_machine.transition_to(STATE_ATTACK)
	hitbox.begin_attack(attack_data, facing_direction)


func _start_projectile(attack_data: AttackData) -> void:
	if attack_data == null or profile.projectile_scene == null:
		return
	current_attack_data = attack_data
	attack_mode = &"projectile"
	projectile_spawned = false
	state_machine.transition_to(STATE_ATTACK)


func _spawn_projectile() -> void:
	if profile.projectile_scene == null or current_attack_data == null:
		return
	var projectile := profile.projectile_scene.instantiate() as EnemyProjectile
	if projectile == null:
		return
	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(projectile)
	projectile.global_position = global_position + Vector2(42.0 * facing_direction, -46.0)
	projectile.setup(current_attack_data, facing_direction, self)
	projectile_spawned = true


func receive_hit(
	attacker: Node,
	attack_data: AttackData,
	direction: int,
) -> HurtboxComponent.ReceiveResult:
	if state_machine.is_state(STATE_DEAD):
		return HurtboxComponent.ReceiveResult.IGNORED

	if state_machine.is_state(STATE_GUARD) and attack_data.attack_type == AttackData.AttackType.NORMAL:
		if qi.consume(attack_data.guard_qi_damage):
			posture.take_posture_damage(attack_data.posture_damage)
			return HurtboxComponent.ReceiveResult.BLOCK

	var target_is_launched := state_machine.is_state(STATE_LAUNCHED)
	if target_is_launched and attack_data.juggle_cost > 0 and current_juggle_hits >= max_juggle_hits:
		return HurtboxComponent.ReceiveResult.IGNORED

	var damage_scale := 1.0
	if target_is_launched:
		damage_scale = JUGGLE_DAMAGE_SCALE[mini(current_juggle_hits, JUGGLE_DAMAGE_SCALE.size() - 1)]

	if not CombatResolver.resolve_hit(attacker, self, attack_data, direction, damage_scale):
		return HurtboxComponent.ReceiveResult.IGNORED

	if target_is_launched or attack_data.reaction_type == AttackData.ReactionType.LAUNCH:
		current_juggle_hits += maxi(attack_data.juggle_cost, 1)

	return HurtboxComponent.ReceiveResult.HIT


func apply_hit_reaction(attack_data: AttackData, direction: int) -> void:
	hitbox.cancel_attack()
	current_attack_data = null
	attack_mode = &"melee"

	match attack_data.reaction_type:
		AttackData.ReactionType.LAUNCH:
			state_machine.transition_to(STATE_LAUNCHED)
			velocity = Vector2(
				attack_data.launch_velocity.x * direction,
				attack_data.launch_velocity.y,
			)
		AttackData.ReactionType.KNOCKDOWN:
			_enter_knockdown(attack_data.knockdown_frames)
			velocity.x = attack_data.knockback.x * direction
		_:
			hitstun_frames_remaining = attack_data.hitstun_frames
			velocity = Vector2(
				attack_data.knockback.x * direction,
				attack_data.knockback.y,
			)
			state_machine.transition_to(STATE_HIT)

	var tween := create_tween()
	visual.modulate = Color(1.0, 0.35, 0.35, 1.0)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.12)


func apply_parry_stun(frames: int) -> void:
	hitstun_frames_remaining = frames
	velocity.x = 0.0
	state_machine.transition_to(STATE_HIT)


func is_knockdown() -> bool:
	return state_machine.is_state(STATE_KNOCKDOWN)


func face_position(target_position: Vector2) -> void:
	facing_direction = 1 if target_position.x >= global_position.x else -1


func _enter_knockdown(frames: int) -> void:
	knockdown_frames_remaining = maxi(frames, 1)
	state_machine.transition_to(STATE_KNOCKDOWN)


func _on_died() -> void:
	hitbox.cancel_attack()
	state_machine.transition_to(STATE_DEAD)
	visual.modulate = Color(0.25, 0.25, 0.25, 1.0)


func _resolve_player() -> void:
	if is_instance_valid(_player):
		return
	_player = get_tree().get_first_node_in_group(&"player") as PlayerController


func _prevent_player_overlap() -> void:
	if _player == null or state_machine.is_state(STATE_DEAD):
		return
	if absf(_player.global_position.y - global_position.y) > 64.0:
		return

	var horizontal_delta := _player.global_position.x - global_position.x
	var horizontal_distance := absf(horizontal_delta)
	if horizontal_distance >= actor_contact_distance:
		return

	var away_direction := -1.0 if horizontal_delta >= 0.0 else 1.0
	global_position.x += away_direction * (actor_contact_distance - horizontal_distance)
	velocity.x = 0.0
