extends Node

func _ready() -> void:
	Global.title_shown = false
	$YouCrashed.frame = Global.player_save.flags["current_skin_id"]

func option(opt: RichTextLabel) -> void:
	match opt.name:
		"DriveAgain":
			Global.goto_level()
			
		"Quit":
			Global.goto_title()
