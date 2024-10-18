extends Node2D

var entities: Array[Entity] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child.get_script() != null:
			print(child.get_script())
			entities.append(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
