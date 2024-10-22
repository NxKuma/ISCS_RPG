extends Sprite2D
class_name Character

@export var stats: Entity
@onready var player_name: Label = $Name
@onready var health: Label = $Health
@onready var mana: Label = $Mana

var blink_shader:Shader = preload("res://Material/blink.gdshader")
var dissolve_shader:Shader = preload("res://Material/disolver.tres")
var outline_shader:Shader = preload("res://Material/outline.tres")
var current_shader:Shader

var material_checks: Array[bool] = [true, false, false]

func align_material() -> void:
	if material_checks[0]:
		current_shader = blink_shader
	elif material_checks[1]:
		current_shader = dissolve_shader
	elif material_checks[2]:
		current_shader = outline_shader

func reset_material(animation_number: int) -> void:
	for check in material_checks:
		check = false
	material_checks[animation_number] = true
	align_material()
	

func _ready() -> void:
	player_name.text = stats.entity_name
	#if material.resource_name == "Blink":
	
func _process(delta: float) -> void:
	health.text = "Health: " + str(stats.health)
	mana.text = "Mana : " + str(stats.mana)


func _on_area_2d_mouse_entered() -> void:
	reset_material(3)
	


func _on_area_2d_mouse_exited() -> void:
	pass # Replace with function body.
