extends Control

var scroll_amount

@onready var bobbleSelected = $"BobbleScroll/HBoxContainer/The Child"
@onready var freshenerSelected = $"FreshenerScroll/HBoxContainer/Family Values"


func _ready():
	scroll_amount = 39
	select_saved($BobbleScroll,Global.player_save.flags.current_bobble_id,scroll_amount,bobbleSelected)
	select_saved($FreshenerScroll,Global.player_save.flags.current_freshener_id,scroll_amount,freshenerSelected)
	update_selected($BobbleScroll/HBoxContainer.get_children(),$BobbleScroll,bobbleSelected)
	update_selected($FreshenerScroll/HBoxContainer.get_children(),$FreshenerScroll,freshenerSelected)

func select_saved(scroll_container:ScrollContainer,ID:int,scroll_amount:float,current_character:Node):
	var Hbox = scroll_container.get_node("HBoxContainer")
	var characters = Hbox.get_children()
	var characterID = 0
	var loop = 0
	for node in characters:
		if node.ID == ID:
			characterID = loop
		loop += 1
	while 2 < characterID:
		if scroll_container.scroll_horizontal >= Hbox.size.x-scroll_container.size.x: #max scroll
			Hbox.move_child(Hbox.get_child(0),characters.size()-1)
			scroll_container.scroll_horizontal -= scroll_amount
		if characters.find(current_character)+1 >= characters.size():
			current_character = characters[0]
		else:
			current_character = characters[characters.find(current_character)+1]
		scroll_container.scroll_horizontal+=scroll_amount
		characterID -= 1
	while 2 > characterID:
		if scroll_container.scroll_horizontal <= 0:
			Hbox.move_child(Hbox.get_child(characters.size()-1),0)
			scroll_container.scroll_horizontal += scroll_amount
		current_character = characters[characters.find(current_character)-1]
		scroll_container.scroll_horizontal-=scroll_amount
		characterID += 1
	if scroll_container == $BobbleScroll:
		bobbleSelected = current_character
	else:
		freshenerSelected = current_character

func scroll_right(scroll_container:ScrollContainer,current_character:Node) -> Node:
	var Hbox = scroll_container.get_node("HBoxContainer")
	var characters = Hbox.get_children()
	
	if scroll_container.scroll_horizontal >= Hbox.size.x-scroll_container.size.x: #max scroll
		Hbox.move_child(Hbox.get_child(0),characters.size()-1)
		scroll_container.scroll_horizontal -= scroll_amount
	if characters.find(current_character)+1 >= characters.size():
		current_character = characters[0]
	else:
		current_character = characters[characters.find(current_character)+1]
	$Left.mouse_filter = 2
	$Right.mouse_filter = 2
	$FreshLeft.mouse_filter = 2
	$FreshRight.mouse_filter = 2
	await create_tween().tween_property(scroll_container,"scroll_horizontal",scroll_container.scroll_horizontal+scroll_amount,.2).set_trans(Tween.TRANS_SINE).finished
	$Left.mouse_filter = 0
	$Right.mouse_filter = 0
	$FreshLeft.mouse_filter = 0
	$FreshRight.mouse_filter = 0
	update_selected(characters,scroll_container,current_character)
	return current_character

func scroll_left(scroll_container:ScrollContainer,current_character:Node) -> Node:
	var Hbox = scroll_container.get_node("HBoxContainer")
	var characters = Hbox.get_children()
	if scroll_container.scroll_horizontal <= 0:
		Hbox.move_child(Hbox.get_child(characters.size()-1),0)
		scroll_container.scroll_horizontal += scroll_amount
	current_character = characters[characters.find(current_character)-1]
	$Left.mouse_filter = 2
	$Right.mouse_filter = 2
	$FreshLeft.mouse_filter = 2
	$FreshRight.mouse_filter = 2
	await create_tween().tween_property(scroll_container,"scroll_horizontal",scroll_container.scroll_horizontal-scroll_amount,.2).set_trans(Tween.TRANS_SINE).finished
	$Left.mouse_filter = 0
	$Right.mouse_filter = 0
	$FreshLeft.mouse_filter = 0
	$FreshRight.mouse_filter = 0
	update_selected(characters,scroll_container,current_character)
	return current_character

func _on_left_pressed():
	bobbleSelected = await scroll_left($BobbleScroll,bobbleSelected)

func _on_right_pressed():
	bobbleSelected = await scroll_right($BobbleScroll,bobbleSelected)

func _on_fresh_left_pressed():
	freshenerSelected = await scroll_left($FreshenerScroll,freshenerSelected)


func _on_fresh_right_pressed():
	freshenerSelected = await scroll_right($FreshenerScroll,freshenerSelected)

func update_selected(characters:Array,scroll_container:ScrollContainer,current_character:Node,loading = false):
	var Name = $BobbleName
	if scroll_container == $FreshenerScroll:
		Name = $FreshnerName
	if current_character.unlocked == true:
		for node in characters:
			node.modulate = Color(1,1,1,1)
		current_character.modulate = Color(5,5,0,1)
		Name.text = current_character.name
		if Name == $FreshnerName:
			Global.player_save.flags.current_freshener_id = current_character.ID
		else:
			Global.player_save.flags.current_bobble_id = current_character.ID
	else:
		Name.text = "???"
	Name.scale = Vector2(0.4,0.4)
	create_tween().tween_property(Name,"scale",Vector2(0.439,0.443),.2).set_trans(Tween.TRANS_BOUNCE)


func _on_color_picker_color_changed(color):
	$car.modulate = color
