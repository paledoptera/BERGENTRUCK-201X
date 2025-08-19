extends ColorRect

signal mouse_in(icon: ColorRect)

@export var value: int = 1
@export var title: String = "Flowers"
var unlocked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D/RichTextLabel.text = str(value)
	
	unlocked = true
	if $Sprite2D.frame == 0:
		$Sprite2D.frame = value-1
	
	if Global.player_save.flags.get("levels_beaten")[value-1]:
		$Sprite2D/TickMark.visible = true


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not unlocked:
					Audio.play_sfx(preload("uid://bigavjv4ovlma")) # bump
					return
				Audio.play_sfx(preload("uid://cf8yyq2r0tegw"),1.01) # vroom
				Global.level = value
				
				if Global.player_save.flags["option_skip_tutorials"]:
					Global.goto_level()
				else:
					Global.goto_storyscreen()


func _on_mouse_entered() -> void:
	mouse_in.emit(self)
