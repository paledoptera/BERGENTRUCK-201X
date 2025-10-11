extends Node3D

func _ready():
	Audio.play_sfx(preload("uid://bbavuftg75n0h"),1,10)

func _process(delta):
	position.z -= 100*delta
