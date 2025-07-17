extends Node3D


@export var music : AudioStream
@export_file var item_queue_intro: Array[String]
@export_file var item_queue_mid: Array[String]
@export_file var item_queue_end: Array[String]
@export var timer : Timer
@export var player : Node3D
@export var entities : Node3D

var bkg_item_spawn_timer : float = 0.0
var item_spawn_timer : float = 0.0
var item_spawn_threshold : float = 100.0
var chunks_to_be_deleted : Array[Node]
var current_stage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.stream = music
	$AudioStreamPlayer.play()

func _process(delta: float) -> void:
	item_spawn_timer += player.speed
	bkg_item_spawn_timer += player.speed
	
	if item_spawn_timer >= 50.0:
		item_spawn_timer -= 50.0
		_spawn_item()
	
	if bkg_item_spawn_timer >= 10.0:
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
		if not item_path:
			return
		var item = load(item_path).instantiate()
		#print("ITEM ", item, " CREATED")
		entities.add_child(item)
		item.global_position.x = _get_random_item_position()
		item.global_rotation_degrees.x = -70


func _spawn_bkg_item() -> void:
	var tree_inst = preload("res://Entities/entity_tree.tscn").instantiate()
	tree_inst.global_position.x = -45.0
	tree_inst.global_rotation_degrees.x = -90
	entities.add_child(tree_inst)


func _check_stage_progress() -> void:
	var progress: float = float(Global.score) / float(Global.goal)
	
	if progress < 0.25:
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
