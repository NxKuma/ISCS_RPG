extends Node2D

@onready var ui: Control = $UI

var entities: Array[Sprite2D] = []
var team: Array[Sprite2D] = []
var enemies: Array[Sprite2D] = []
var action_list: Dictionary = {}

var current_state: int = GameState.SetUp
var special_button: Button
var a_panel: HSplitContainer
var s_panel: HSplitContainer
var l_panel: VSplitContainer
var turn_indicator: Label
var current_entity: int = 0
var target_entity: int = 0
var left_buttons: Array[Button] = []
var right_buttons: Array[Button] = []
var current_action: String

enum GameState{
	SetUp, #Set Up = Player Chooses their moves
	Target, #Target = Player Chooses the target of their moves
	Queue #Queue = Game queues player action
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	a_panel = ui.get_child(0).get_child(0).get_child(1).get_child(0)
	s_panel = ui.get_child(0).get_child(0).get_child(1).get_child(1)
	l_panel = ui.get_child(0).get_child(0).get_child(0).get_child(0)
	turn_indicator = ui.get_child(1).get_child(0)
	
	a_panel.set_visible(false)
	s_panel.set_visible(false)
#--------------------------------------------------------------
	for child in a_panel.get_children():
		right_buttons.append(child.get_child(0))
	
	right_buttons[0].button_up.connect(_attack_button_press)
	special_button = right_buttons[1]
	special_button.button_up.connect(_special_button_press)
#--------------------------------------------------------------
	for child in l_panel.get_children():
		left_buttons.append(child.get_child(0))
	
	left_buttons[0].button_down.connect(_action_screen_open)
	left_buttons[1].button_down.connect(_skill_screen_open)
#--------------------------------------------------------------
	for child in get_children():
		if child.get_script() != null and child.stats != null:
			entities.append(child)
#--------------------------------------------------------------
	for e in entities:
		if e.stats.inTeam:
			team.append(e)
		else:
			enemies.append(e)
	print(team.size())

func pick_enemy_action() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == GameState.SetUp and current_entity < team.size():
		current_action = " "
		for b in left_buttons:
			b.set_mouse_filter(0)
		for b in right_buttons:
			b.set_mouse_filter(0)
			b.set_pressed_no_signal(false)

		for e in entities:
			e.game_state = 0
		turn_indicator.text = team[current_entity].stats.entity_name +"'s turn"
		if a_panel.is_visible():
			special_button.text = team[current_entity].stats.skill_list[0].skill_name
	elif current_state == GameState.Target:
		for b in left_buttons:
			b.set_mouse_filter(2)
		for b in right_buttons:
			b.set_mouse_filter(2)
			if b.is_pressed():
				current_action = b.text
		for enemy in enemies:
			enemy.game_state = 2
	elif current_state == GameState.Queue and Engine.get_process_frames() % 5 == 0:
			initialize_action(team[current_entity], current_action, enemies[target_entity])
			print(action_list)
			

#Just for checking for now
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		current_entity += 1
	if current_state == GameState.Target and event.is_action_pressed("ui_cancel"):
		current_state = GameState.SetUp

func get_enemy_count(enemy: Character) -> int:
	return enemies.find(enemy)

func initialize_action(source: Character, action: String, destination: Character):
	var character_stats: Array[Skill] = source.stats.skill_list
	for skill in character_stats:
		if skill.skill_name == action or action == "Attack":
			action_list[source] = [action, destination]
			current_entity += 1
			current_state = GameState.SetUp
		else:
			current_state = GameState.SetUp
			print("Skill not in Character")
			
#------------------------------------------------------------------------------

# Button Presses
func _attack_button_press():
	current_state = GameState.Target

func _special_button_press():
	current_state = GameState.Target
	
func _action_screen_open():
	a_panel.set_visible(!a_panel.is_visible())
	if s_panel.is_visible():
		s_panel.set_visible(false)
	
func _skill_screen_open():
	s_panel.set_visible(!s_panel.is_visible())
	if a_panel.is_visible():
		a_panel.set_visible(false)
