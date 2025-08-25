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

var modifiers = {
	"FragileCar": false,
	"NoSlow": false,
	"NoHeal": false,
	"DrunkMode": false,
	"Drain": false
}

@onready var player_save : PlayerSave
@onready var _default_save := PlayerSave.new()

func _ready() -> void:
	player_save = SaveLoad.file_load()
	_refresh_flags()
	border = get_flag("border")
	
	if get_flag("option_skip_tutorials"):
		controls_shown = false
	
	AudioServer.set_bus_volume_linear(0,get_flag("option_master_vol"))
	AudioServer.set_bus_volume_linear(1,get_flag("option_music_vol"))
	AudioServer.set_bus_volume_linear(2,get_flag("option_sound_vol"))


func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 



func update_border() -> void:
	if not game:
		return
	var border_tex : Texture2D = preload("uid://b41hk6q2ky6f8") # Simple.png
	game.over_border.visible = false
	game.border.visible = true
	match border:
		0: # NONE
			game.border.visible = false
			game.border.texture = preload("uid://bu325xsdlvy3f") # Blank.png
			
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
		if player_save.flags[flag] is Array:
			push_error("Array flags must be set with set_flag_array!")
			return false
		player_save.flags[flag] = value
	else:
		if not flag_exists(flag):
			return false
		
		_refresh_flags()
		if player_save.flags[flag] is bool:
			player_save.flags[flag] = bool(value)
		else:
			player_save.flags[flag] = value


func set_flag_array(flag:String, value, index: int):
	flag = flag.to_lower()
	
	var flag_array: Array = get_flag(flag)
	var default_flag_array: Array = _default_save.flags[flag]
	
	if not flag_array:
		if not flag_exists(flag):
			return false
		_refresh_flags()
		flag_array = get_flag(flag)
	
	if flag_array.size() != default_flag_array.size():
		_refresh_flags()
	
	index = clamp(index,0,flag_array.size()-1)
	flag_array[index] = value
	set_flag(flag,flag_array)


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
			# check if it's an array
			if player_save.flags[key] is Array:
				for val in range(_default_save.flags[key].size()):
					if val >= player_save.flags[key].size():
						continue
					_default_save.flags[key][val] = player_save.flags[key][val]
					
				continue
				# so there was an issue with array flags in that if using _refresh_flags,
				# since arrays are a value in of themselves it wouldn't actually
				# expand old arrays to the size of new arrays, it'd just replace the 
				# entire new array with the old one which causes crashes.
				# this method fixes that
			
			_default_save.flags[key] = player_save.flags[key] # overwriting all flags that the player file has
	
	player_save.flags = _default_save.flags


func goto_level(value : int = level) -> void:
	var lv : String
	
	match value:
		1: # Flowers
			lv = "uid://c7p8pcqopqawn" # level1.tscn
		2: # Fast Food
			lv = "uid://dfltl3btm1pp6" # level2.tscn
		3: # Knight Fight
			lv = "uid://bc8vcjm8kaofg" # level3.tscn
		4: # Punchout City
			lv = "uid://b0obvicgtatpa" # levelQ.tscn
		#5: # Dog Race
		
		# DARK MODE
		
		#6: # Thorns
		7: # Buyout City
			lv = "uid://cnseiocfp02jr" # levelS.tscn
		8: # Frozen Food
			lv = "uid://dlbag4r2ncy86" # level2_hard.tscn
		#9: # Dog Chase
		10: # Light Fight
			lv = "uid://cro28ctqlf873" # level3_hard.tscn
	
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
	var all_modifiers = true
	for mod in modifiers:
		if modifiers[mod] == true:
			print("Beaten with ",mod)
			if modifiers[mod] not in player_save.flags["level_beaten_modifiers"][level-1]:
				player_save.flags["level_beaten_modifiers"][level-1].append(mod)
		else:
			all_modifiers = false
	if all_modifiers:
		player_save.flags["levels_mastered"][level-1] = true
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
