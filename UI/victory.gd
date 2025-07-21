extends Node

func _ready() -> void:
	Global.player_save.flags["levels_beaten"][Global.level-1] = true
	Global.player_save.flags["levels_unlocked"][min(Global.level,2)] = true
	SaveLoad.file_save()

func _on_drive_again_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Global.level += 1
				Global.goto_storyscreen()
				#Global.goto_level(Global.level+1)


func _on_quit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Global.goto_title()
