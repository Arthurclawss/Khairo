class_name FighterFSM
extends Node

## Máquina de estados finitos para o lutador.
## Gerencia transições entre estados e garante o compromisso dos golpes.

signal state_changed(old_state: State, new_state: State)

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

## Transição pública com regra de compromisso:
## Durante um ataque, só permite transição para HIT_REACTION (interrupção por dano).
func change_state(new_state: State) -> void:
	if is_attacking() and new_state != State.HIT_REACTION:
		return
	_execute_change(new_state)

## Transição forçada (sem verificação de compromisso).
## Usada internamente pelo controller para avançar fases do ataque
## (PREP → ACTIVE → RECOVERY → IDLE) e para transições controladas.
func force_change_state(new_state: State) -> void:
	_execute_change(new_state)

func is_attacking() -> bool:
	return current_state in [State.ATTACK_PREP, State.ATTACK_ACTIVE, State.ATTACK_RECOVERY]

func _execute_change(new_state: State) -> void:
	var old_state := current_state
	_exit_state(current_state)
	current_state = new_state
	_enter_state(current_state)
	state_changed.emit(old_state, new_state)

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

