@icon("uid://cucobdmil4ama") #ui_toolbar.png
class_name PlayerSave
extends Resource

var time = 0

@export var flags = {
	"first_play": true,
	"levels_unlocked" : [true,false,false,false,false,false,false,false,false,false],
	"levels_beaten" : [false,false,false,false,false,false,false,false,false,false],
	"levels_mastered" : [false,false,false,false,false,false,false,false,false,false], #LEVELS BEATEN W/ ALL MODIFIERS AT SAME TIME
	"level_beaten_modifiers": [[],[],[],[],[],[],[],[],[],[]],
	"level_time": [0,0,0,0,0,0,0,0,0,0],
	"best_time": [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
	"option_show_time": false,
	"option_skip_tutorials": false,
	"option_skip_credits": false,
	"option_master_vol": 1.0,
	"option_music_vol": 1.0,
	"option_sound_vol": 1.0,
	"border" : 1,
	"current_skin_id": 0,
	"skins_unlocked": [true,false,false,false,false,false,false,false,false,false,false,false,false]
}

func update_level_time(delta: float, level: int = 1):
	time += 1*delta
	flags["level_time"][level-1] = time
