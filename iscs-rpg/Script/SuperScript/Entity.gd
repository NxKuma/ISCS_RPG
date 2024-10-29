extends Resource
class_name Entity

#Editable in the Inspector
@export var entity_name : String
@export var health : float
@export var mana: int
@export var damage: float
@export var inTeam: bool
@export var skill_list: Array[Skill] = []
@export var element: Element
@export var resistance: Array[Element] = []
@export var weakness: Array[Element] = []
@export var speed: int 

#signals
signal took_damage(did_crit:int)
signal healed
signal speed_changed
signal crit_up
signal stunned
signal did_armored
signal mana_used
signal damage_changed
signal entity_revive

#Hidden in the Inspector
enum Element{
	Fire,
	Water,
	Earth,
	Wind,
	Light,
	Dark
}

var max_health: float
var max_mana: int 
var is_stunned:bool = false
var is_dead: bool = false
var is_armored: bool = false
var armor: int = 0
var crit_chance: float = 30.0
var crit_multiplier: float = 1.5


# ---Return Functions---


#Take Physical Damage
func take_damage(damage_dealt:float) -> float:
	#Calculate Crit Damage
	if randf_range(1,100) <= crit_chance:
		damage_dealt *= crit_multiplier
		health -= damage_dealt
		emit_signal("took_damage", 1)
	else:
		emit_signal("took_damage", 0)
		if armor > 0:
			armor -= damage_dealt
		else:
			is_armored = false
			health -= damage_dealt
		if health <= 0:
			health = 0
	#Return the damaged health
	return health

#Take Skill Damage
func take_skill_damage(skill_recieved:Skill) -> float:
	var initial_health:float = health
	var damage_dealt: float = skill_recieved.skill_damage
	#Check if the Skill Element is aligned with the Element of the Entity
	#Based on this the damage will either weaken or strengthen
	if armor > 0:
		armor -= damage_dealt
		emit_signal("took_damage", 0)
	else:
		is_armored = false
		if skill_recieved.skill_element in resistance:
			initial_health -= damage_dealt * 0.5
			emit_signal("took_damage", 2)
		elif skill_recieved.skill_element in weakness:
			initial_health -= damage_dealt * 2
			emit_signal("took_damage", 1)
		else:
			initial_health -= damage_dealt
			emit_signal("took_damage", 0)
	
	if initial_health <= 0:
		initial_health = 0
	
	#Return the calculated health
	return initial_health

#Add Heal
func heal(health_healed: float) -> float:
	health += health_healed
	emit_signal("healed")
	return health
	

# --- Non Return Functions--- Skills

#Stun the Entity
func stun() -> void:
	is_stunned = true
	emit_signal("stunned")
	
func change_speed(speed_change:int) -> void:
	speed += speed_change
	emit_signal("speed_changed")
	
func damage_boost(amount: int) -> void:
	damage *= amount
	emit_signal("damage_changed")
	
	
func change_crit(crit_change:int):
	crit_chance += crit_change  
	emit_signal("crit_up")

func armored(armor_value: float) -> void:
	is_armored = true
	armor = armor_value
	emit_signal("did_armored")

#Revive the Entity
func revive() -> void:
	health = max_health
	mana = max_mana
	is_stunned = false
	is_armored = false
	crit_chance = 30.0
	is_dead = false
	emit_signal("entity_revive")
