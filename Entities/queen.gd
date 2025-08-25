extends Entity

const ATTACK = ["punch", "kick"] #"baseball_toss", "double_kick", "laser", "fast_kicks", "waves_of_queen"] #

@export var player : Node
var speed = 0.0
var horizontal_speed = 0.0
var speed_acc = 0.1
var siner = 0
var attacks_used = 0
var max_attacks_used = 0
var sword_dir = false # false = right, true = left
var vulnerable = false
var current_attack: String
var last_attack: String
var current_attack_small: Array
var current_attack_mega: String
var attack_pool : Array[String]
var previous_attack_pool : Array[String]
@export var keeping_up_with_player = true
@export var entities : Node3D
@export var sprite : AnimatedSprite3D
@export var ai_timer : Timer
@export var ai_anim : AnimationPlayer
var attack_cooldown: float = 0
var current_player_speed: float = 1


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	siner += delta*(0.66+(float(player.gear)/2.5))
	
	if keeping_up_with_player:
		speed = lerp(speed,-player.speed,0.1)
	
	
	var gear_dif = float(player.speed) - current_player_speed
	current_player_speed = lerp(current_player_speed,float(player.speed),0.1)
	#var dist = global_rotation.x+deg_to_rad(35)
	if gear_dif < 0:
		gear_dif *= 3.5
	#if $AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == "punch":
		#current_player_speed = lerp(current_player_speed,float(player.speed),0.5)
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,horizontal_speed*delta)
	global_position.z = lerp(global_position.z,gear_dif*3,0.1)
	
	#global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-35),deg_to_rad(-3))


func hit(player) -> void:
	Audio.play_sfx(hit_sound_impact)
	Global.score += 1
	if Global.score >= Global.goal:
		$Timer.stop()
	player.screenshake_strength += 10
	player.particle_trigger(particle_effect)
	
	keeping_up_with_player = true
	#ai_anim.play("hit")
	
	
	disable_collision()


#region - KNIGHT AI // SLASH PATTERN
func _start_enter() -> void:
	var tween = player.create_tween()
	tween.set_parallel(true)
	tween.tween_property(player.get_node("Camera3D"),"size",.01,2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	keeping_up_with_player = true
	attacks_used = 0
	$EntityContainer/CollisionShape3D.disabled = false
	ai_timer.start(2.0)
	ai_anim.queue("idle")


func _start_process(delta: float) -> void:
	speed = -player.speed
	
	
	var current_y = Utility.get_sine(siner,1.0,7.0)
	var next_y = Utility.get_sine(siner+delta,1.0,7.0)
	if sign(current_y) != sign(next_y) and $EntityContainer/AnimatedSprite3D.animation == "idle":
		sprite.frame = wrap(sprite.frame+1,0,2)
	
	horizontal_speed = abs(current_y)*2
	sprite.position.z = lerp(sprite.position.z,0.0,0.2)
	sprite.position.y = -2.0+abs(current_y)

func _attack_enter() -> void:
	_get_current_attack_pool()
	
	if not current_attack:
		print(attack_pool)
		if previous_attack_pool != attack_pool.duplicate():
			print("NEW ATTACK")
			previous_attack_pool.clear()
			previous_attack_pool = attack_pool.duplicate()
			current_attack = attack_pool.back()
		else:
			if last_attack and attack_pool.size() > 1:
				attack_pool.erase(last_attack)
			
			if previous_attack_pool != attack_pool:
				attack_pool.append
				
			current_attack = attack_pool.pick_random()
		last_attack = current_attack
		print(current_attack)
		
	
	var attack_anim = ATTACK.pick_random()
	
	ai_anim.play(attack_anim)
	ai_timer.start(ai_anim.current_animation_length)


func _attack_process(delta) -> void:
	pass


func _attack_exit() -> void:
	attacks_used += 1


func _break_enter() -> void:
	ai_anim.play("idle")
	ai_timer.start(1.5)


func _end_process(delta) -> void:
	speed = lerp(speed,0.0,0.04)
#endregion


func _on_timer_timeout() -> void:
	if attacks_used > max_attacks_used:
		attacks_used = 0
		$AIState.send_event("End")
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
	bullet_inst.speed = player.speed * spd_mult
	bullet_inst.h_speed = h_spd
	bullet_inst.bullet_owner = self
	bullet_inst.global_position.x = global_position.x
	bullet_inst.global_rotation.x = global_rotation.x
	bullet_inst.player = player


func disable_collision() -> void:
	pass
	#$EntityContainer/CollisionShape3D.disabled = true


func play_sound(audio: AudioStream, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	Audio.play_sfx(audio, pitch_scale, volume_db)


func _get_current_attack_pool() -> void:
	var current_attack_num = Global.score / 18
	current_attack_num = clamp(int(current_attack_num),0,ATTACK.size()-1)
	attack_pool.clear()
	for i in range(current_attack_num+1):
		attack_pool.append(ATTACK[i])

#
#func _on_afterimage_timer_timeout() -> void:
	#var afterimage = preload("uid://cgwpbuermixlc").instantiate() # afterimage.tscn
	#get_parent().add_child(afterimage)
	#afterimage.global_position = $EntityContainer/AnimatedSprite3D.global_position
	#afterimage.global_rotation = $EntityContainer/AnimatedSprite3D.global_rotation
	#afterimage.sprite_frames =  $EntityContainer/AnimatedSprite3D.sprite_frames
	#afterimage.animation =  $EntityContainer/AnimatedSprite3D.animation
	#afterimage.frame =  $EntityContainer/AnimatedSprite3D.frame
	#afterimage.flip_h =  $EntityContainer/AnimatedSprite3D.flip_h
