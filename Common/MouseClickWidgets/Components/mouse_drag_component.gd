extends Node
class_name MouseDragComponent

signal drag_started(event_position)
signal drag_ended

func _ready() -> void :
	set_process(false)

func _process(delta: float) -> void :
	if not Input.is_action_pressed("click"):
		drag_ended.emit()

func object_held_down(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_started.emit(event.position)
				set_process(true)
			elif not event.pressed:
				drag_ended.emit()
				set_process(false)
