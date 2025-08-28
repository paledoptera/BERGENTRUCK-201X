extends Node3D

@export var music : AudioStream
@export_file var item_queue_intro: Array[String]
@export_file var item_queue_mid: Array[String]
@export_file var item_queue_end: Array[String]
@export var trees: PackedScene = preload("uid://d1mwhsl0wm0tg") # bkg_tree.tscn
@export var timer : Timer
@export var player : Node3D
@export var entities : Node3D
@export var level_val : int = 1
var chunks_to_be_deleted : Array[Node]
var current_stage : int = 1
var faded_in = false
var win = false

var drain_timer = null
@export var drain_interval = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_sfx(preload("uid://cphvgk1cwgtnj"),0.99) # Car Start.wav
	var tween = create_tween()
	tween.tween_property($FadeEffect,'global_position',Vector2(-104,-48),1.5)
	tween.tween_callback(start_music)
	tween.tween_property($FadeEffect,'modulate',Color("ffffff00"),3.0)
	tween.tween_callback(fade_in_done)
	
	Global.level = level_val
	if Global.modifiers.Drain:
		drain_timer = Timer.new()
		add_child(drain_timer)
		drain_timer.start(drain_interval)
		drain_timer.connect("timeout",Callable(self,"drain"))
	for node in $"Progress Points".get_children():
		node.add_to_group("progress_point")

func drain():
	if Global.score > 10:
		print("DRAINED")
		Audio.play_sfx(preload("uid://ou7hsckbba2n"),1,5) #snd_screenshake.wav
		Global.score -= 1+5*Global.score/150

func start_music() -> void:
	Audio.play_music(music,false,false)

func fade_in_done() -> void:
	faded_in = true

func _process(delta: float) -> void:
	
	if Global.game:
		if Global.border == 1: #dynamic border
			Global.game.border.self_modulate = Color("ffffff",1.0-$FadeEffect.modulate.a)
			Global.game.border.self_modulate += Color("ffffff")*($FlashEffect.modulate.a*3)
		else:
			Global.game.border.self_modulate = Color("ffffff",1.0)
	
	if player.hp <= 0:
		Global.die()
		return
	elif Global.score >= Global.goal and not win:
		win = true
		if Global.level < 3:
			Audio.stop_music(true)
			var tween = create_tween()
			tween.tween_property($FadeEffect,'modulate',Color("ffffff"),3.0)
			tween.tween_callback(win_level)
		else:
			Audio.stop_music(true)
			Audio.play_sfx(preload("uid://bei3ovddpe0mp"),1.01)
			player.screenshake_strength = 40
			var tween = create_tween()
			tween.tween_property($FlashEffect,'modulate',Color.WHITE,0.5)
			tween.tween_property($FadeEffect,'modulate',Color("ffffff"),1.0)
			tween.tween_property($FlashEffect,'modulate',Color("ffffff00"),0.5)
			
			if Global.get_flag("option_skip_credits"):
				tween.tween_callback(win_level)
			else:
				tween.tween_callback(goto_credits)
			win = true
			
	

func _spawn_item() -> void:
	var queue: Array
	
	_check_stage_progress()
	
	match current_stage:
		1: queue = item_queue_intro.duplicate()
		2: queue = item_queue_mid.duplicate()
		3: queue = item_queue_end.duplicate()
	
	if queue.size() > 0:
		var item_path = queue.pick_random()
		if not item_path or item_path == "":
			return
		var item = load(item_path)
		if not item:
			return
		item = item.instantiate()
		#print("ITEM ", item, " CREATED")
		entities.add_child(item)
		if level_val == 3:
			item.get_node("EntityContainer/Sprite3D").modulate = Color("307dff")
		item.global_position.x = _get_random_item_position()
		item.global_rotation_degrees.x = -90


func _spawn_bkg_item() -> void:
	var tree_inst = trees.instantiate()
	entities.add_child(tree_inst)
	tree_inst.sprite.global_position.x += randi_range(-3,0)
	tree_inst.global_rotation_degrees.x = -90
	if level_val == 3:
		tree_inst.sprite.modulate = Color("307dff")
		tree_inst.sprite_2.modulate = Color("307dff")


func _check_stage_progress() -> void:
	var progress: float = float(Global.score) / float(Global.goal)
	
	if progress <= 0.20:
		current_stage = 1
	elif progress < 0.60:
		current_stage = 2
	else:
		current_stage = 3


func _get_random_item_position() -> float:
	var core_pos: float = randf_range(-15.0,15.0)
	var rand_subtract1: float = randf_range(0.0,17.0)
	var rand_subtract2: float = randf_range(0.0,17.0)
	
	match current_stage:
		1:
			rand_subtract1 = clamp(rand_subtract1,10.0,17.0)
		2:
			rand_subtract1 = clamp(rand_subtract1,5.0,17.0)
	
	if core_pos >= 0:
		rand_subtract1 *= -1
		rand_subtract2 *= -1
	
	core_pos -= (rand_subtract1+rand_subtract2) 
	
	return core_pos

func flash() -> void:
	$FlashEffect.modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property($FlashEffect,'modulate',Color("ffffff00"),0.3)
	tween.tween_callback(fade_in_done)

func win_level() -> void:
	reset_border()
	Global.win()

func goto_credits() -> void:
	reset_border()
	Global.goto_credits()

func reset_border() -> void:
	if Global.border == 1:
		Global.game.border.texture = preload("uid://bu325xsdlvy3f")
		Global.game.over_border.texture = preload("uid://bu325xsdlvy3f")
		Global.game.border.self_modulate = Color("ffffff",1.0)

func _exit_tree() -> void:
	Global.game.border.self_modulate = Color("ffffff",1.0)
