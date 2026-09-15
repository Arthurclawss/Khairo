class_name FighterFSM
extends Node

enum State {
	IDLE_MOVEMENT,   # Movimento Livre
	BLOCKING,        # Bloqueio
	ATTACK_PREP,     # Preparação (antecipação)
	ATTACK_ACTIVE,   # Fase Ativa (resolução da colisão/hitbox)
	ATTACK_RECOVERY, # Recuperação (vulnerabilidade após o golpe)
	HIT_REACTION     # Reação a Dano
}

var current_state: State = State.IDLE_MOVEMENT

func _ready() -> void:
	pass

func change_state(new_state: State) -> void:
	# Lógica para garantir o compromisso dos golpes (não podem ser cancelados livremente)
	if is_attacking() and new_state != State.HIT_REACTION:
		# Só permite sair do estado de ataque se a animação/estado atual terminar
		return
		
	_exit_state(current_state)
	current_state = new_state
	_enter_state(current_state)

func is_attacking() -> bool:
	return current_state in [State.ATTACK_PREP, State.ATTACK_ACTIVE, State.ATTACK_RECOVERY]

func _enter_state(state: State) -> void:
	match state:
		State.IDLE_MOVEMENT:
			pass # Lógica de iniciar movimento
		State.BLOCKING:
			pass # Ativa guarda
		State.ATTACK_PREP:
			pass # Inicia frame de antecipação
		State.ATTACK_ACTIVE:
			pass # Ativa hitbox
		State.ATTACK_RECOVERY:
			pass # Inicia frames de vulnerabilidade
		State.HIT_REACTION:
			pass # Aplica stun / hitstop

func _exit_state(state: State) -> void:
	match state:
		State.ATTACK_ACTIVE:
			pass # Desativa hitbox
		State.BLOCKING:
			pass # Desativa guarda
