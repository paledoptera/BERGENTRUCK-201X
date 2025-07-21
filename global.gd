extends Node

var score: float = 0.0
var goal: float = 100.0
var level: int = 1
var game: Node
var title_shown: bool = false
var controls_shown: bool = false
@onready var player_save : PlayerSave

func _ready() -> void:
	player_save = SaveLoad.file_load()
	if player_save.flags["option_skip_tutorials"]:
		controls_shown = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click_right"):
		game.game_state.send_event("Back")

func goto_level(value : int = level) -> void:
	var lv : String
	
	match value:
		1:
			lv = "uid://c7p8pcqopqawn" # level1.tscn
		2:
			lv = "uid://dfltl3btm1pp6" # level2.tscn
		3:
			lv = "uid://bc8vcjm8kaofg" # level3.tscn
	
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
