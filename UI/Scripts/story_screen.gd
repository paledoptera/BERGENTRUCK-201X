extends Node

var loaded = false

func _ready() -> void:
	$Sprite2D.frame = Global.level-1



func _on_play_gui_input(event: InputEvent) -> void:
	if not loaded:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Global.goto_level()


func _on_display_timer_timeout() -> void:
	$Sprite2D.visible = true
	Audio.play_sfx(preload("uid://bwrewdkj3pqlf"),1.01)

func _on_load_timer_timeout() -> void:
	loaded = true
