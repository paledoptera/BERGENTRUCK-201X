extends Node2D
@export var done = false
#
#func _ready() -> void:
	#Audio.play_music(preload("uid://clvnws7xol5k4"),false,false)


func _on_fade_gui_input(event: InputEvent) -> void:
	if not done:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var tween = create_tween()
				tween.tween_property($Fade,'modulate',Color.WHITE,2.0)
				tween.parallel().tween_property($AudioStreamPlayer,'volume_db',-50.0,2.0)
				tween.tween_callback(_goto_title)

func _goto_title() -> void:
	Global.goto_title()
