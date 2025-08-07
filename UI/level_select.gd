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
	
	if icon is Bonus:
		$LVNumber.text = str("-Level ", icon.special_val, "-")
		$LVTitle.text = icon.title
		return
	
	if icon.unlocked:
		$LVTitle.text = icon.title
		if Global.player_save.flags["best_time"][icon.value-1] != -1:
			$BestTime.visible = true
			$BestTime.text = "Best Time: " + Global.get_time(Global.player_save.flags["best_time"][icon.value-1])
	else:
		$LVTitle.text = "???"


func _on_level_icon_mouse_exited() -> void:
	$BestTime.visible = false
	$Selected.global_position = Vector2(-9999,-9999)
	#Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))


func _on_back_menu_option_clicked(option: RichTextLabel) -> void:
	Global.goto_title()
	pass # Replace with function body.
