extends ColorRect

signal mouse_in(icon: ColorRect)
signal clicked(icon: ColorRect)

@export var number_overide: String = ""
@export var dark_number_overide: String = ""
@export var value: int = 1
@export var title: String = "Flowers"
@export var darkvalue: int = 1
@export var darktitle: String = "Flowers"
var unlocked = false

@onready var original_position = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color(2,2,2,1)
	$Sprite2D/RichTextLabel.text = str(value)
	if number_overide != "":
		$Sprite2D/RichTextLabel.text = number_overide
	unlocked = true #unlocks EVERY LEVEL ALWAYS ---------------------------------//////////
	if $Sprite2D.frame == 0:
		$Sprite2D.frame = value
	
	if Global.player_save.flags.get("levels_beaten")[value-1]:
		$Sprite2D/TickMark.visible = true


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not unlocked:
					Audio.play_sfx(preload("uid://bigavjv4ovlma")) # bump
					return
				clicked.emit(self)


func _on_mouse_entered() -> void:
	if modulate.a == 1:
		$Sprite2D.modulate = Color(2,2,2,1)
		mouse_in.emit(self)
