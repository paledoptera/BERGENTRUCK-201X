extends AnimatedSprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self,'modulate',Color("ffffff00"),0.4)
	tween.tween_callback(queue_free)
