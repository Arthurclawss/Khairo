extends Node2D

## Orquestrador da cena de combate.
## Conecta sinais de hitbox, resolve impactos e detecta fim de luta.

@onready var fighter = $Fighter
@onready var opponent = $Opponent
@onready var impact_resolver: ImpactResolver = $ImpactResolver
@onready var hud = $UI

var _fight_over: bool = false

func _ready() -> void:
	# Configura o alvo da IA
	opponent.set_target(fighter)

	# Conecta sinais de hitbox (colisão física)
	$Fighter/Hitbox.area_entered.connect(_on_fighter_hit_opponent)
	$Opponent/Hitbox.area_entered.connect(_on_opponent_hit_fighter)

	# Conecta sinais de derrota
	$Fighter/Resources.health_depleted.connect(_on_fighter_defeated)
	$Opponent/Resources.health_depleted.connect(_on_opponent_defeated)

	# Conecta sinais de guard break
	$Fighter/Resources.guard_broken.connect(func(): _on_guard_broken(fighter))
	$Opponent/Resources.guard_broken.connect(func(): _on_guard_broken(opponent))

	# Configura o HUD com as referências de recursos
	hud.setup($Fighter/Resources, $Opponent/Resources)

# --- Resolução de Impacto ---

func _on_fighter_hit_opponent(_area: Area2D) -> void:
	if _fight_over:
		return
	var atk_damage := fighter.get_attack_damage()
	var defender_fsm := $Opponent/FSM as FighterFSM
	var defender_resources := $Opponent/Resources as FighterResources
	var block_time := opponent.get_block_time()
	impact_resolver.resolve_impact(atk_damage, defender_fsm, defender_resources, block_time)
	fighter.deactivate_hitbox()
	print("[COMBAT] Fighter → Opponent | Dano: ", atk_damage)

func _on_opponent_hit_fighter(_area: Area2D) -> void:
	if _fight_over:
		return
	var atk_damage := opponent.get_attack_damage()
	var defender_fsm := $Fighter/FSM as FighterFSM
	var defender_resources := $Fighter/Resources as FighterResources
	var block_time := fighter.get_block_time()
	impact_resolver.resolve_impact(atk_damage, defender_fsm, defender_resources, block_time)
	opponent.deactivate_hitbox()
	print("[COMBAT] Opponent → Fighter | Dano: ", atk_damage)

# --- Eventos de Combate ---

func _on_guard_broken(target) -> void:
	print("[COMBAT] GUARD BREAK em ", target.name, "!")
	target.get_node("FSM").force_change_state(FighterFSM.State.HIT_REACTION)

func _on_fighter_defeated() -> void:
	_fight_over = true
	print("[COMBAT] ===== OPPONENT WINS! =====")

func _on_opponent_defeated() -> void:
	_fight_over = true
	print("[COMBAT] ===== FIGHTER WINS! =====")
