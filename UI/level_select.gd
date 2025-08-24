extends Node

var dark = false
var big = false
var closet = false
var current_icon = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$LVNumber/Dark.text = $LVNumber.text
	$LVTitle/Dark.text = $LVTitle.text
	$BestTime/Dark.text = $BestTime.text
	$Modifiers/Dark.text = $Modifiers.text
	if $LVNumber.text == "":
		$LVNumber/Dark/DarkGradient.hide()
	else:
		$LVNumber/Dark/DarkGradient.show()


func _mouse_enters(icon: ColorRect) -> void:
	if current_icon != null and icon != current_icon and big == true:
		return
	if $Selected.visible:
		$Selected.global_position = icon.global_position
		$Selected.scale = icon.scale - (icon.scale/10)*3
		Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))
	var levelnum = str(icon.value)
	if dark:
		if icon.dark_number_overide != "":
			levelnum = icon.dark_number_overide
	else:
		if icon.number_overide != "":
			levelnum = icon.number_overide
	$LVNumber.text = str("-Level ", levelnum, "-")
	if icon is Bonus:
		$LVNumber.text = str("-Level ", icon.special_val, "-")
		$LVTitle.text = icon.title
		return
	updatetitle(icon)

func updatetitle(icon: ColorRect):
	$BestTime.visible = false
	if icon.unlocked:
		var best_time = Global.player_save.flags["best_time"][icon.value-1]
		if dark:
			$LVTitle.text = icon.darktitle
			best_time = Global.player_save.flags["best_time"][icon.darkvalue-1]
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
	if big == false and closet == false:
		Global.goto_title()
	if big == true:
		$Back.hide()
		big = false
		for node in get_tree().get_nodes_in_group("transparent"):
			if node != current_icon:
				node.mouse_filter = 0
				var alpha = create_tween()
				alpha.tween_property(node,"modulate:a",1,.5)
		var tweens = [create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_CUBIC),create_tween(),create_tween().set_trans(Tween.TRANS_CUBIC)]
		$LVTitle.text = "Choose a Level"
		$LVNumber.text = ""
		$Selected.position = Vector2(99999,99999)
		current_icon.mouse_filter = 2
		$BestTime.hide()
		tweens[0].tween_property(current_icon,"position",current_icon.original_position,.5)
		tweens[2].tween_property($BestTime,"position",Vector2(0,64),.3)
		tweens[3].tween_property($Modifiers,"position:y",240,.3)
		await tweens[1].tween_property(current_icon,"scale",Vector2(1,1),.5).finished
		current_icon.mouse_filter = 0
		current_icon = null
		$Back.show()
	elif closet == true:
		$LVTitle.text = "Choose a Level"
		$LVNumber.text = ""
		$SkinSelector.hide()
		for node in get_tree().get_nodes_in_group("transparent"):
			if node != $Skins:
				node.mouse_filter = 0
				var alpha = create_tween()
				alpha.tween_property(node,"modulate:a",1,.5)
		var tweens = [create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_BACK)]
		$Dark.show()
		$Gradient.hide()
		tweens[1].tween_property($Skins,"scale",Vector2(1,1),.5)
		tweens[2].tween_property($Skins,"modulate",Color(1,1,1,1),.3)
		closet = false
		await tweens[0].tween_property($Skins,"position:y",155,.5).finished
		$Skins.mouse_filter = 0
		SaveLoad.file_save() #saves the skin you chose
	

func _on_level_icon_clicked(icon):
	if current_icon != null and icon != current_icon:
		return
	if big == false:
		big = true
		if icon.scale != Vector2(1,1):
			return
		current_icon = icon
		for node in get_tree().get_nodes_in_group("transparent"):
			if node != icon:
				node.mouse_filter = 2
				var alpha = create_tween()
				alpha.tween_property(node,"modulate:a",0,.2)
		var tweens = [create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK),create_tween().set_trans(Tween.TRANS_BACK)]
		$Selected.position = Vector2(99999,99999)
		current_icon.mouse_filter = 2
		tweens[0].tween_property(icon,"position",Vector2(100,44),.5)
		tweens[2].tween_property($BestTime,"position",Vector2(0,144),.3)
		tweens[3].tween_property($Modifiers,"position:y",170,.3)
		await tweens[1].tween_property(icon,"scale",Vector2(2,2),.5).finished
		current_icon.mouse_filter = 0
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
	$LVTitle/Dark.visible = dark
	$LVNumber/Dark.visible = dark
	$BestTime/Dark.visible = dark
	$Modifiers/Dark.visible = dark
	for icon in get_tree().get_nodes_in_group("level_icon"):
		icon.update_visual(dark) #update icons
	if big:
		updatetitle(current_icon)
	if dark:
		$TextureRect.texture = preload("res://UI/Assets/Visuals/level_select_dark_bkg.png")
		$LVNumber.add_theme_color_override("default_color",Color.BLACK)
		$Skins.icon = preload("uid://buta83lh3jwxf") #ClosetDark.png
	else:
		$TextureRect.texture = preload("res://UI/Assets/Visuals/level_select_bkg.png")
		$LVNumber.remove_theme_color_override("default_color")
		$Skins.icon = preload("uid://lqjqgdnqxcj7") #Closet.png
	$black.show()
	await get_tree().create_timer(.4).timeout
	$black.hide()


func _on_skins_menu_option_clicked(option):
	if closet == false:
		$Skins.mouse_filter = 2
		for node in get_tree().get_nodes_in_group("transparent"):
			if node != $Skins:
				node.mouse_filter = 2
				create_tween().tween_property(node,"modulate:a",0,.2)
		var tweens = [create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_CUBIC),create_tween().set_trans(Tween.TRANS_BACK)]
		$BestTime.hide()
		$Dark.hide()
		$Back.hide()
		$Selected.position = Vector2(99999,99999)
		tweens[1].tween_property($Skins,"scale",Vector2(6,6),.5)
		tweens[0].tween_property($Skins,"position:y",75,.5)
		closet = true
		$SkinSelector.modulate.a = 0
		await tweens[2].tween_property($Skins,"modulate",Color(0,0,0,1),.3).finished
		$Gradient.show()
		$SkinSelector.show()
		create_tween().tween_property($SkinSelector,"modulate:a",1,.5).set_trans(Tween.TRANS_SINE)
		$Back.show()
