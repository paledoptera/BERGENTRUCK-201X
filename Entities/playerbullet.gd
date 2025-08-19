extends Node3D

func _ready():
	Audio.play_sfx(preload("res://Global/SFX/gunshotjbudden.mp3"),1,10)

func _process(delta):
	position.z -= 100*delta
