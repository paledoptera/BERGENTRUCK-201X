extends Node2D
@export var done = false
#
func _ready() -> void:
	if Global.player_save.flags["level_time"][Global.level-1] < Global.player_save.flags["best_time"][Global.level-1] or Global.player_save.flags["best_time"][Global.level-1] == -1:
		Global.player_save.flags["best_time"][Global.level-1] = Global.player_save.flags["level_time"][Global.level-1]
	
	Global.title_shown = false
	Global.player_save.flags["levels_beaten"][2] = true
	SaveLoad.file_save()



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
