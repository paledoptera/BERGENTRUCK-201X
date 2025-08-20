class_name WidgetSlider
extends ColorRect

@export var snap_to_cursor = false
@export var drag_speed: float = 1.0
@export var snap_speed: float = 1.0
var value: float = 0

func _ready() -> void :
	for i in get_children():
		if i is Marker2D:
			i.reparent($Notches)
	$DraggableItem.linked_notches = $Notches.get_children()
	$DraggableItem.keep_offset = not snap_to_cursor
	$DraggableItem.drag_speed = drag_speed
	$DraggableItem.notch_snap_speed = snap_speed


func _on_drag(delta: float) -> void :
	$DraggableItem.position.y = 32
	$DraggableItem.position.x = clamp($DraggableItem.position.x, 32, size.x - 32)

	value = ($DraggableItem.position.x - 32) / (size.x - 64)
	$DraggableItem / RichTextLabel.text = str("x ", value)
