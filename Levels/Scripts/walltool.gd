@tool
extends StaticBody3D

@export var place_trees = true
@export var tree = preload("res://Entities/entity_tree.tscn")
var previous_property
var previous_amount

func _ready():
	if Engine.is_editor_hint():
		return
	make_trees()

func _process(delta):
	if Engine.is_editor_hint():
		$CollisionShape3D/Hurtbox/EntityContainer/CollisionShape3D2.shape = $CollisionShape3D.shape
		make_trees()

func make_trees():
	if $CollisionShape3D.transform == previous_property:
		return
	
	previous_property = $CollisionShape3D.transform
	$CollisionShape3D/Trees.position.z = $CollisionShape3D.shape.size.z/2
	var amount = range($CollisionShape3D/Trees.position.z/10)
	if previous_amount == amount:
		return
	for child in $CollisionShape3D/Trees.get_children():
		child.queue_free()
	if !place_trees:
		return
	previous_amount = amount
	var position_offset = 0
	for pos in amount:
		var treeinst = tree.instantiate()
		treeinst.collision_shape.disabled = true
		treeinst.solid = false
		treeinst.damage = 0
		treeinst.scale *= 4
		treeinst.position.y = -19.8*treeinst.scale.x
		treeinst.position.z = position_offset
		$CollisionShape3D/Trees.add_child(treeinst)
		position_offset -= 20
