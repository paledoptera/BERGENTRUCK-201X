extends Entity

var dog_position = 0.0
@export var player: CharacterBody3D
var speed = 1.0
var current_speed = -1.5

func _ready() -> void:
	pass

func hit(player) -> void:
	super(player)
	speed = -2.5
	current_speed = 0.0

func _process(delta: float) -> void:
	super(delta)
	speed = lerp(speed,current_speed,0.01)
	dog_position -= speed
	$EntityContainer/Sprite3D.frame = wrap(round((($EntityContainer/Sprite3D.global_rotation.y)/deg_to_rad(360))*16),0,16)
	global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-90),deg_to_rad(12))
	if global_rotation.x >= deg_to_rad(11.9):
		current_speed = -2.2
	if global_rotation.x <= 0:
		current_speed = -1.5
