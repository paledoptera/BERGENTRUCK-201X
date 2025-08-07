extends Node


func _ready() -> void:
	update_txt_colors()



func menuoption(option: RichTextLabel) -> void:
	match option.name:
		"Fullscreen":
			Global.toggle_fullscreen()
		
		"SpeedrunTimer":
			Global.player_save.flags["option_show_time"] = not Global.player_save.flags["option_show_time"]
		
		"SkipTutorials":
			Global.player_save.flags["option_skip_tutorials"] = not Global.player_save.flags["option_skip_tutorials"]
		
		"Border":
			Global.player_save.flags["border"] = wrapi(Global.player_save.flags["border"]+1,0,6)
			Global.border = Global.get_flag("border")
		
		"SkipCredits":
			Global.set_flag("option_skip_credits", not Global.get_flag("option_skip_credits")) 
		
		"Return":
			SaveLoad.file_save()
			if Global.game.program is Level:
				Global.game._open_overlay("uid://bjuchij38e3hi")
			else:
				Global.goto_title()
		
	update_txt_colors()
	

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
	
	if Global.get_flag("option_skip_credits"):
		$SkipCredits.modulate = Color.WHITE
	else:
		$SkipCredits.modulate = Color("757575")
	
	$Border.modulate = Color.WHITE
	
	match Global.border:
		0:
			$Border.modulate = Color("757575")
			$Border.text = "Border: None"
		1:
			$Border.text = "Border: Dynamic"
		2:
			$Border.text = "Border: Simple"
		3: 
			$Border.text = "Border: Forest Day"
		4: 
			$Border.text = "Border: Forest Night"
		5:
			$Border.text = "Border: Arcade"


func _on_volume_sfx_drag_ended(value_changed: bool) -> void:
	Audio.play_sfx(preload("uid://bwrewdkj3pqlf")) # Sniff.wav
