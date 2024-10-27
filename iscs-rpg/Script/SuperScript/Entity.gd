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
signal took_damage
signal healed
signal speed_changed
signal stunned
signal did_armored
signal mana_used

#Hidden in the Inspector
enum Element{
	Fire,
	Water,
	Earth,
	Wind,
	Light,
	Dark
}

var max_health: float = health
var is_stunned:bool = false
var is_dead: bool = false
var armor: int = 0
var crit_chance: float = 50.0
var crit_multiplier: float = 1.5


# ---Return Functions---

#Take Physical Damage
func take_damage(damage_dealt:float) -> float:
	#Calculate Crit Damage
	if randf_range(0,100) <= crit_chance:
		damage_dealt *= crit_multiplier
	if armor >= 0:
		armor -= damage_dealt
	else:
		health -= damage_dealt
	if health <= 0:
		health = 0
	emit_signal("took_damage")
	#Return the damaged health
	return health

#Take Skill Damage
func take_skill_damage(skill_recieved:Skill) -> float:
	var initial_health:float = health
	
	#Check if the Skill Element is aligned with the Element of the Entity
	#Based on this the damage will either weaken or strengthen
	if skill_recieved.skill_element in resistance:
		initial_health -= skill_recieved.skill_damage * 0.5
	elif skill_recieved.skill_element in weakness:
		initial_health -= skill_recieved.skill_damage * 2
	else:
		initial_health -= skill_recieved.skill_damage
	if mana < skill_recieved.skill_cost:
		emit_signal("mana_used")
		return initial_health
	
	if initial_health <= 0:
		initial_health = 0
	emit_signal("took_damage")
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

func armored(armor_value: float) -> void:
	armor = armor_value
	emit_signal("did_armored")

#Revive the Entity
func revive() -> void:
	if !is_dead:
		return
	else:
		health = max_health
		is_dead = false
