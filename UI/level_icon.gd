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
	update_visual(false)

func update_visual(dark:bool):
	var usedvalue = value
	if dark: #choose value
		usedvalue = darkvalue
		$Sprite2D/RichTextLabel.text = dark_number_overide
	else:
		$Sprite2D/RichTextLabel.text = str(value)
		if number_overide != "":
			$Sprite2D/RichTextLabel.text = number_overide
	$Sprite2D.frame = usedvalue #update level icon
	$Sprite2D/TickMark.visible = Global.player_save.flags.get("levels_beaten")[usedvalue-1] #update checkmark
	
	#LOCK THE LEVEL VV
	if Global.player_save.flags.get("levels_unlocked")[usedvalue-1] or OS.has_feature("editor"): #is the level locked?? IN EDITOR EVERYTHING IS UNLOCKED
		unlocked = true
		$Sprite2D/RichTextLabel.show()
	else:
		unlocked = false
		$Sprite2D/RichTextLabel.hide()
		$Sprite2D/TickMark.hide()
		$Sprite2D.frame = 0
		return


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not unlocked:
					Audio.play_sfx(preload("uid://bigavjv4ovlma")) # bump
					return
				clicked.emit(self)


func _on_mouse_entered() -> void:
	mouse_in.emit(self)
