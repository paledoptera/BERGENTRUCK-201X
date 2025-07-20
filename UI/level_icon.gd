extends ColorRect

@export var value: int = 1
var unlocked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D/RichTextLabel.text = str(value)
	
	if Global.player_save.levels_unlocked[value-1]:
		unlocked = true
		$Sprite2D.frame = value-1
	else:
		$Sprite2D.frame = 3


func _on_gui_input(event: InputEvent) -> void:
	if not unlocked:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Global.level = value
				Global.goto_storyscreen()
