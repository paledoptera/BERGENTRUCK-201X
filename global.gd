extends Node

var score: float = 0.0
var goal: float = 100.0
var level: int = 1
var game: Node
@onready var player_save := PlayerSave.new()

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

func die() -> void:
	score = 0.0
	game.game_state.send_event("Die")

func win() -> void:
	score = 0.0
	game.game_state.send_event("Win")
