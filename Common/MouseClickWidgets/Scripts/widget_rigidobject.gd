class_name Item
extends RigidBody2D

@export var lifetime_in_seconds: float = 1.0
@export var use_sound : AudioStreamWAV
@export var score_amount : int = 100
var lifetime : float = 0
var strength = 50
@onready var lifetimer := $Timer
@onready var audio := $AudioStreamPlayer

func _ready() -> void:
	var rand_scale = randf_range(0.5,1.5)
	scale = Vector2(rand_scale,rand_scale)
	score_amount *= rand_scale
	$DraggableItem.top_level = true
	$DraggableItem.global_position = global_position
	$DraggableItem.global_rotation = global_rotation
	$DraggableItem.scale *= scale
	$GrabBox.scale *= scale
	$GrabBox.position = Vector2(0,0)-(($GrabBox.size*$GrabBox.scale)/2)
	$AudioStreamPlayer.stream = use_sound

func _integrate_forces(state) -> void:
	if $DraggableItem.drag:
		linear_velocity = global_position.direction_to($DraggableItem.global_position) * (global_position.distance_to($DraggableItem.global_position) * strength)

func _physics_process(delta: float) -> void:
	if $DraggableItem.drag:
		global_position = $DraggableItem.global_position
		global_rotation = $DraggableItem.global_rotation
	else:
		$DraggableItem.global_position = global_position
		$DraggableItem.global_rotation = global_rotation

func _on_input_event(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var new_event = event
		print(new_event.position)
		new_event.position = global_position + new_event.position + $GrabBox.position
		$DraggableItem/MouseDragComponent.object_held_down(event)


func _on_timer_timeout() -> void:
	Global.score += score_amount
	queue_free()
