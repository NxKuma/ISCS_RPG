extends Resource
class_name Skill

#Editable in the Inspector
@export var skill_name: String
@export_multiline var skill_description: String
@export_enum("Attack", "Support") var skill_type: String
@export_enum("Passive", "Active") var skill_mode: String
@export var skill_element: Element
@export var skill_damage: float

#Hidden in the Inspector
enum Element{
	Fire,
	Water,
	Earth,
	Wind,
	Light,
	Dark
}
