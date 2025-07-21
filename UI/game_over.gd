extends Node

func _ready() -> void:
	Global.title_shown = false

func option(opt: RichTextLabel) -> void:
	match opt.name:
		"DriveAgain":
			Global.goto_level()
			
		"Quit":
			Global.goto_title()
