extends ColorRect

@export var value: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = value-1
	$Sprite2D/RichTextLabel.text = str(value)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Global.goto_level(value)
