extends Node

const SAVELOCATION := "user://save.tres"
var save_file_data: PlayerSave


func file_save():
	save_file_data = Global.player_save
	ResourceSaver.save(save_file_data, SAVELOCATION)
	print("SAVE: Saved player file in", OS.get_user_data_dir())

func file_load():
	if has_save_data:
		print("SAVE: Loaded player file from", OS.get_user_data_dir())
		save_file_data = ResourceLoader.load(SAVELOCATION)#.duplicate(true)
		return save_file_data
	else:
		#print("SAVE: No player file found in", OS.get_user_data_dir()) 
		return false

func file_erase():
	if FileAccess.file_exists(SAVELOCATION):
		var dir = DirAccess.open("user://")
		dir.remove(SAVELOCATION)
		print("SAVE: Erased player file from", OS.get_data_dir()) 
	else:
		save_file_data = null
		print("SAVE: No player file found in", OS.get_data_dir()) 
		return false

func has_save_data() -> bool:
	if FileAccess.file_exists(SAVELOCATION):
		return true
	else:
		return false
