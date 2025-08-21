extends TextureRect

@export var ID = 0
@export var locked = true

@export_multiline var description = ""

func _ready():
	$Sprite2D.frame = ID+2
	if locked:
		$Sprite2D.frame = 1
