extends Node2D


func _on_menu_option_clicked(opt: RichTextLabel) -> void:
	match opt.name:
		"OptResume":
			get_tree().paused = false
			Global.game._close_overlay()
			queue_free()
		
		"OptOptions":
			Global.game._open_overlay("uid://byiyp5l2tjvif") # options
		
		"OptQuitToTitle":
			Global.title_shown = false
			Global.goto_title()
			get_tree().paused = false
			Global.game._close_overlay()
			queue_free()
