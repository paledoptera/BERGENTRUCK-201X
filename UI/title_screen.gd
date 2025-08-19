extends Node

var siner: float = 0
var siner2: float = 0
var logo_bobbing = false

func _ready() -> void:
	if not Global.title_shown:
		Global.title_shown = true
		$AnimationPlayer.play("intro")
	else:
		$ColorRect.modulate = Color("ffffff00")
		logo_bobbing = true

func _process(delta: float) -> void:
	siner2 += delta
	$Sprite2D.offset.y = Utility.get_sine(siner2,1,20)
	$Background.offset = Vector2(Utility.get_sine(siner2,1,5),Utility.get_sine(siner2,1,10))
	
	if Input.is_action_just_pressed("click"):
		$AnimationPlayer.speed_scale = 100
	
	if logo_bobbing:
		siner += delta
		$Logo.position.y = 29 + Utility.get_sine(siner,2,2)
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	logo_bobbing = true
	Global.game.update_dynamic_border()


func _on_menu_option_clicked(option: RichTextLabel) -> void:
	match option.name:
		"Play":
			Global.goto_levelselect()
		
		"Options":
			Global.goto_options()
			
		"Quit":
			get_tree().quit()
