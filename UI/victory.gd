extends Node

var siner : float = 0

func _ready() -> void:
	if Global.player_save.flags["level_time"][Global.level-1] < Global.player_save.flags["best_time"][Global.level-1] or Global.player_save.flags["best_time"][Global.level-1] == -1:
		Global.player_save.flags["best_time"][Global.level-1] = Global.player_save.flags["level_time"][Global.level-1]
		$NewBest.visible = true
	
	$RichTextLabel.text = "Time: " + Global.get_time(Global.player_save.flags["level_time"][Global.level-1])
	Global.title_shown = false
	Global.player_save.flags["levels_beaten"][Global.level-1] = true
	if Global.level < 3 or Global.level > 5: #linear progression
		Global.player_save.flags["levels_unlocked"][min(Global.level,9)] = true
	if Global.level == 3: #unlocks the bonus levels
		Global.player_save.flags["levels_unlocked"][3] = true
		Global.player_save.flags["levels_unlocked"][4] = true
	elif Global.level > 3 and Global.player_save.flags["levels_beaten"][3] and Global.player_save.flags["levels_beaten"][4]: #unlocks DARK if both bonus levels beat
		Global.player_save.flags["levels_unlocked"][5] = true
	if Global.level >= 3 and Global.get_flag("option_skip_credits"):
		$DriveAgain.queue_free()
		$Quit.position.x = 108
		$Quit.start_pos.x = 108
	SaveLoad.file_save()

func _process(delta: float) -> void:
	siner += delta
	$Sprite2D.offset.y = Utility.get_sine(siner,1,10)

func option(opt: RichTextLabel) -> void:
	match opt.name:
		"DriveAgain":
			Global.level += 1
			Global.goto_storyscreen()
		
		"Quit":
			Global.goto_title()
