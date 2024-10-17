extends Resource
class_name Skill

@export var skill_name: String
@export_multiline var skill_description: String
@export_enum("Attack", "Support") var skill_type: String
@export_enum("Passive", "Active") var skill_mode: String
@export var skill_element: String
@export var skill_damage: float
@export var isPassive: bool

enum Element{
	Fire,
	Water,
	Earth,
	Wind,
	Ligh,
	Dark
}
