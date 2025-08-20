extends Node

var dark = false
var big = false
var current_icon = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _mouse_enters(icon: ColorRect) -> void:
	if current_icon != null and icon != current_icon:
		return
	if $Selected.visible:
		$Selected.global_position = icon.global_position
		$Selected.scale = icon.scale - (icon.scale/10)*3
		Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))
	if dark:
		$LVNumber.text = str("-Level ", icon.value, " DARK-")
	else:
		$LVNumber.text = str("-Level ", icon.value, "-")
	
	if icon is Bonus:
		$LVNumber.text = str("-Level ", icon.special_val, "-")
		$LVTitle.text = icon.title
		return
	
	if icon.unlocked:
		var best_time = Global.player_save.flags["best_time"][icon.value-1]
		if dark:
			$LVTitle.text = icon.darktitle
			#best_time = Global.player_save.flags["best_time"][icon.darkvalue-1]
		else:
			$LVTitle.text = icon.title
		
		if best_time != -1:
			$BestTime.visible = true
			$BestTime.text = "Best Time: " + Global.get_time(best_time)
	else:
		$LVTitle.text = "???"


func _on_level_icon_mouse_exited() -> void:
	if big == false:
		$BestTime.visible = false
	$Selected.global_position = Vector2(-9999,-9999)
	#Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))


func _on_back_menu_option_clicked(option: RichTextLabel) -> void:
	if big == false:
		Global.goto_title()
	else:
		for node in get_tree().get_nodes_in_group("transparent"):
			if node != current_icon:
				node.mouse_filter = 0
				var alpha = create_tween()
				alpha.tween_property(node,"modulate:a",1,.5)
		var tweens = [create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_CUBIC),create_tween()]
		$LVTitle.text = "Choose a Level"
		$LVNumber.text = ""
		$Selected.position = Vector2(99999,99999)
		$Selected.hide()
		$BestTime.hide()
		tweens[0].tween_property(current_icon,"position",current_icon.original_position,.5)
		tweens[2].tween_property($BestTime,"position",Vector2(0,64),.3)
		big = false
		await tweens[1].tween_property(current_icon,"scale",Vector2(1,1),.5).finished
		current_icon = null
		$Selected.show()



func _on_level_icon_clicked(icon):
	if current_icon != null and icon != current_icon:
		return
	if big == false:
		if icon.scale != Vector2(1,1):
			return
		current_icon = icon
		for node in get_tree().get_nodes_in_group("transparent"):
			if node != icon:
				node.mouse_filter = 2
				var alpha = create_tween()
				alpha.tween_property(node,"modulate:a",0,.2)
		var tweens = [create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_BACK)]
		$BestTime.visible == true
		$Selected.position = Vector2(99999,99999)
		$Selected.hide()
		tweens[0].tween_property(icon,"position",Vector2(100,44),.5)
		tweens[2].tween_property($BestTime,"position",Vector2(0,144),.3)
		big = true
		await tweens[1].tween_property(icon,"scale",Vector2(2,2),.5).finished
		$Selected.show()
	else:
		Audio.play_sfx(preload("uid://cf8yyq2r0tegw"),1.01) # vroom
		if dark:
			Global.level = icon.darkvalue
		else:
			Global.level = icon.value
		
		if Global.player_save.flags["option_skip_tutorials"]:
			Global.goto_level()
		else:
			Global.goto_storyscreen()


func _on_dark_menu_option_clicked(option):
	Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))
	$LVTitle.text = "Choose a Level"
	$LVNumber.text = ""
	dark = not dark
	for icon in get_tree().get_nodes_in_group("level_icon"):
		var sprite = icon.get_node("Sprite2D")
		if dark:
			sprite.frame = icon.darkvalue
		else:
			sprite.frame = icon.value
