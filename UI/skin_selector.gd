extends Control

@onready var scroll_container = $ScrollContainer
@onready var Hbox = $ScrollContainer/HBoxContainer
@onready var characters = $ScrollContainer/HBoxContainer.get_children()
@onready var current_character = $ScrollContainer/HBoxContainer/Asgore
var scroll_amount

func _ready():
	scroll_amount = 54

func _on_left_pressed():
	if scroll_container.scroll_horizontal <= 0:
		Hbox.move_child(Hbox.get_child(characters.size()-1),0)
		scroll_container.scroll_horizontal += scroll_amount
	current_character = characters[characters.find(current_character)-1]
	$Left.mouse_filter = 2
	$Right.mouse_filter = 2
	await create_tween().tween_property(scroll_container,"scroll_horizontal",scroll_container.scroll_horizontal-scroll_amount,.2).set_trans(Tween.TRANS_SINE).finished
	$Left.mouse_filter = 0
	$Right.mouse_filter = 0
	update_selected()

func _on_right_pressed():
	if scroll_container.scroll_horizontal >= Hbox.size.x-scroll_container.size.x: #max scroll
		Hbox.move_child(Hbox.get_child(0),characters.size()-1)
		scroll_container.scroll_horizontal -= scroll_amount
	if characters.find(current_character)+1 >= characters.size():
		current_character = characters[0]
	else:
		current_character = characters[characters.find(current_character)+1]
	$Left.mouse_filter = 2
	$Right.mouse_filter = 2
	await create_tween().tween_property(scroll_container,"scroll_horizontal",scroll_container.scroll_horizontal+scroll_amount,.2).set_trans(Tween.TRANS_SINE).finished
	$Left.mouse_filter = 0
	$Right.mouse_filter = 0
	update_selected()

func update_selected():
	for node in characters:
		node.modulate = Color(1,1,1,1)
	current_character.modulate = Color(5,5,0,1)
	$Bio.text = current_character.description
