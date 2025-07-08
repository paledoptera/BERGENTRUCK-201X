extends GridMap

const ENTITIES = {
	
	"tree": {
			"cell_id": 0,
			"scene_id": preload("uid://bujhn23r8iqh8")
		},
	
	"flowerbush": {
			"cell_id": 4,
			"scene_id": preload("uid://bnn5y7tkfk8rg")
		},
	
	}


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	position.y -= 4
	for val in ENTITIES:
		var entity = ENTITIES.get(val)
		var used_cells = get_used_cells_by_id(entity.get("cell_id"))
		replace_tiles(used_cells, entity.get("scene_id"))
	
	#var flower_bushes = get_used_cells_by_id(4)
	#replace_tiles(flower_bushes,

func get_used_cells_by_id(id: int):
	var arr = []
	var cells = get_used_cells()
	for i in cells:
		if(get_cell_item(Vector3(i.x,i.y,i.z)) == id):
			arr.append(i)
	return arr

func replace_tiles(cell_array : Array, inst : PackedScene):
	for i in cell_array:
		var new_object = new_object(i, inst)
	print(get_used_cells())

func new_object(cell : Vector3, inst : PackedScene):
	var new_inst = inst.instantiate()
	var tile_pos = to_global(map_to_local(cell))
	new_inst.global_position = tile_pos
	set_cell_item(cell,-1)
	add_child(new_inst)
	return new_inst
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
