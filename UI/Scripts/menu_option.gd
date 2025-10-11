extends Control

signal menu_option_clicked(option: RichTextLabel)

@export var offset_on_cursor :=  Vector2(3,0)
@onready var start_pos = global_position

func _enter_tree() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _on_mouse_entered() -> void:
	Audio.play_sfx(preload("uid://bwrewdkj3pqlf"))
	var tween = create_tween()
	tween.tween_property(self,'global_position',start_pos+offset_on_cursor,0.05)


func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self,'global_position',start_pos,0.05)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				menu_option_clicked.emit(self)
