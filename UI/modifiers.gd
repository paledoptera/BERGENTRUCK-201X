extends RichTextLabel

func _ready():
	for child in $Buttons.get_children():
		child.connect("pressed",Callable(self,"_on_modifier_menu_option_clicked").bind(child))
		child.connect("mouse_entered",Callable(self,"_on_modifier_mouse_enter").bind(child))
		child.connect("mouse_exited",Callable(self,"_on_modifier_mouse_exit").bind(child))
		child.button_pressed = Global.modifiers.get(child.name) # keep your modifiers
		child.modulate.a = .5
		if Global.modifiers[child.name] == true:
			child.button_pressed = true
			child.modulate.a = 1

func _on_modifier_menu_option_clicked(button : Button):
	if button.button_pressed:
		button.modulate.a = 1
	else:
		button.modulate.a = .5
	Global.modifiers.set(button.name, button.button_pressed)
	print(Global.modifiers)

func _on_modifier_mouse_enter(button: Button):
	text = button.display_text

func _on_modifier_mouse_exit(button: Button):
	text = "Modifiers"
