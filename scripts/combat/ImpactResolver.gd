class_name ImpactResolver
extends Node

# Emitido quando um parry é executado com sucesso
signal parry_success
# Emitido quando um golpe conecta (com sucesso ou defendido)
signal hit_connected

# Janela de tempo (em segundos) no início de um bloqueio onde o parry é válido
const PARRY_WINDOW: float = 0.12

# Calcula e resolve um ataque recebido
# atk_damage: Dano base do ataque
# defender_fsm: Referência à FSM do defensor (para checar se está bloqueando)
# defender_resources: Referência aos recursos do defensor (vida/estamina)
# block_time_elapsed: Quanto tempo (em segundos) o defensor está segurando a defesa
func resolve_impact(atk_damage: float, defender_fsm: FighterFSM, defender_resources: FighterResources, block_time_elapsed: float) -> void:
	
	emit_signal("hit_connected")

	# Checa se o defensor está no estado de bloqueio
	if defender_fsm.current_state == FighterFSM.State.BLOCKING:
		# Checa se o bloqueio foi acionado recentemente (Janela de Parry)
		if block_time_elapsed <= PARRY_WINDOW:
			_resolve_parry(defender_resources)
		else:
			_resolve_block(atk_damage, defender_resources)
	else:
		_resolve_normal_hit(atk_damage, defender_resources, defender_fsm)

func _resolve_parry(defender_resources: FighterResources) -> void:
	# O parry anula totalmente o dano e a quebra de postura, sem custar estamina.
	emit_signal("parry_success")
	# Pode adicionar hitstop/efeitos visuais no futuro
	# Opcional: recuperar um pouco de estamina ao defender com precisão
	defender_resources.reset_recovery_delay() 

func _resolve_block(atk_damage: float, defender_resources: FighterResources) -> void:
	# Passa a responsabilidade do consumo de estamina e dano chip para a classe Resources
	defender_resources.take_block_damage(atk_damage)

func _resolve_normal_hit(atk_damage: float, defender_resources: FighterResources, defender_fsm: FighterFSM) -> void:
	# Recebe o dano integral
	defender_resources.take_raw_damage(atk_damage)
	
	# Força o estado de hit reaction (stun)
	defender_fsm.change_state(FighterFSM.State.HIT_REACTION)
