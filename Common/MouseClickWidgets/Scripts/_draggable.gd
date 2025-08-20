extends Area2D
class_name DraggableItem

signal dragging(delta)

@export var keep_offset: bool = true
@export var drag_speed: float = 1.0
@export var notch_snap_speed: float = 1.0
@export var snap_to_notches_during_drag: bool = false
@export var linked_notches: Array[Node]

var drag: bool = false
var closest_notch: Marker2D
var offset = Vector2.ZERO
@onready var drag_component = $MouseDragComponent as MouseDragComponent


func _ready() -> void :
	drag = false

func _on_item_drag_started(event_position):
	if keep_offset:
		offset = event_position - global_position
	drag = true

func _on_item_drag_ended():
	drag = false
	if linked_notches.size() == 0:
		return
	closest_notch = Utility.find_closest_node_to_point(linked_notches, global_position)


func _process(delta: float) -> void :
	if drag:
		global_position = lerp(global_position, get_global_mouse_position() - offset, drag_speed)
		global_position = global_position.clamp(Vector2(0, 0), get_viewport_rect().size)
		dragging.emit(delta)
	elif closest_notch:
		global_position = lerp(global_position, closest_notch.global_position, notch_snap_speed)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void :
	drag_component.object_held_down(event)
