extends Sprite3D
class_name EntitySpawnBeam

var player: CharacterBody3D
var base_pos: Vector3

func _process(delta: float) -> void:
	global_position = base_pos 
	global_position.x -= (player.get_node("Camera3D").global_position.x - base_pos.x)
