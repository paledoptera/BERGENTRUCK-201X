extends Item

func _ready():
	pass

func use() -> void:
	pass


func _on_explode_timeout():
	player.hp -= 15
	var particle = preload("res://Global/Particles/Pipis.tscn").instantiate()
	add_sibling(particle)
	Audio.play_sfx(preload("res://Global/SFX/deltarune-explosion.mp3"),2,10)
	particle.emitting = true
	particle.global_position = global_position
	queue_free()
