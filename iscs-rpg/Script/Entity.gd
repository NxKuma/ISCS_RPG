extends Resource
class_name Entity

@export var name : String
@export var health : int
@export var mana: int
@export var damage: float
@export var skill_list: Array[Skill] = []
@export var element: Element
@export var resistance: Element
@export var weakness: Element
@export var speed: int 


enum Element{
	Fire,
	Water,
	Earth,
	Wind,
	Ligh,
	Dark
}

#Take Physical Damage
func take_damage(damage_dealt:int) -> int:
	health -= damage_dealt
	#Return the damaged health
	return health

#Take Skill Damage
func take_skill_damage(skill_recieved:Skill) -> int:
	var initial_health:int = health
	
	#Check if the Skill Element is aligned with the Element of the Entity
	#Based on this the damage will either weaken or strengthen
	if skill_recieved.skill_element == resistance:
		initial_health -= skill_recieved.skill_damage * 0.75
	elif skill_recieved.skill_element == weakness:
		initial_health -= skill_recieved.skill_damage * 2
	
	#Return the calculated health
	return initial_health
	
