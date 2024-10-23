extends Sprite2D
class_name Character

@export var stats: Entity
@onready var player_name: Label = $Name
@onready var health: Label = $Health
@onready var mana: Label = $Mana

var game_state: int = 0

var blink_shader:Shader = preload("res://Material/blink.gdshader")
var dissolve_shader:Shader = preload("res://Material/disolver.tres")
var outline_shader:Shader = preload("res://Material/outline.tres")
var current_shader:Shader

var shader_checks: Array[bool] = [false, false, false]
var is_hovering: bool = false


func align_shader(shader_number: int) -> void:
	if shader_number == 0:
		current_shader = blink_shader
	elif shader_number == 1:
		current_shader = dissolve_shader
	elif shader_number == 2:
		current_shader = outline_shader
	self.material.set_shader(current_shader)

func reset_shader(animation_number: int) -> void:
	for x in range(0,2):
		shader_checks[x] = false
	shader_checks[animation_number] = true
	align_shader(animation_number)
	

func _ready() -> void:
	player_name.text = stats.entity_name
	reset_shader(0)
	
func _process(delta: float) -> void:
	health.text = "Health: " + str(stats.health)
	mana.text = "Mana : " + str(stats.mana)
	
	if !stats.inTeam and game_state == 0:
		reset_shader(0)


func _on_area_2d_mouse_entered() -> void:
	if game_state == 2:
		reset_shader(2)
		self.material.set_shader_parameter("shader_parameter/Width",3)
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		is_hovering = true
		
		#var mouse_input : InputEvent = InputEventMouseButton
		#if mouse_input is InputEventMouseButton:
			#get_parent().current_state = get_parent().GameState.Queue

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_hovering:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().target_entity = get_parent().get_enemy_count(self)
			get_parent().current_state = get_parent().GameState.Queue


func _on_area_2d_mouse_exited() -> void:
	if game_state == 2:
		reset_shader(0)
		self.material.set_shader_parameter("shader_parameter/Width",0)
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		is_hovering = false
