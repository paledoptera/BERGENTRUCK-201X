extends Control

@export var display_text: String = "Modifiers"

func _enter_tree() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))
	var tween = create_tween()
	tween.tween_property(self,'scale',Vector2(.9,.9),0.05)


func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self,'scale',Vector2(1,1),0.05)
