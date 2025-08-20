extends Area2D
class_name ClickableItem
@onready var click_component = $MouseClickComponent as MouseClickComponent

func _on_item_clicked(event_position):
    _clicked()

func _clicked() -> void :
    pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void :
    click_component.object_clicked(event)
