class_name Character extends AnimatedSprite2D


@export var stats: Entity
@onready var player_name: Label = $Name
@onready var health: Label = $Health
@onready var mana: Label = $Mana
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var dissolve_value:float = 0.0
@export var blink_value:float = 0.0
@export var stun_counter: int = 0

var game_state: int = 0

var blink_shader:Shader = preload("res://Material/blink.gdshader")
var dissolve_shader:Shader = preload("res://Material/disolver.tres")
var outline_shader:Shader = preload("res://Material/outline.tres")
var current_shader:Shader

var shader_checks: Array[bool] = [false, false, false]
var is_hovering: bool = false
var is_dead: bool = false
var done_animating:bool = false
var noise : NoiseTexture2D = NoiseTexture2D.new()
var noise_texture: FastNoiseLite = FastNoiseLite.new()

signal entity_done
signal target_picked
signal stun_finished

func align_shader(shader_number: int) -> void:
	if shader_number == 0:
		current_shader = blink_shader
	elif shader_number == 1:
		current_shader = dissolve_shader
		noise.set_noise(noise_texture) 
		self.material.set("shader_parameter/Texture2DParameter", noise)
		if !stats.inTeam:
			self.material.set("shader_parameter/ColorParameter",Color.RED)
		else:
			self.material.set("shader_parameter/ColorParameter",Color.AQUA)
	elif shader_number == 2:
		current_shader = outline_shader
		if !stats.inTeam:
			self.material.set("shader_parameter/ColorParameter",Color.RED)
		else:
			self.material.set("shader_parameter/ColorParameter",Color.AQUA)
	self.material.set_shader(current_shader)

func reset_shader(animation_number: int) -> void:
	for x in range(0,2):
		shader_checks[x] = false
	shader_checks[animation_number] = true
	align_shader(animation_number)
	

func _ready() -> void:
	stats.took_damage.connect(take_damage)
	stats.did_armored.connect(get_armor)
	stats.crit_up.connect(crit_boost)
	stats.stunned.connect(stunned)
	stats.healed.connect(heal)
	stats.damage_changed.connect(damage_boost)
	stats.entity_revive.connect(revive)
	
	stats.max_health = stats.health
	stats.max_mana = stats.mana
	
	player_name.text = stats.entity_name
	reset_shader(1)
	if stats.inTeam:
		self.material.set("shader_parameter/ColorParameter",Color.AQUA)
	else:
		self.material.set("shader_parameter/ColorParameter",Color.RED)
	
func _process(delta: float) -> void:
	if stats.is_armored:
		health.set_modulate(Color.AQUA)
	else:
		health.set_modulate(Color.WHITE)
	
	if stats.is_stunned:
		player_name.set_modulate(Color.YELLOW)
	else:
		player_name.set_modulate(Color.WHITE)
	health.text = "Health: " + str(stats.health)
	mana.text = "Mana : " + str(stats.mana)
	
	if current_shader == dissolve_shader:
		self.material.set("shader_parameter/DissolveValue",dissolve_value)
	elif current_shader == blink_shader:
		self.material.set("shader_parameter/blink_intensity",blink_value)
		
	
	if self.material.get("shader_parameter/DissolveValue") >= 1:
		done_animating = true
	if game_state == 0 and done_animating and !is_dead:
		reset_shader(0)
	
	if stats.health <= 0 and !is_dead:
		if !animation_player.is_playing():
			stats.is_stunned = false
			stats.is_dead = true
			is_dead = true
			reset_shader(1)
			health.visible = false
			mana.visible = false
			player_name.visible = false
			animation_player.play("Die")
			await animation_player.animation_finished
			set_process(false)
			


func _on_area_2d_mouse_entered() -> void:
	if game_state == 2 and !is_dead:
		reset_shader(2)
		is_hovering = true
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		self.material.set("shader_parameter/Width",1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_hovering and !is_dead:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_hovering = false
			get_parent().target_entity = get_parent().get_entity_count(self,stats.inTeam)
			get_parent().current_state = get_parent().GameState.Queue

func _on_area_2d_mouse_exited() -> void:
	if game_state == 2 and !is_dead:
		reset_shader(0)
		self.material.set_shader_parameter("shader_parameter/Width",0)
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		is_hovering = false

func take_damage(did_crit: int):
	reset_shader(0)
	if did_crit == 0:
		self.material.set("shader_parameter/blink_color",Color.WHITE)
	elif did_crit == 1:
		self.material.set("shader_parameter/blink_color",Color.RED)
	else:
		self.material.set("shader_parameter/blink_color",Color.DIM_GRAY)
	animation_player.play("Damaged")
	await animation_player.animation_finished
	emit_signal("entity_done")
	
func get_armor():
	reset_shader(0)
	self.material.set("shader_parameter/blink_color",Color.SKY_BLUE)
	animation_player.play("Defend")
	await animation_player.animation_finished
	emit_signal("entity_done")
	
func heal():
	reset_shader(0)
	self.material.set("shader_parameter/blink_color",Color.GREEN)
	animation_player.play("Heal")
	await animation_player.animation_finished
	emit_signal("entity_done")
	
func crit_boost():
	reset_shader(0)
	self.material.set("shader_parameter/blink_color",Color.DARK_ORANGE)
	animation_player.play("ChangeCrit")
	await animation_player.animation_finished
	emit_signal("entity_done")
	
func damage_boost():
	reset_shader(0)
	self.material.set("shader_parameter/blink_color",Color.CRIMSON)
	animation_player.play("DamageBoost")
	await animation_player.animation_finished
	emit_signal("entity_done")

func stunned():
	self.pause()
	reset_shader(0)
	self.material.set("shader_parameter/blink_color",Color.YELLOW)
	animation_player.play("Stun")
	await animation_player.animation_finished
	emit_signal("entity_done")


func _on_stun_finished() -> void:
	self.play("default")
	stats.is_stunned = false
	reset_shader(0)
	self.material.set("shader_parameter/blink_color",Color.YELLOW)
	animation_player.play("Revert_stun")
	await animation_player.animation_finished
	emit_signal("entity_done")

func revive() -> void:
	done_animating = false
	health.visible = true
	mana.visible = true
	player_name.visible = true
	stats.is_dead = false
	is_dead = false
	reset_shader(1)
	animation_player.play("DisolveAgain")
	await animation_player.animation_finished
