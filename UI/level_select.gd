extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _mouse_enters(icon: ColorRect) -> void:
	$Selected.global_position = icon.global_position
	Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))
	$LVNumber.text = str("-Level ", icon.value, "-")
	if icon.unlocked:
		$LVTitle.text = icon.title
	else:
		$LVTitle.text = "???"


func _on_level_icon_mouse_exited() -> void:
	$Selected.global_position = Vector2(-9999,-9999)
	#Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))
