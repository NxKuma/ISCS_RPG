extends Node2D

@onready var ui: Control = $UI

var entities: Array[Entity] = []
var current_state: int = GameState.SetUp
var special_button: Button
var r_panel: HSplitContainer
var l_panel: VSplitContainer
var left_buttons: Array[Button]
var right_buttons: Array[Button]


enum GameState{
	SetUp, #Set Up = Player Chooses their moves
	Target, #Target = Player Chooses the target of their moves
	Execute #Execute = Game executes player and enemy movement
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	r_panel = ui.get_child(0).get_child(0).get_child(1).get_child(0)
	l_panel = ui.get_child(0).get_child(0).get_child(0).get_child(0)
#--------------------------------------------------------------
	for child in r_panel.get_children():
		right_buttons.append(child.get_child(0))
	
	for button in right_buttons:
		button.button_down.connect(_on_right_button_press)
		if button.name.contains("2"):
			special_button = button
#--------------------------------------------------------------
	for child in l_panel.get_children():
		left_buttons.append(child.get_child(0))
	
	for button in left_buttons:
		button.button_down.connect(_on_left_button_press)
#--------------------------------------------------------------
	for child in get_children():
		if child.get_script() != null and child.stats != null:
			entities.append(child)

func check_order() -> void:
	pass

func pick_enemy_action() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == GameState.SetUp:
		for entity in entities:
			if r_panel.is_visible():
				special_button.text = entity.skill_list[0].skill_name
	elif current_state == GameState.Target:
		pass
	else:
		pass
		
		
func _on_right_button_press():
	pass
	
func _on_left_button_press():
	pass
