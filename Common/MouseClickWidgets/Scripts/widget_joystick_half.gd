class_name WidgetJoystickHalf
extends WidgetJoystick

func _on_drag(delta: float) -> void:
	var distance = $DraggableItem.global_position.distance_to(global_position)
	var range = 150*scale.x
	if distance > range:
		var distance_offset = distance-range
		$DraggableItem.global_position = $DraggableItem.global_position.move_toward(global_position,distance_offset)

	$DraggableItem.position.y = min($DraggableItem.position.y,0)
	#value = ($DraggableItem.global_position-global_position) / (150*scale.x)
	$DraggableItem/RichTextLabel.text = str("x ", value.x).pad_decimals(2)
	$DraggableItem/RichTextLabel2.text = str("y ", value.y).pad_decimals(2)


func _on_draggable_item_drag_started(event_position: Variant) -> void:
	pass # Replace with function body.
