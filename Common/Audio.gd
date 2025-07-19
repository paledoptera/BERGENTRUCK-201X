extends Node

var music_player : AudioStreamPlayer
var music_position : Dictionary = {}
var music_fade_duration = 0.5
var music_track_name = ""
var sfx_player : Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)


func _process(_delta: float) -> void:
	if music_track_name in music_position:
		if music_player.has_stream_playback(): music_position[music_track_name] = music_player.get_playback_position()


#region Music
func play_music(audio : AudioStream, saved_pos := true, fadein := true):
	if audio == music_player.stream:
		return
	
	music_player.stop()
	
	var pos = 0.0
	music_track_name = audio.resource_path
	
	if saved_pos:
		if music_track_name not in music_position:
			music_position[music_track_name] = 0.0
		pos = music_position[music_track_name] 
	
	if fadein:
		music_player.volume_db = -40
		var tween = create_tween()
		tween.tween_property(music_player,'volume_db',0,music_fade_duration)
	else:
		music_player.volume_db = 0
	music_player.stream = audio
	music_player.play(pos)


func stop_music(fade := false):
	if fade:
		var tween = create_tween()
		tween.tween_property(music_player,'volume_db',-40,music_fade_duration)
		await tween.finished
		music_player.stop()
		music_player.stream = null
		return true
	else:
		music_player.stop()
		music_player.stream = null
		return true


func refresh_music_memory():
	music_position.clear()
#endregion


#region SFX
func play_sfx(sound: AudioStream, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	var pitch = pitch_scale 
	if pitch == 1.0:
		pitch *= randf_range(0.5,1.5)
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = sound
	player.pitch_scale = pitch
	player.volume_db = volume_db
	add_child(player)
	sfx_player.append(sound)
	player.finished.connect(_on_sound_timeout.bind(player))
	player.play()


func _on_sound_timeout(audio_player: AudioStreamPlayer) -> void:
	sfx_player.erase(audio_player)
	audio_player.finished.disconnect(_on_sound_timeout)
	audio_player.queue_free()
#endregion
