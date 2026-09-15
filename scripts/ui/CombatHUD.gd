extends CanvasLayer

## HUD de combate: exibe barras de vida e estamina dos dois lutadores.

@onready var fighter_health: ProgressBar = $FighterHealthBar
@onready var fighter_stamina: ProgressBar = $FighterStaminaBar
@onready var opponent_health: ProgressBar = $OpponentHealthBar
@onready var opponent_stamina: ProgressBar = $OpponentStaminaBar

var _fighter_resources: FighterResources
var _opponent_resources: FighterResources

func setup(f_resources: FighterResources, o_resources: FighterResources) -> void:
	_fighter_resources = f_resources
	_opponent_resources = o_resources

func _process(_delta: float) -> void:
	if not _fighter_resources or not _opponent_resources:
		return

	fighter_health.value = _fighter_resources.current_health
	fighter_stamina.value = _fighter_resources.current_stamina
	opponent_health.value = _opponent_resources.current_health
	opponent_stamina.value = _opponent_resources.current_stamina
