class_name Item
extends RigidBody2D

@export var lifetime_in_seconds: float = 1.0
@export var use_sound : AudioStreamWAV
@export var score_amount : int = 100
var lifetime : float = 0
var strength = 50
@export var weight: float = 1.0
@onready var lifetimer := $Timer
@onready var audio := $AudioStreamPlayer
@export var player : Node3D
@export var damage : float = 0.0

func _ready() -> void:
	rotation_degrees = randi_range(0,360)
	var rand_scale = randf_range(0.75,1.25)
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
	else:
		apply_force(global_position.direction_to(global_position+Vector2(player.car_velocity.x,player.car_velocity.y)) * (global_position.distance_to(global_position+Vector2(player.car_velocity.x,player.car_velocity.y) * strength * 50)/weight))

func _physics_process(delta: float) -> void:
	if $DraggableItem.drag:
		if damage:
			if $AsgoreScreamTimer.is_stopped():
				Audio.play_sfx(preload("uid://cjkg2bw1yl0j8"),randf_range(0.9,1.1),3)
				$AsgoreScreamTimer.start()
			if $DamageTimer.is_stopped():
				player.hp -= damage
				$DamageTimer.start()
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
