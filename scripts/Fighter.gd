extends CharacterBody2D

## Controller principal do lutador controlado pelo jogador.
## Lê inputs, delega à FSM e gerencia hitbox/hurtbox + feedback visual.

const SPEED: float = 200.0
const BASE_ATTACK_DAMAGE: float = 15.0

# Duração de cada fase do ataque (em segundos)
const PREP_DURATION: float = 0.15
const ACTIVE_DURATION: float = 0.1
const RECOVERY_DURATION: float = 0.3
const HIT_STUN_DURATION: float = 0.4

@onready var fsm: FighterFSM = $FSM
@onready var resources: FighterResources = $Resources
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitboxShape
@onready var sprite: Polygon2D = $Sprite

var _block_time: float = 0.0
var _attack_timer: float = 0.0
var _hit_stun_timer: float = 0.0

func _ready() -> void:
	hitbox_shape.disabled = true
	fsm.state_changed.connect(_on_state_changed)

func _physics_process(delta: float) -> void:
	if resources.current_health <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_handle_input()
	_update_attack_phases(delta)
	_update_block_time(delta)
	_update_hit_stun(delta)
	_update_visuals()
	move_and_slide()

# --- Input ---

func _handle_input() -> void:
	if fsm.current_state == FighterFSM.State.IDLE_MOVEMENT:
		var direction := 0.0
		if Input.is_action_pressed("move_left"):
			direction = -1.0
		elif Input.is_action_pressed("move_right"):
			direction = 1.0
		velocity.x = direction * SPEED

		if Input.is_action_just_pressed("attack"):
			_start_attack()
			return

		if Input.is_action_pressed("block"):
			_start_block()
			return

	elif fsm.current_state == FighterFSM.State.BLOCKING:
		velocity.x = 0
		if Input.is_action_just_released("block"):
			fsm.force_change_state(FighterFSM.State.IDLE_MOVEMENT)

	elif fsm.current_state == FighterFSM.State.HIT_REACTION:
		velocity.x = 0

# --- Ações ---

func _start_attack() -> void:
	if not resources.consume_stamina(12.0):
		return
	velocity.x = 0
	_attack_timer = 0.0
	fsm.force_change_state(FighterFSM.State.ATTACK_PREP)

func _start_block() -> void:
	velocity.x = 0
	_block_time = 0.0
	fsm.force_change_state(FighterFSM.State.BLOCKING)

# --- Timers de Fase ---

func _update_attack_phases(delta: float) -> void:
	if not fsm.is_attacking():
		return
	_attack_timer += delta
	match fsm.current_state:
		FighterFSM.State.ATTACK_PREP:
			if _attack_timer >= PREP_DURATION:
				_attack_timer = 0.0
				fsm.force_change_state(FighterFSM.State.ATTACK_ACTIVE)
				hitbox_shape.disabled = false
		FighterFSM.State.ATTACK_ACTIVE:
			if _attack_timer >= ACTIVE_DURATION:
				_attack_timer = 0.0
				hitbox_shape.disabled = true
				fsm.force_change_state(FighterFSM.State.ATTACK_RECOVERY)
		FighterFSM.State.ATTACK_RECOVERY:
			if _attack_timer >= RECOVERY_DURATION:
				_attack_timer = 0.0
				fsm.force_change_state(FighterFSM.State.IDLE_MOVEMENT)

func _update_block_time(delta: float) -> void:
	if fsm.current_state == FighterFSM.State.BLOCKING:
		_block_time += delta

func _update_hit_stun(delta: float) -> void:
	if fsm.current_state == FighterFSM.State.HIT_REACTION:
		_hit_stun_timer += delta
		if _hit_stun_timer >= HIT_STUN_DURATION:
			_hit_stun_timer = 0.0
			fsm.force_change_state(FighterFSM.State.IDLE_MOVEMENT)

# --- Callbacks ---

func _on_state_changed(_old_state: FighterFSM.State, new_state: FighterFSM.State) -> void:
	if new_state == FighterFSM.State.HIT_REACTION:
		_hit_stun_timer = 0.0
		hitbox_shape.disabled = true
		_attack_timer = 0.0

# --- API Pública (chamada pelo CombatScene) ---

func deactivate_hitbox() -> void:
	hitbox_shape.disabled = true

func get_attack_damage() -> float:
	return BASE_ATTACK_DAMAGE

func get_block_time() -> float:
	return _block_time

# --- Feedback Visual ---

func _update_visuals() -> void:
	match fsm.current_state:
		FighterFSM.State.IDLE_MOVEMENT:
			sprite.color = Color(0.2, 0.4, 0.9, 1.0)    # Azul
		FighterFSM.State.BLOCKING:
			sprite.color = Color(0.1, 0.2, 0.5, 1.0)    # Azul escuro
		FighterFSM.State.ATTACK_PREP:
			sprite.color = Color(0.9, 0.7, 0.1, 1.0)    # Amarelo
		FighterFSM.State.ATTACK_ACTIVE:
			sprite.color = Color(1.0, 1.0, 1.0, 1.0)    # Branco
		FighterFSM.State.ATTACK_RECOVERY:
			sprite.color = Color(0.5, 0.5, 0.7, 1.0)    # Cinza azulado
		FighterFSM.State.HIT_REACTION:
			sprite.color = Color(0.9, 0.1, 0.1, 1.0)    # Vermelho
