extends CharacterBody2D

## Controller do oponente (IA básica para testes do protótipo).
## Persegue o alvo e alterna entre ataques e bloqueios aleatórios.

const SPEED: float = 120.0
const BASE_ATTACK_DAMAGE: float = 12.0

const PREP_DURATION: float = 0.20   # Levemente mais lento que o jogador
const ACTIVE_DURATION: float = 0.1
const RECOVERY_DURATION: float = 0.35
const HIT_STUN_DURATION: float = 0.4

@onready var fsm: FighterFSM = $FSM
@onready var resources: FighterResources = $Resources
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitboxShape
@onready var sprite: Polygon2D = $Sprite

var _block_time: float = 0.0
var _attack_timer: float = 0.0
var _hit_stun_timer: float = 0.0
var _ai_timer: float = 0.0
var _ai_action_interval: float = 2.0
var _target: Node2D = null

func _ready() -> void:
	hitbox_shape.disabled = true
	fsm.state_changed.connect(_on_state_changed)
	_randomize_interval()

func set_target(target: Node2D) -> void:
	_target = target

func _physics_process(delta: float) -> void:
	if resources.current_health <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_ai(delta)
	_update_attack_phases(delta)
	_update_block_time(delta)
	_update_hit_stun(delta)
	_update_visuals()
	move_and_slide()

# --- IA ---

func _update_ai(delta: float) -> void:
	if fsm.is_attacking() or fsm.current_state == FighterFSM.State.HIT_REACTION:
		return

	_ai_timer += delta

	if _ai_timer >= _ai_action_interval:
		_ai_timer = 0.0
		_randomize_interval()
		_choose_action()

	# Persegue o alvo quando livre
	if _target and fsm.current_state == FighterFSM.State.IDLE_MOVEMENT:
		var distance := _target.global_position.x - global_position.x
		if abs(distance) > 80:
			velocity.x = sign(distance) * SPEED
		else:
			velocity.x = 0

func _choose_action() -> void:
	var roll := randf()
	if roll < 0.6:
		_start_attack()
	elif roll < 0.85:
		_start_block()
	# else: idle

func _randomize_interval() -> void:
	_ai_action_interval = randf_range(1.5, 3.0)

# --- Ações ---

func _start_attack() -> void:
	if not resources.consume_stamina(10.0):
		return
	velocity.x = 0
	_attack_timer = 0.0
	fsm.force_change_state(FighterFSM.State.ATTACK_PREP)

func _start_block() -> void:
	velocity.x = 0
	_block_time = 0.0
	fsm.force_change_state(FighterFSM.State.BLOCKING)
	# Solta o bloqueio automaticamente após um tempo aleatório
	get_tree().create_timer(randf_range(0.5, 1.5)).timeout.connect(
		func():
			if fsm.current_state == FighterFSM.State.BLOCKING:
				fsm.force_change_state(FighterFSM.State.IDLE_MOVEMENT)
	)

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

# --- API Pública ---

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
			sprite.color = Color(0.9, 0.2, 0.2, 1.0)    # Vermelho
		FighterFSM.State.BLOCKING:
			sprite.color = Color(0.5, 0.1, 0.1, 1.0)    # Vermelho escuro
		FighterFSM.State.ATTACK_PREP:
			sprite.color = Color(0.9, 0.7, 0.1, 1.0)    # Amarelo
		FighterFSM.State.ATTACK_ACTIVE:
			sprite.color = Color(1.0, 1.0, 1.0, 1.0)    # Branco
		FighterFSM.State.ATTACK_RECOVERY:
			sprite.color = Color(0.7, 0.5, 0.5, 1.0)    # Cinza rosado
		FighterFSM.State.HIT_REACTION:
			sprite.color = Color(1.0, 0.0, 0.0, 1.0)    # Vermelho forte
