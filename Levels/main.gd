extends Node


@export var program : Node
@export var overlay : Node
@export var game_state : StateChart
var level_path : String

func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.game = self

#region Game States
func _title_screen_enter() -> void:
	_change_program("uid://bbyqb78v0mmni") # title_screen.tscn
	Audio.play_music(preload("uid://cc7we7oj6hn6t")) # Bereavement.ogg


func _level_select_enter() -> void:
	_change_program("uid://bsyjain0shc50") # level_select.tscn
	Audio.play_music(preload("uid://cc7we7oj6hn6t"))


func _level_enter() -> void:
	Audio.stop_music(true)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	_change_program(level_path)

func _level_exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _gameover_enter() -> void:
	_change_program("uid://dhue5xb8addio") # game_over.tscn

func _victory_enter() -> void:
	_change_program("uid://cs40bcv6qrnuo") # victory.tscn
#endregion



#region Functions
func _change_program(filepath:String):
	if program: program.queue_free()
	program = load(filepath).instantiate()
	add_child(program)

func _open_overlay(filepath:String):
	if overlay:
		return
	overlay = load(filepath).instantiate()
	$OverlayLayer.add_child(overlay)

func _close_overlay():
	if overlay:
		overlay.queue_free()
		overlay = null
#endregion
