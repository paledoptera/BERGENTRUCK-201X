extends "res://Entities/spamton_pipis.gd"
class_name QueenBall

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	speed = -10
	var tween = create_tween()
	tween.tween_property($EntityContainer/Sprite3D4,"modulate",Color("ffffff",0.0),0.3)
	tween.tween_property($EntityContainer/Sprite3D4,"modulate",Color("ffffff",1.0),0.3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$EntityContainer/Sprite3D4.global_position.y -= 0.05
	$EntityContainer/Sprite3D4.pixel_size += 0.001
	$EntityContainer/Sprite3D4.rotation.z -= 0.03
	super(delta)
	$EntityContainer.global_position.z -= 0.05
	$EntityContainer.global_position.x = lerp($EntityContainer.global_position.x,player.get_node("Camera3D").global_position.x-0.35,0.1)
	$EntityContainer.position.y = lerp($EntityContainer.position.y,21.361,0.05)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

func deflect() -> void:
	var tween = create_tween()
	tween.tween_property($EntityContainer/Sprite3D4,"modulate",Color("ffffff",0.0),0.1)
	player.screenshake_strength += 10
	Audio.play_sfx(preload("uid://bpmsky0fvrfbm"))
	Audio.play_sfx(preload("uid://bt8ccvfxai2hr"))
	$EntityContainer/CollisionShape3D.queue_free()
	anim.play("deflect")
