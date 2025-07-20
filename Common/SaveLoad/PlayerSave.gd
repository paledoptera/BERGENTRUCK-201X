@icon("uid://cucobdmil4ama") #ui_toolbar.png
class_name PlayerSave
extends Resource

var levels_unlocked = [true,true,true]
var levels_beaten = [false,false,false]
var best_times = [0,0,0]

@export var flags = {
	"game_completed" : false,
}
