extends MeshInstance3D
class_name SpeechBubble3D


@export_multiline var text: String
@export var talksound: AudioStream
@export var delay: float = 0.0

func _enter_tree() -> void:
	var txt = $SubViewport/SpeechBubble
	txt.text = text
	txt.talksound = talksound
	txt.delay = delay
