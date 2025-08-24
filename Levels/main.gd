extends Node


@export var program : Node
@export var overlay : Node
@export var game_state : StateChart
@export var window : SubViewport
@export var border : TextureRect
@export var over_border : TextureRect
var level_path : String
var boot: bool = false


func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.game = self

#region Game States
func _title_screen_enter() -> void:
	if not boot:
		boot = true
		get_window().move_to_center()
	_change_program("uid://bbyqb78v0mmni") # title_screen.tscn
	Audio.play_music(preload("uid://cc7we7oj6hn6t"),false,false) # Bereavement.ogg


func _level_select_enter() -> void:
	#if Global.get_flag("levels_beaten")[2]:
	_change_program("uid://chf1v1go0vts5") # level_select_bonus.tscn
	#else:
	#	_change_program("uid://bsyjain0shc50") # level_select.tscn
	Audio.play_music(preload("uid://cc7we7oj6hn6t"),false,false)


func _level_enter() -> void:
	Audio.stop_music(true)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	_change_program(level_path)

func _level_process(delta) -> void:
	if Input.is_action_just_pressed("click_right"):
		get_tree().paused = not get_tree().paused
		Audio.play_sfx(preload("uid://bigavjv4ovlma"))
		if get_tree().paused == true:
			_open_overlay("uid://bjuchij38e3hi")
		else:
			_close_overlay()
	
	
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	

func _level_exit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _gameover_enter() -> void:
	Audio.stop_music(false)
	_change_program("uid://dhue5xb8addio") # game_over.tscn

func _victory_enter() -> void:
	_change_program("uid://cs40bcv6qrnuo") # victory.tscn

func _story_screen_enter() -> void:
	
	Audio.stop_music(true)
	_change_program("uid://cguaj6qonrj1x") # story_screen.tscn
	pass # Replace with function body.
#endregion

func fade_to_border(texture: Texture2D) -> void:
	over_border.texture = border.texture
	$AnimationPlayer.play("change_border")
	border.texture = texture


#region Functions
func _change_program(filepath:String):
	if program: program.queue_free()
	program = load(filepath).instantiate()
	window.add_child(program)
	
	update_dynamic_border()
		

func update_dynamic_border() -> void:
	if Global.border != 1:
		return
	
	if not program:
		return
	
	match program.name:
		
		"TitleScreen":
			if program.logo_bobbing:
				#border.texture = preload("uid://bu325xsdlvy3f") # Blank.png
				fade_to_border(preload("uid://bxwx3be5d5vaa")) # ForestNight.png
			else:
				border.texture = preload("uid://bu325xsdlvy3f") # Blank.png
		"LevelSelect":
			fade_to_border(preload("uid://jfrrgron4tmh")) # Arcade.png
		"Level1":
			fade_to_border(preload("uid://ca6gusig1qi0u")) # ForestDay.png
		"Level2":
			fade_to_border(preload("uid://1tchac8mct7w")) # ForestEvening.png
		"Level3":
			fade_to_border(preload("uid://bxwx3be5d5vaa")) # ForestNight.png
		
		"LevelQ", "LevelS":
			fade_to_border(preload("uid://cy1hkw0wv0i01")) # City.png
		
		"Level3Hard":
			fade_to_border(preload("uid://dlc5e78c7swx4")) # Cathedral.png
		
		_:
			fade_to_border(preload("uid://b41hk6q2ky6f8")) # Simple.png

func _open_overlay(filepath:String):
	if overlay: overlay.queue_free()
	overlay = load(filepath).instantiate()
	$SubViewportContainer/Overlay.add_child(overlay)

func _close_overlay():
	if overlay:
		overlay.queue_free()
		overlay = null
#endregion


func _credits_entered() -> void:
	_change_program("uid://cjh1hi4cjh33m")

func _controlsplash_entered() -> void:
	Audio.stop_music()
	_change_program("uid://b2xygcidcdw4m")


func _options_entered() -> void:
	_change_program("uid://byiyp5l2tjvif")
	pass # Replace with function body.
