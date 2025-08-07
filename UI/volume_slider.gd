extends HSlider

@export var bus_name: String
@export var flag_name: String
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = Global.get_flag(flag_name)

func _on_value_changed(value: float) -> void:
	var base_value = 0.0
	if bus_name == "Music":
		base_value = -3.0
	AudioServer.set_bus_volume_db(bus_index,base_value+linear_to_db(value))
	Global.set_flag(flag_name,value)
	
