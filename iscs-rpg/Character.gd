extends Sprite2D
class_name Character

@export var stats: Entity
@onready var player_name: Label = $Name
@onready var health: Label = $Health
@onready var mana: Label = $Mana

func _ready() -> void:
	player_name.text = stats.entity_name
	
func _process(delta: float) -> void:
	health.text = "Health: " + str(stats.health)
	mana.text = "Mana : " + str(stats.mana)
