extends Resource
class_name Entity

#Editable in the Inspector
@export var name : String
@export var health : float
@export var mana: int
@export var damage: float
@export var skill_list: Array[Skill] = []
@export var element: Element
@export var resistance: Element
@export var weakness: Element
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
var crit_chance: float = 0.5
var crit_multiplier: float = 1.5


# ---Return Functions---

#Take Physical Damage
func take_damage(damage_dealt:float) -> float:
	health -= damage_dealt
	#Return the damaged health
	return health

#Take Skill Damage
func take_skill_damage(skill_recieved:Skill) -> float:
	var initial_health:float = health
	
	#Check if the Skill Element is aligned with the Element of the Entity
	#Based on this the damage will either weaken or strengthen
	if skill_recieved.skill_element == resistance:
		initial_health -= skill_recieved.skill_damage * 0.75
	elif skill_recieved.skill_element == weakness:
		initial_health -= skill_recieved.skill_damage * 2
	
	#Return the calculated health
	return initial_health


# --- Non Return Functions---

#Stun the Entity
func stun():
	is_stunned = true

#Revive the Entity
func revive():
	if !is_dead:
		return
	else:
		health = max_health
		is_dead = false
