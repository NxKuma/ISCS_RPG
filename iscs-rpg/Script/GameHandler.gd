extends Node2D

@onready var ui: Control = $UI
@onready var label: Label = $Label

const cursor_open = preload("res://Art/harold_open_cursor_big.png")
const cursor_point = preload("res://Art/harold_point_cursor_big.png")
const dsmite_card = preload("res://Art/harold_divine_smite.png")
const daid_card = preload("res://Art/harold_divine_aid.png")
const sarmor_card = preload("res://Art/harolita_shell_armor.png")
const rtide_card = preload("res://Art/harolita_rising_tide.png")

var cards: Array = [dsmite_card, daid_card, sarmor_card, rtide_card]
var entities: Array[AnimatedSprite2D] = []
var team: Array[AnimatedSprite2D] = []
var enemies: Array[AnimatedSprite2D] = []
var card_skills: Array[Sprite2D] = []
var action_list: Dictionary = {}
var echo: Label

var current_state: int = GameState.SetUp
var special_button: TextureButton
var skill1_button: TextureButton
var skill2_button: TextureButton
var a_panel: HSplitContainer
var s_panel: HSplitContainer
var l_panel: VSplitContainer
var turn_indicator: Label
var current_entity: int = 0
var target_entity: int = 0
var left_buttons: Array[TextureButton] = []
var right_buttons: Array[TextureButton] = []
var skill_buttons: Array[TextureButton] = []
var action_buttons: Array[TextureButton] = []
var current_action: String
var has_queued: bool = false
var is_done_executing: bool = false
var is_attack: bool = false
var die_count: int = 0

signal has_completed_executing
signal action_initialized
signal win_signal
signal lose_signal
# gamehandler.signal.connect(function)
# emit_signal("skill_button_pressed", 123)

enum GameState{
	SetUp, #Set Up = Player Chooses their moves
	Target, #Target = Player Chooses the target of their moves
	Queue, #Queue = Game queues player action
	Execute
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	a_panel = ui.get_child(0).get_child(0).get_child(1).get_child(0)
	s_panel = ui.get_child(0).get_child(0).get_child(1).get_child(1)
	l_panel = ui.get_child(0).get_child(0).get_child(0).get_child(0)
	echo = ui.get_child(0).get_child(0).get_child(1).get_child(2)
	turn_indicator = ui.get_child(1).get_child(0)
	
	Input.set_custom_mouse_cursor(cursor_open, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(cursor_point, Input.CURSOR_POINTING_HAND)

	
	a_panel.set_visible(false)
	s_panel.set_visible(false)
	#--------------------------------------------------------------
	for child in a_panel.get_children():
		right_buttons.append(child.get_child(0))
		action_buttons.append(child.get_child(0))
	special_button = right_buttons[1]
	for child in s_panel.get_children():
		right_buttons.append(child.get_child(0).get_child(1).get_child(0))
		skill_buttons.append(child.get_child(0).get_child(1).get_child(0))
	skill1_button = right_buttons[2]
	skill2_button = right_buttons[3]
	for rb in right_buttons:
		rb.button_up.connect(_attack_button_press)
	#--------------------------------------------------------------
	card_skills.append(s_panel.get_child(0).get_child(0).get_child(0).get_child(0))
	card_skills.append(s_panel.get_child(1).get_child(0).get_child(0).get_child(0))
	#--------------------------------------------------------------
	for child in l_panel.get_children():
		left_buttons.append(child.get_child(0))

	left_buttons[0].button_down.connect(_action_screen_open)
	left_buttons[1].button_down.connect(_skill_screen_open)
	#--------------------------------------------------------------
	for child in get_children():
		if child.get_script() != null and child is AnimatedSprite2D:
			entities.append(child)
#--------------------------------------------------------------
	get_available_entity()

func get_available_entity() -> void:
	team.clear()
	enemies.clear()
	for e in entities:
		if !e.is_dead and (e.stats.health > 0) and (!e.stats.is_stunned):
			if e.stats.inTeam:
				team.append(e)
			else:
				enemies.append(e)

func pick_enemy_action() -> void:
	for e in range(enemies.size()):
		var enemy:Character = enemies[e]
		var enemy_action_number: int  = randi_range(0, enemy.stats.skill_list.size())
		var enemy_action_string: String
		var target_array: Array[AnimatedSprite2D]
		if enemy_action_number == enemy.stats.skill_list.size():
			enemy_action_string = "Attack"
			target_array = team
		else:
			enemy_action_string = enemy.stats.skill_list[enemy_action_number].skill_name
			if enemy.stats.skill_list[enemy_action_number].skill_type == "Support":
				target_array = enemies
			else:
				target_array = team
		has_queued = false
		initialize_action(enemies[e],enemy_action_string, target_array[randi_range(0,target_array.size() - 1)])

func fastest_to_slowest(a, b):
	if a.stats.speed > b.stats.speed:
		return true
	return false

func arrange_by_speed(array_list: Array) -> Array[Character]:
	var entity_list: Array[Character] = []
	for e in array_list:
		entity_list.append(e)
	entity_list.sort_custom(fastest_to_slowest)
	return entity_list

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
		
	if current_state == GameState.SetUp and current_entity < team.size():
		if team[current_entity].stats.is_stunned:
			current_entity += 1
		l_panel.set_visible(true)
		is_attack = false
		has_queued = false
		is_done_executing = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
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
			special_button.get_child(0).text = team[current_entity].stats.skill_list[0].skill_name
		if s_panel.is_visible():
			skill1_button.get_child(0).text = team[current_entity].stats.skill_list[1].skill_name
			skill2_button.get_child(0).text = team[current_entity].stats.skill_list[2].skill_name
			card_skills[0].set_texture(team[current_entity].stats.skill_list[1].card_img)
			card_skills[1].set_texture(team[current_entity].stats.skill_list[2].card_img) 
#------------------------------------------------------------------------------
	elif current_state == GameState.Target:
		for b in left_buttons:
			b.set_mouse_filter(2)
		for b in right_buttons:
			b.set_mouse_filter(2)
			if b.is_pressed() and b.visible == true:
				if b in action_buttons:
					for a in action_buttons:
						if b == a:
							current_action = b.get_child(0).text
				elif b in skill_buttons:
					for s in skill_buttons:
						if b == s:
							current_action = b.get_child(0).text
		for skill in team[current_entity].stats.skill_list:
			if skill.skill_name == current_action:
				if skill.skill_type == "Attack":
					is_attack = true
					for enemy in enemies:
						enemy.game_state = 2
				elif skill.skill_type == "Support":
					is_attack = false
					for mate in team:
						mate.game_state = 2
			elif current_action == "Attack":
				is_attack = true
				for enemy in enemies:
					enemy.game_state = 2
#------------------------------------------------------------------------------
	elif current_state == GameState.Queue and has_queued == false:
		var target : Character
		if is_attack:
			target = enemies[target_entity]
		else:
			target = team[target_entity]
		initialize_action(team[current_entity], current_action, target)
		#await action_initialized
#------------------------------------------------------------------------------
	elif current_state == GameState.Execute:
		if has_queued:
			pick_enemy_action()
			has_queued = false
		var sorted_list = arrange_by_speed(entities)
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		for b in left_buttons:
			b.set_mouse_filter(0)
		for b in right_buttons:
			b.set_mouse_filter(0)
			b.set_pressed_no_signal(false)
		for e in entities:
			e.game_state = 0
		s_panel.set_visible(false)
		a_panel.set_visible(false)
		l_panel.set_visible(false)
		turn_indicator.text = " "
		#-------------------------------
		if !is_done_executing:
			execute_action(sorted_list)
			is_done_executing = true
		#-------------------------------
		await _on_has_completed_executing
#------------------------------------------------------------------------------
#Just for checking for now
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		current_entity += 1
	if current_state == GameState.Target and event.is_action_pressed("ui_cancel"):
		current_state = GameState.SetUp
#------------------------------------------------------------------------------
func get_entity_count(entity: Character, is_in_team: bool) -> int:
	var count: int = 0
	if is_in_team:
		count = team.find(entity)
	else:
		count = enemies.find(entity)
	return count
#------------------------------------------------------------------------------
func initialize_action(source: Character, action: String, destination: Character):
	if !has_queued:
		var character_stats: Array[Skill] = source.stats.skill_list
		var target_array: Array[AnimatedSprite2D] = []
		if source.name.contains("Player"):
			target_array = team
		else:
			target_array = enemies
		has_queued = true
		for skill in character_stats:
			if skill.skill_name == action or action == "Attack":
				action_list[source] = [action, destination]
				if current_entity < target_array.size()-1:
					current_entity += 1
					a_panel.set_visible(false)
					s_panel.set_visible(false)
					current_state = GameState.SetUp
					return
				else:
					current_state = GameState.Execute
			#else:
				#current_state = GameState.SetUp
	#label.text += source.stats.entity_name + " used " +  action + " on " + destination.stats.entity_name + "\n"
#------------------------------------------------------------------------------
func execute_action(list:Array[Character]) -> void:
	for l in list:
		if l in action_list:
			var stats: Entity = l.stats
			var skill: Skill
			var target: Character = action_list[l][1]
			var action: String = action_list[l][0]
			var enough_mana: bool
			#print("{} (Who is dead?{}) is attacking {} (Who is dead?{})".format([l.stats.entity_name,l.is_dead,target.stats.entity_name,target.is_dead], "{}"))
			if action != "Attack":
				for s in stats.skill_list:
					if s.skill_name == action:
						skill = s
				enough_mana = skill.skill_cost > stats.mana
			if (!target.is_dead and !l.is_dead) and !l.stats.is_stunned:
				echo.visible = true
				echo.text = l.stats.entity_name + " used " +  action + " on " + target.stats.entity_name
				if action == "Attack":
					target.stats.health = target.stats.take_damage(stats.damage)
				else:
					if enough_mana:
						echo.text = "Not Enough Mana"
						await get_tree().create_timer(1).timeout
					else:
						
						if skill.skill_type == "Attack":
							if skill.skill_name.contains("Smite"):
								for e in enemies:
									e.stats.health = e.stats.take_skill_damage(skill)
							elif skill.skill_name.contains("Stun"):
								target.stats.stun()
							elif skill.skill_name.contains("Kill"):
								for e in team:
									e.stats.health = e.stats.take_skill_damage(skill)
							else:
								target.stats.health = target.stats.take_skill_damage(skill)
						
						elif skill.skill_type == "Support":
							if skill.skill_name.contains("Heal"):
								target.stats.heal(skill.skill_damage)
							elif skill.skill_name.contains("Aid"):
								target.stats.change_crit(skill.skill_damage)
							elif skill.skill_name.contains("Armor"):
								target.stats.armored(skill.skill_damage)
							elif skill.skill_name.contains("Rising"):
								target.stats.armored(skill.skill_damage)
						if skill.skill_mode == "Active":
							if l.stats.mana <= 0:
								l.stats.mana = 0
							else:
								l.stats.mana -= skill.skill_cost
				if !enough_mana:
					await target.entity_done
	#print("-------------------------------")
	emit_signal("has_completed_executing")

func queue_action() -> void:
	var target : Character
	if is_attack:
		target = enemies[target_entity]
	else:
		target = team[target_entity]
	initialize_action(team[current_entity], current_action, target)

#------------------------------------------------------------------------------
# Button Presses
func _attack_button_press():
	current_state = GameState.Target
	
func _action_screen_open():
	a_panel.set_visible(!a_panel.is_visible())
	if s_panel.is_visible():
		s_panel.set_visible(false)
	
func _skill_screen_open():
	s_panel.set_visible(!s_panel.is_visible())
	if a_panel.is_visible():
		a_panel.set_visible(false)


func _on_has_completed_executing() -> void:
	for t in entities:
		if t.stats.mana < t.stats.max_mana:
			t.stats.mana += 10
		else:
			t.stats.mana = t.stats.max_mana
		
		if t.stats.is_stunned:
			if t.stun_counter > 0:
				t.stun_counter -= 1
			else:
				t.emit_signal("stun_finished")
	current_entity = 0
	echo.visible = false
	print(entities[0].stats.health == 0 and entities[1].stats.health == 0)
	if team.size() <= 0 and (entities[0].stats.health == 0 and entities[1].stats.health == 0) :
		emit_signal("lose_signal")
		set_process(false)
		return
	elif enemies.size() <= 0:
		emit_signal("win_signal")
		set_process(false)
		return
	get_available_entity()
	if team.size() == 0:
		print("hello")
		has_queued = true
		current_state = GameState.Execute
	else:
		current_state = GameState.SetUp
