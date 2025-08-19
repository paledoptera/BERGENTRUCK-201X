extends Node

var score: float = 0.0
var goal: float = 100.0
var level: int = 1
var game: Node
var title_shown: bool = false
var controls_shown: bool = false
var border: int = -1:
	set(value):
		border = value
		update_border()
		update_res()
var res_scale: int = 2:
	set(value):
		update_res()

@onready var player_save : PlayerSave
@onready var _default_save := PlayerSave.new()

func _ready() -> void:
	player_save = SaveLoad.file_load()
	if player_save.flags.levels_beaten.size() == 3:
		player_save.flags.levels_beaten.append(false)
		player_save.flags.levels_beaten.append(false)
		player_save.flags.levels_beaten.append(false)
	if player_save.flags.best_time.size() == 3:
		player_save.flags.best_time.append(-1)
		player_save.flags.best_time.append(-1)
		player_save.flags.best_time.append(-1)
	if player_save.flags.level_time.size() == 3:
		player_save.flags.level_time.append(0)
		player_save.flags.level_time.append(0)
		player_save.flags.level_time.append(0)
	
	border = get_flag("border")
	
	if get_flag("option_skip_tutorials"):
		controls_shown = false
	
	AudioServer.set_bus_volume_linear(0,get_flag("option_master_vol"))
	AudioServer.set_bus_volume_linear(1,get_flag("option_music_vol"))
	AudioServer.set_bus_volume_linear(2,get_flag("option_sound_vol"))


func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		get_window().size = Vector2i(960,540)
		get_window().content_scale_size = Vector2i(480,270)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		update_res()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
		update_res()


func update_res() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		if border == 0:
			game.border.visible = false
			game.over_border.visible = false
		else:
			game.border.visible = true
		return
		
	if border == 0:
		get_window().content_scale_size = Vector2i(320,240)
		get_window().size = Vector2i(640,480) 
	else:
		game.border.visible = true
		get_window().size = Vector2i(960,540)
		get_window().content_scale_size = Vector2i(480,270)
	
	get_window().move_to_center()

func update_border() -> void:
	var border_tex : Texture2D = preload("uid://b41hk6q2ky6f8") # Simple.png
	game.over_border.visible = false
	match border:
		1: # DYNAMIC
			game.over_border.visible = true
			game.border.texture = preload("uid://bu325xsdlvy3f") # Blank.png
			game.update_dynamic_border()
		2:
			game.border.texture = preload("uid://b41hk6q2ky6f8") # Simple.png
		3:
			game.border.texture = preload("uid://ca6gusig1qi0u") # TownLight.png
		4: 
			game.border.texture = preload("uid://bxwx3be5d5vaa") # TownDark.png
		5:
			game.border.texture = preload("uid://jfrrgron4tmh") # Arcade.png
	
	
	
	#game.update_border(border_tex)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click_right"):
		game.game_state.send_event("Back")

func get_flag(flag:String):
	flag = flag.to_lower()
	
	if flag in player_save.flags.keys():
		return player_save.flags[flag]
	else:
		if not flag_exists(flag):
			return false
		
		_refresh_flags()
		return player_save.flags[flag]


func set_flag(flag:String, value):
	flag = flag.to_lower()
	
	if flag in player_save.flags.keys():
		player_save.flags[flag] = value
	else:
		if not flag_exists(flag):
			return false
		
		_refresh_flags()
		if player_save.flags[flag] is bool:
			player_save.flags[flag] = bool(value)
		else:
			player_save.flags[flag] = value


func flag_exists(flag: String) -> bool:
	if flag not in _default_save.flags.keys():
		push_error("Flag ", flag, " does not exist!")
		return false
	else:
		return true

func _refresh_flags() -> void:
	# this is a fallback in case flags dont exist in the player's savefile, 
	# it loads all possible new flags from default because the old save doesn't have new flags
	
	for key in _default_save.flags.keys():
		if key in player_save.flags:
			_default_save.flags[key] = player_save.flags[key] # overwriting all flags that the player file has
	
	player_save.flags = _default_save.flags



func goto_level(value : int = level) -> void:
	var lv : String
	
	match value:
		1:
			lv = "uid://c7p8pcqopqawn" # level1.tscn
		2:
			lv = "uid://dfltl3btm1pp6" # level2.tscn
		3:
			lv = "uid://bc8vcjm8kaofg" # level3.tscn
		6:
			lv = "res://Levels/levelSPAM.tscn"
	
	game.level_path = lv
	return game.game_state.send_event("Start")

func goto_title() -> void:
	score = 0.0
	game.game_state.send_event("Title")

func goto_levelselect() -> void:
	game.game_state.send_event("LevelSelect")

func goto_storyscreen() -> void:
	if not controls_shown:
		controls_shown = true
		game.game_state.send_event("ControlSplash")
		return
	elif player_save.flags["option_skip_tutorials"]:
		goto_level()
	else:
		game.game_state.send_event("StoryScreen")

func goto_credits() -> void:
	game.game_state.send_event("Credits")

func die() -> void:
	score = 0.0
	game.game_state.send_event("Die")

func win() -> void:
	score = 0.0
	game.game_state.send_event("Win")

func get_time(time: float) -> String:
	var seconds = time
	var minutes = int(seconds / 60)
	var hours = int(minutes / 60)
	seconds -= minutes * 60
	minutes -= hours * 60
	
	var text: String = '%02d:%02d' % [minutes, seconds]
	return text

func goto_options() -> void:
	game.game_state.send_event("Options")
