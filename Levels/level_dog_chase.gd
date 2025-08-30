extends Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_sfx(preload("uid://cphvgk1cwgtnj"),0.99) # Car Start.wav
	var tween = create_tween()
	tween.tween_property($FadeEffect,'global_position',Vector2(-104,-48),1.5)
	tween.tween_callback(start_music)
	tween.tween_property($FadeEffect,'modulate',Color("ffffff00"),3.0)
	tween.tween_callback(fade_in_done)
	
	Global.level = level_val
	if Global.modifiers.Drain:
		drain_timer = Timer.new()
		add_child(drain_timer)
		drain_timer.start(drain_interval)
		drain_timer.connect("timeout",Callable(self,"drain"))
	for node in $"Progress Points".get_children():
		node.add_to_group("progress_point")

func _process(delta: float) -> void:
	
	if Global.game:
		if Global.border == 1: #dynamic border
			Global.game.border.self_modulate = Color("ffffff",1.0-$FadeEffect.modulate.a)
			Global.game.border.self_modulate += Color("ffffff")*($FlashEffect.modulate.a*3)
		else:
			Global.game.border.self_modulate = Color("ffffff",1.0)
	
	if player.hp <= 0:
		Global.die()
		return
	elif Global.score >= Global.goal and not win:
		win = true
		Audio.stop_music(true)
		var tween = create_tween()
		tween.tween_property($FadeEffect,'modulate',Color("ffffff"),3.0)
		tween.tween_callback(win_level)
