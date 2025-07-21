extends Node


func _ready() -> void:
	update_txt_colors()



func menuoption(option: RichTextLabel) -> void:
	match option.name:
		"Fullscreen":
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
		
		"SpeedrunTimer":
			Global.player_save.flags["option_show_time"] = not Global.player_save.flags["option_show_time"]
		
		"SkipTutorials":
			Global.player_save.flags["option_skip_tutorials"] = not Global.player_save.flags["option_skip_tutorials"]
		
		"Return":
			Global.goto_title()
		
	update_txt_colors()
	SaveLoad.file_save()

func update_txt_colors() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$Fullscreen.modulate = Color.WHITE
	else:
		$Fullscreen.modulate = Color("757575")

	if Global.player_save.flags["option_show_time"]:
		$SpeedrunTimer.modulate = Color.WHITE
	else:
		$SpeedrunTimer.modulate = Color("757575")
	
	if Global.player_save.flags["option_skip_tutorials"]:
		$SkipTutorials.modulate = Color.WHITE
	else:
		$SkipTutorials.modulate = Color("757575")
