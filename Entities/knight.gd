extends Entity

const ATTACKS = ["small_slash_rude"]
const HEAVY_ATTACKS = ["big_slash_bullets"]

@export var player : Node
var speed = 0.0
var horizontal_speed = 0.0
var speed_acc = 0.1
var siner = 0
var attacks_used = 0
var sword_dir = false # false = right, true = left
var vulnerable = false
@export var keeping_up_with_player = true
@export var entities : Node3D
@export var sprite : AnimatedSprite3D
@export var ai_timer : Timer
@export var ai_anim : AnimationPlayer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	siner += delta
	
	if keeping_up_with_player:
		speed = lerp(speed,-player.speed,0.1)
	
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,horizontal_speed)
	global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-30),deg_to_rad(12))

	#if speed_acc < 0.1:
		#speed_acc *= 1.01


func hit(player) -> void:
	$AIState.send_event("Hit")
	$EntityContainer/CollisionShape3D.disabled = true
	
	pass
	#global_rotation.x -= deg_to_rad(2)
	#speed = -2.5
	#speed_acc = 0.0001



#region - KNIGHT AI
func _start_enter() -> void:
	keeping_up_with_player = true
	attacks_used = 0
	$EntityContainer/CollisionShape3D.disabled = false
	#speed = -2.5
	ai_timer.start(2.0)
	ai_anim.queue("idle")


func _start_process(delta: float) -> void:
	horizontal_speed = lerp(horizontal_speed,0.2,0.2)
	speed = -player.speed
	sprite.position.y = 0.5+Utility.get_sine(siner,0.5,5.0)


func _attack_enter() -> void:
	if sword_dir:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	ai_anim.play(ATTACKS.pick_random())
	ai_timer.start(0.3)


func _attack_process(delta) -> void:
	pass


func _attack_exit() -> void:
	attacks_used += 1


func _break_enter() -> void:
	#ai_anim.play("break")
	speed = -2.0
	ai_timer.start(0.2)

func _break_process(delta) -> void:
	horizontal_speed = lerp(horizontal_speed,0.2,0.1)


func _break_exit() -> void:
	sprite.flip_h = false


func _mega_attack_enter() -> void:
	if sword_dir:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	ai_anim.play(HEAVY_ATTACKS.pick_random())
	ai_timer.start(1.0)

func _end_enter() -> void:
	ai_anim.play("vulnerable")
	#ai_anim.queue("ball")
	ai_timer.start(2.5)

func _end_process(delta) -> void:
	speed = lerp(speed,0.0,0.035)


func _hit_enter() -> void:
	ai_timer.stop()
	keeping_up_with_player = true
	ai_anim.play("hit")
	ai_timer.start(0.5)





#endregion



func _on_timer_timeout() -> void:
	if attacks_used >= 3:
		attacks_used = 0
		$AIState.send_event("MegaAttack")
	else:
		$AIState.send_event("Progress")


func swap_sword_dir() -> void:
	sword_dir = not sword_dir

func change_speed(value : float):
	speed = value

func change_horizontal_speed(value : float):
	horizontal_speed = value

func spawn_bullet(bullet : PackedScene, spd_mult : float = 1.0, h_spd : float = 0):
	var bullet_inst = bullet.instantiate()
	entities.add_child(bullet_inst)
	bullet_inst.speed = player.speed / spd_mult
	bullet_inst.h_speed = h_spd
	bullet_inst.bullet_owner = self
	bullet_inst.global_position.x = global_position.x
	bullet_inst.global_rotation.x = global_rotation.x
