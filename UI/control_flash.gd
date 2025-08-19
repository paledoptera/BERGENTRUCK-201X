extends Node

var clickable = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect,'size',$ColorRect.size+Vector2(1,1),1.0)
	tween.tween_property($ColorRect,'modulate',Color("ffffff00"),1.0)
	tween.tween_callback(enable_click)
	if OS.get_name() == "iOS":
		$TextureRect/RichTextLabel.show()

func enable_click() -> void:
	clickable = true

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and clickable:
				var tween = create_tween()
				tween.tween_property($ColorRect,'modulate',Color("ffffff"),0.5)
				tween.tween_property($ColorRect,'size',$ColorRect.size+Vector2(1,1),0.5)
				tween.tween_callback(next)

func next() -> void:
	Global.goto_storyscreen()
