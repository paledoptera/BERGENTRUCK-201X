extends Level


func _process(delta: float) -> void:
	super(delta)
	$MeshInstance3D.mesh.material.uv1_offset.z += (player.speed*delta)/100
	#$CityScape/Circle.get_surface_override_material(0).uv1_offset.z -= (player.speed*delta)/50
