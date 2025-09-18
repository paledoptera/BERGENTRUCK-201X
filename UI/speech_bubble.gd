extends Sprite2D
class_name SpeechBubble

const SCENE: PackedScene = preload("uid://1nxnu6rfn7aw")

@export_multiline var text: String
@export var talksound: AudioStream
@export var delay: float = 0.0
var last_visible_characters: float = 0.0

static func new(text: String, talksound: AudioStream, global_position: Vector2, delay: float = 0.0) -> SpeechBubble:
	var new_dialogue: SpeechBubble = SCENE.instantiate()
	new_dialogue.text = text
	new_dialogue.talksound = talksound
	new_dialogue.delay = delay
	new_dialogue.global_position = global_position
	return new_dialogue

func _ready() -> void:
	visible = false
	$RichTextLabel.text = text
	$RichTextLabel.visible_ratio = 0.0
	if !delay:
		_on_timer_timeout()
		return
	$Timer.start(delay)
	


func _physics_process(delta: float) -> void:
	if floor(last_visible_characters) < floor($RichTextLabel.visible_characters):
		last_visible_characters = floor($RichTextLabel.visible_characters) 
		Audio.play_sfx(talksound,randf_range(0.95,1.05))


func _on_timer_timeout() -> void:
	modulate = Color("ffffff00")
	$AnimationPlayer.play("textbox")
	visible = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
