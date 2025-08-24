extends Entity

const ATTACK = ["pipis", "slashes_stars", "mail", "swords_wall"] #"swords_corridor"]

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
var current_attack_small: String
var current_attack_mega: String
var attack_pool : Array[String]
var previous_attack_pool : Array[String]
@export var keeping_up_with_player = true
@export var entities : Node3D
@export var sprite : AnimatedSprite3D
@export var ai_timer : Timer
@export var ai_anim : AnimationPlayer
var shake: float = 0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	shake = .2
	await $AnimationPlayer.animation_finished
	idleanimation(true)
	#Global.score = 46

func _process(delta: float) -> void:
	if shake != 0:
		for node in get_tree().get_nodes_in_group("shake"):
			node.position += Vector3(randf_range(-shake,shake),(randf_range(-shake,shake)),0)
	siner += delta
	
	speed = lerp(speed,-player.speed,.1)
	global_position.x = lerp(global_position.x,player.get_node("Camera3D").global_position.x,.9)
	global_rotation.x += deg_to_rad(speed)
	global_rotation.x = clamp(global_rotation.x,deg_to_rad(-35),deg_to_rad(12))


func hit(player) -> void:
	#if player.gear < 3:
	#	Global.score += randf_range(-1.0,-5.0)
	#Global.score += randf_range(0.0,4.0)
	#Global.score += 5
	#if Global.score >= Global.goal:
	#	$Timer.stop()
	#player.screenshake_strength += 40
	#player.particle_trigger(particle_effect)
	#$AIState.send_event("Hit")
	disable_collision()


#region - KNIGHT AI // SLASH PATTERN
func _start_enter() -> void:
	keeping_up_with_player = true
	attacks_used = 0
	$EntityContainer/CollisionShape3D.disabled = false
	ai_timer.start(2.0)


func _start_process(delta: float) -> void:
	horizontal_speed = lerp(horizontal_speed,0.2,0.2)
	speed = -player.speed
	sprite.position.y = 0.5+Utility.get_sine(siner,0.5,5.0)


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
		match current_attack:
			"pipis":
				current_attack_small = "pipis"
				current_attack_mega = "big_slash_bullets"
				max_attacks_used = 3
		
			"slashes_stars":
				current_attack_small = "big_slash_bullets"
				current_attack_mega = "big_slash_bullets"
				max_attacks_used = 1
			
			"mail":
				current_attack_small = "mailwall"
				current_attack_mega = "mailwall"
				print("HA")
				max_attacks_used = 4
			
			"swords_wall":
				current_attack = ""
				current_attack_small = "big_sword_wall"
				current_attack_mega = "big_sword_wall"
				max_attacks_used = 1
	
	
	if sword_dir:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	
	var attack_anim = current_attack_mega if attacks_used >= max_attacks_used else current_attack_small
	
	ai_anim.play(attack_anim)
	ai_timer.start(ai_anim.current_animation_length)


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


func _end_enter() -> void:
	current_attack = ""
	ai_anim.play("vulnerable")
	ai_timer.start(2.0)


func _end_process(delta) -> void:
	speed = lerp(speed,0.0,0.04)


func _hit_enter() -> void:
	ai_timer.stop()
	keeping_up_with_player = true
	ai_anim.play("hit")
	ai_timer.start(0.5)
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

func heart_attack():
	var bullet_inst = preload("res://Entities/spamton_heart.tscn").instantiate()
	bullet_inst.bullet_owner = self
	bullet_inst.player = player
	add_child(bullet_inst)
	#bullet_inst.global_position = $EntityContainer/Sprite3D.global_position
	bullet_inst.global_rotation.x = global_rotation.x

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
	$EntityContainer/CollisionShape3D.disabled = true


func play_sound(audio: AudioStream, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	Audio.play_sfx(audio, pitch_scale, volume_db)


func _get_current_attack_pool() -> void:
	var current_attack_num = Global.score / 10
	current_attack_num = clamp(int(current_attack_num),0,ATTACK.size()-1)
	attack_pool.clear()
	for i in range(current_attack_num+1):
		attack_pool.append(ATTACK[i])


func _on_afterimage_timer_timeout() -> void:
	var afterimage = preload("uid://cgwpbuermixlc").instantiate() # afterimage.tscn
	get_parent().add_child(afterimage)
	afterimage.global_position = $EntityContainer/AnimatedSprite3D.global_position
	afterimage.global_rotation = $EntityContainer/AnimatedSprite3D.global_rotation
	afterimage.sprite_frames =  $EntityContainer/AnimatedSprite3D.sprite_frames
	afterimage.animation =  $EntityContainer/AnimatedSprite3D.animation
	afterimage.frame =  $EntityContainer/AnimatedSprite3D.frame
	afterimage.flip_h =  $EntityContainer/AnimatedSprite3D.flip_h


func _on_hurtbox_area_entered(area):
	area.get_parent().queue_free()
	idleanimation(false)
	$AnimationPlayer.play("hit")
	Global.score += 6
	player.screenshake_strength += 10
	player.particle_trigger(particle_effect)
	Audio.play_sfx(preload("res://Global/SFX/Small Item Hit 3.wav"),1,10)
	shake = 1
	await get_tree().create_timer(.2).timeout
	shake = 0
	idleanimation(true)

func idleanimation(begin:bool):
	if begin:
		$AudioStreamPlayer.stop()
		for node in get_tree().get_nodes_in_group("stop"):
			node.play("loop")
		$EntityContainer/Head.play("idle")
	else:
		for node in get_tree().get_nodes_in_group("stop"):
			node.stop(false)
