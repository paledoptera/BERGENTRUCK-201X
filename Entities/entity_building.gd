extends Entity

const SPRITES := [
	preload("uid://d2vici5x316kj"),
	#preload("res://Entities/Assets/Visuals/building.png"),
	#preload("res://Entities/Assets/Visuals/buildingblue.png"),
]


func _ready() -> void:
	super()
	$EntityContainer/Sprite3D.texture = SPRITES.pick_random()
	$EntityContainer/Sprite3D.flip_h = [true, false].pick_random()
