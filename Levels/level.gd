extends Node3D


@export var music : AudioStream
@export_file var item_queue_intro: Array[String]
@export_file var item_queue_mid: Array[String]
@export_file var item_queue_end: Array[String]
@export var timer : Timer
@export var player : Node3D
@export var entities : Node3D
@export var level_val : int = 1
var bkg_item_spawn_timer : float = 0.0
var item_spawn_timer : float = 0.0
var item_spawn_threshold : float = 100.0
var chunks_to_be_deleted : Array[Node]
var current_stage : int = 1
var faded_in = false
var win = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_sfx(preload("uid://cphvgk1cwgtnj"),0.99) # Car Start.wav
	var tween = create_tween()
	tween.tween_property($FadeEffect,'global_position',Vector2(-104,-48),1.5)
	tween.tween_callback(start_music)
	tween.tween_property($FadeEffect,'modulate',Color("ffffff00"),3.0)
	tween.tween_callback(fade_in_done)
	
	Global.level = level_val

func start_music() -> void:
	Audio.play_music(music,false,false)

func fade_in_done() -> void:
	faded_in = true

func _process(delta: float) -> void:
	if player.hp <= 0:
		Global.die()
		return
	elif Global.score >= Global.goal and not win:
		win = true
		Audio.stop_music(true)
		var tween = create_tween()
		tween.tween_property($FadeEffect,'modulate',Color("ffffff"),3.0)
		tween.tween_callback(win_level)
	
	if faded_in:
		item_spawn_timer += player.speed
	bkg_item_spawn_timer += player.speed
	
	if item_spawn_timer >= 75.0:
		item_spawn_timer -= 75.0
		_spawn_item()
	
	if bkg_item_spawn_timer >= 40.0:
		bkg_item_spawn_timer -= 40.0
		_spawn_bkg_item()

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
	var tree_inst = preload("uid://d1mwhsl0wm0tg").instantiate() # bkg_tree.tscn
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
	Global.win()
