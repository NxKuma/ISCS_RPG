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
var crit_chance: float = 50.0
var crit_multiplier: float = 1.5


# ---Return Functions---

#Take Physical Damage
func take_damage(damage_dealt:float) -> float:
	#Calculate Crit Damage
	if randf_range(0,100) <= crit_chance:
		damage_dealt *= crit_multiplier
	health -= damage_dealt
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
	
	#Return the calculated health
	return initial_health

#Add Heal
func heal(health_healed: float) -> float:
	health += health_healed
	return health
# --- Non Return Functions--- Skills

#Stun the Entity
func stun() -> void:
	is_stunned = true
	
func change_speed(speed_change:int):
	speed += speed_change
	

#Revive the Entity
func revive() -> void:
	if !is_dead:
		return
	else:
		health = max_health
		is_dead = false
