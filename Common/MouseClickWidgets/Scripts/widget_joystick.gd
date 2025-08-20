class_name WidgetJoystick
extends Sprite2D

@export var drag_from_whole_circle = true
@export var snap_to_cursor = false
@export var drag_speed: float = 1.0
@export var snap_speed: float = 1.0
var value: Vector2 = Vector2.ZERO

func _ready() -> void :
	$DraggableItem.linked_notches = $Notches.get_children()
	$DraggableItem.keep_offset = not snap_to_cursor
	$DraggableItem.drag_speed = drag_speed
	$DraggableItem.notch_snap_speed = snap_speed

func _on_drag(delta: float) -> void :
	var distance = $DraggableItem.global_position.distance_to(global_position)
	var range = 150 * scale.x
	if distance > range:
		var distance_offset = distance - range
		$DraggableItem.global_position = $DraggableItem.global_position.move_toward(global_position, distance_offset)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void :
	if drag_from_whole_circle:
		$DraggableItem.drag_component.object_held_down(event)

func _process(delta: float) -> void :
	value = ($DraggableItem.global_position - global_position) / (150 * scale.x)
	$DraggableItem / RichTextLabel.text = str("x ", value.x).pad_decimals(2)
	$DraggableItem / RichTextLabel2.text = str("y ", value.y).pad_decimals(2)
