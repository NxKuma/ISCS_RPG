extends CanvasLayer

@onready var win_button: TextureButton = $"Win Panel/HSplitContainer/Panel/Win Button"
@onready var lose_button: TextureButton = $"Lose Panel/HSplitContainer/Panel/Lose Button"
@onready var win_panel: Panel = $"Win Panel"
@onready var lose_panel: Panel = $"Lose Panel"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().win_signal.connect(show_win)
	get_parent().lose_signal.connect(show_lose)
	win_button.button_down.connect(return_to_game)
	lose_button.button_down.connect(return_to_game)
	win_panel.visible = false
	lose_panel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func show_win() -> void:
	win_panel.visible = true
	lose_panel.visible = false
	
func show_lose() -> void:
	win_panel.visible  = false
	lose_panel.visible = true
	
func return_to_game() -> void:
	win_panel.visible = false
	lose_panel.visible = false
		
