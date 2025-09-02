extends Entity

const ATTACK_POOL = {
	"round1":
		{
			0: ["laser"], #["punch"],
			1: ["kick", "punch"],
			2: ["baseball_throw","punch","kick","punch","kick"],
		},
	
	"round2":
		{
			0: ["kick_double","punch","kick"],
			1: ["laser", "kick_double","laser","laser","punch","baseball_throw"],
		},
	
	"round3":
		{
			0: ["laser_double", "kick", "punch", "laser"],
			1: ["waves_of_queen","kick_double","punch","laser"],
			2: ["giant_baseball_toss","kick_double","laser_double"]
		},
	
	}

@export var player : Node
var speed = 0.0
var horizontal_speed = 0.0
var speed_acc = 0.1
var siner = 0
var attacks_used = 0
var max_attacks_used = 0
var vulnerable = false
var current_attack: String
var last_attack: String
var current_attack_small: Array
var current_attack_mega: String
@onready var attack_pool : Array
var previous_attack_pool : Array
@export var keeping_up_with_player = true
@export var entities : Node3D
@export var sprite : AnimatedSprite3D
@export var ai_timer : Timer
@export var ai_anim : AnimationPlayer
var attack_cooldown: float = 0
var current_player_speed: float = 1
var dir = "left"


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	#print("SCORE: ", Global.score)
	
	siner += delta*(0.66+(float(player.gear)/2.5))
	
	if keeping_up_with_player:
		speed = lerp(speed,-player.speed,0.1)
	
	
	var gear_dif = float(player.speed) - current_player_speed
	current_player_speed = lerp(current_player_speed,float(player.speed),0.1)
	#var dist = global_rotation.x+deg_to_rad(35)
	if gear_dif < 0:
		gear_dif *= 3.5
	if $AnimationPlayer.current_animation == "punch_left" or $AnimationPlayer.current_animation == "punch_right":
		current_player_speed = lerp(current_player_speed,float(player.speed),0.3)
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,horizontal_speed*delta)
	global_position.z = gear_dif*3
	
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
	#ai_anim.queue("idle")


func _start_process(delta: float) -> void:
	speed = -player.speed
	
	#
	#var current_y = Utility.get_sine(siner,1.0,7.0)
	#var next_y = Utility.get_sine(siner+delta,1.0,7.0)
	#if sign(current_y) != sign(next_y) and $EntityContainer/AnimatedSprite3D.animation == "idle":
		#sprite.frame = wrap(sprite.frame+1,0,2)
	
	horizontal_speed = 2#abs(current_y)*2
	sprite.position.z = lerp(sprite.position.z,0.0,0.2)
	#sprite.position.y = lerp(sprite.position.y,-2.0+abs(current_y),0.2)

func _attack_enter() -> void:
	horizontal_speed = 1#abs(current_y)*2
	_get_current_attack_pool()
	print(attack_pool)
	if previous_attack_pool != attack_pool.duplicate():
		print("NEW ATTACK")
		previous_attack_pool.clear()
		previous_attack_pool = attack_pool.duplicate()
		current_attack = attack_pool.front()
	else:
		if last_attack and attack_pool.size() > 1:
			attack_pool.erase(last_attack)
			
		current_attack = attack_pool.pick_random()
	last_attack = current_attack
	print(current_attack)
		
	
	match current_attack:
		"punch", "kick", "kick_double":
			current_attack += ("_" + dir)
	
	ai_anim.play(current_attack)
	ai_timer.start(ai_anim.current_animation_length)


func _attack_process(delta) -> void:
	pass


func _attack_exit() -> void:
	attacks_used += 1
#endregion


#func _on_timer_timeout() -> void:
	#if $AnimationPlayer.is_playing():
		#match $AnimationPlayer.current_animation:
			#"idle":
				#pass
			#"hit_left", "hit_right":
				#await $AnimationPlayer.animation_changed
				#sprite.position.z = 0.0
				#siner = 0.0
			#"punch_left", "punch_right":
				#await $AnimationPlayer.animation_finished
				#sprite.animation = "idle"
				#sprite.flip_h = not sprite.flip_h
				#sprite.offset = Vector2(-7,40)
				#if sprite.flip_h: sprite.offset.x *= -1
				#sprite.position.z = 0.0
				#siner = 0.0
			#_:
				#await $AnimationPlayer.animation_finished
	#$AIState.send_event("Progress")


func change_speed(value : float):
	speed = value


func change_horizontal_speed(value : float):
	horizontal_speed = value


func spawn_bullet(bullet : PackedScene, spd_mult : float = 1.0, h_spd : float = 0):
	var bullet_inst = bullet.instantiate()
	entities.add_child(bullet_inst)
	bullet_inst.speed = bullet_inst.speed * spd_mult
	bullet_inst.h_speed = h_spd
	bullet_inst.bullet_owner = self
	bullet_inst.global_position.x = sprite.global_position.x+1
	bullet_inst.global_rotation.x = global_rotation.x
	if bullet_inst is QueenBall:
		bullet_inst.speed = player.speed * spd_mult
		bullet_inst.entity_container.position.y = (sprite.position.y*2)
		bullet_inst.global_position.x = sprite.global_position.x+6.5
		bullet_inst.global_rotation.x = global_rotation.x
	
	bullet_inst.player = player


func disable_collision() -> void:
	pass
	#$EntityContainer/CollisionShape3D.disabled = true


func play_sound(audio: AudioStream, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	Audio.play_sfx(audio, pitch_scale, volume_db)


func _get_current_attack_pool() -> void:
	print("SCORE: ", Global.score)
	attack_pool.clear()
	
	if Global.score < 10.0:
		attack_pool = ATTACK_POOL["round1"][0].duplicate()
	elif Global.score < 20.0: 
		attack_pool = ATTACK_POOL["round1"][1].duplicate()
	elif Global.score < 33.0:
		attack_pool = ATTACK_POOL["round1"][2].duplicate()
	elif Global.score < 40.0:
		attack_pool = ATTACK_POOL["round2"][0].duplicate()
	elif Global.score < 66.0:
		attack_pool = ATTACK_POOL["round2"][1].duplicate()
	elif Global.score < 70.0:
		attack_pool = ATTACK_POOL["round3"][0].duplicate()
	elif Global.score < 85.0:
		attack_pool = ATTACK_POOL["round3"][1].duplicate()
	else:
		attack_pool = ATTACK_POOL["round3"][2].duplicate()

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


func _animation_finished(anim_name: StringName) -> void:
	
	match anim_name:
		"hit_left", "kick_right", "hit_drunk_left":
			$AnimationPlayer.play("idle_right")
		
		"hit_right", "kick_left", "hit_drunk_right":
			$AnimationPlayer.play("idle_left")
		
		"punch_left":
			$AnimationPlayer.play("idle_right")
		
		"punch_right":
			$AnimationPlayer.play("idle_left")
		
		
		"baseball_throw":
			if player.baseball_hit:
				player.baseball_hit = false
				$AnimationPlayer.play("baseball_after_hit")
			else:
				$AnimationPlayer.play("baseball_after_miss")
			$AnimationPlayer.queue("idle_right")
		
	
	if ai_timer.is_stopped():
		$AIState.send_event("Progress")
		return
	
	match anim_name:
		
		"idle_left", "idle_right":
			dir = ["left","right"].pick_random()
			$AnimationPlayer.play("idle_" + dir)

		
		#_:
			#await $AnimationPlayer.animation_finished
	
