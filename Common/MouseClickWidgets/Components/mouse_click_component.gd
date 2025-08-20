extends Node
class_name MouseClickComponent

signal clicked(event_position)

func object_clicked(event: InputEvent):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                clicked.emit(event.position)
