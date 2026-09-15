class_name FighterResources
extends Node

# Emitido quando a vida chega a zero
signal health_depleted
# Emitido quando a defesa falha por falta de estamina
signal guard_broken

const MAX_HEALTH: float = 100.0
const MAX_STAMINA: float = 100.0

var current_health: float = MAX_HEALTH
var current_stamina: float = MAX_STAMINA

# A estamina recupera 18 pontos por segundo
const STAMINA_RECOVERY_RATE: float = 18.0
# Tempo de espera após uma ação (ataque ou hit) antes de recuperar
const STAMINA_RECOVERY_DELAY: float = 0.8

# Custo fixo para defender um golpe comum
const BLOCK_STAMINA_COST: float = 8.0
# Porcentagem de dano que passa pelo bloqueio
const CHIP_DAMAGE_MODIFIER: float = 0.25

var _idle_timer: float = 0.0
var _can_recover_stamina: bool = false

func _process(delta: float) -> void:
	if current_health <= 0:
		return
		
	# Gerencia o timer de recuperação
	if not _can_recover_stamina:
		_idle_timer += delta
		if _idle_timer >= STAMINA_RECOVERY_DELAY:
			_can_recover_stamina = true
	else:
		# Recupera a estamina ao longo do tempo
		if current_stamina < MAX_STAMINA:
			current_stamina += STAMINA_RECOVERY_RATE * delta
			if current_stamina > MAX_STAMINA:
				current_stamina = MAX_STAMINA

# Reinicia o delay de recuperação. Deve ser chamado sempre que atacar ou sofrer impacto.
func reset_recovery_delay() -> void:
	_idle_timer = 0.0
	_can_recover_stamina = false

# Aplica consumo direto de estamina (ex: ao desferir um golpe)
func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		reset_recovery_delay()
		return true
	return false

# Lógica de bloqueio: Consome estamina e aplica dano residual (chip damage)
func take_block_damage(damage: float) -> void:
	reset_recovery_delay()
	
	if current_stamina >= BLOCK_STAMINA_COST:
		current_stamina -= BLOCK_STAMINA_COST
		var chip_damage = damage * CHIP_DAMAGE_MODIFIER
		take_raw_damage(chip_damage)
	else:
		# Falha na guarda por falta de estamina (Guard Break)
		current_stamina = 0.0
		emit_signal("guard_broken")
		take_raw_damage(damage)

# Aplica dano integral
func take_raw_damage(damage: float) -> void:
	reset_recovery_delay()
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		emit_signal("health_depleted")
