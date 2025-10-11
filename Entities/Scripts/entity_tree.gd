extends Entity

const SPRITES := [
	preload("uid://d1mdkawxifsd7"), # tree_big.png
	preload("uid://b30enj4fl0sv6"), # tree_giant.png
	preload("uid://cysf0f7go2467"), # tree_pine.png
	preload("uid://cetvub4tbbdy2"), # tree_sparse.png
	]


func _ready() -> void:
	super()
	$EntityContainer/Sprite3D.texture = SPRITES.pick_random()
	$EntityContainer/Sprite3D.flip_h = [true, false].pick_random()
