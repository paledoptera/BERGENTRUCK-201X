extends "player.gd"

var rotation_offset = 0.0
var reverse = Vector3(1,0,1)


func _ready() -> void:
	Global.player_save.time = 0
	if Global.modifiers.NoSlow:
		$Visuals/WidgetGear/DraggableItem/CollisionShape2D.disabled = true
	if Global.modifiers.FragileCar:
		max_hp = 50
		hp = 50
	if Global.modifiers.DrunkMode:
		_spawn_item(preload("res://Items/item_beer.tscn"))
		$DrunkTimer.start(2)
		$Visuals/BeerProgress.show()
	#_correct_sprite_size($Ground)
	skin_change()
	$CarEngine.volume_db = -40
	$CarEngine.play(0.0)
	var tween = create_tween()
	tween.tween_property($CarEngine,'volume_db',0,3.0)

func _physics_process(delta: float) -> void:
	if Global.player_save.flags["option_show_time"]:
		$Visuals/Time.visible = true
	else:
		$Visuals/Time.visible = false
	Global.player_save.update_level_time(delta,Global.level)
	$Visuals/Time.text = "Time: " + Global.get_time(Global.player_save.flags["level_time"][Global.level-1])
	last_velocity = car_velocity
	car_velocity.z = -lerp(car_velocity.z,(speed),friction)
	#position -= Vector3(car_velocity.x,0,car_velocity.z).rotated(Vector3.UP, rotation.y)*40*Vector3(reverse.x,0,reverse.z)*delta #move forward
	if is_on_floor():
		rotation.y -= widget_wheel.value.x*delta #turn
	reverse = reverse.move_toward(Vector3(1,0,1),delta)
	car_velocity.x = move_toward(car_velocity.x,0,delta*gear)
	velocity = Vector3(car_velocity.x,0,car_velocity.z).rotated(Vector3.UP, rotation.y)*40*Vector3(reverse.x,0,reverse.z)
	velocity.y = car_velocity.y*200
	print(car_velocity.y)
	move_and_slide()
	#if friction < 0.3:
		#$CarScreech.play()
	#else:
		#screeching = false
		#$CarScreech.stop()
	var last_angle = car_angle.x
	
	
	_gear_mechanics()
	
	speed = lerp(speed,float(gear*3.34),friction*delta)
	
	_steering_mechanics()
	_hand_visuals()
	_gravity_mechanics(delta)
	_items_in_face()
	$Camera2D.offset=_get_shake(delta)
	
	$Visuals/Parallax2D.scroll_offset.x = car_position.x
	
	if last_angle != car_angle.x:
		var difference = abs(car_angle.x - last_angle)
		friction -= (difference*0.7)
		visuals_angle = (car_angle.x - last_angle)
		visuals_angle = clamp(visuals_angle,-0.1,0.1)
	else:
		visuals_angle *= 0.95
	
	visuals_angle += (noise.get_noise_2d(1,noise_i) * screenshake_strength)/100
	
	$Visuals/HealthBar/Dial.rotation_degrees = lerp($Visuals/HealthBar/Dial.rotation_degrees,((max_hp/2-hp)/max_hp)*90.0,0.2)
	$Visuals/ProgressBar/Dial.rotation_degrees = lerp($Visuals/ProgressBar/Dial.rotation_degrees,-225.0+(Global.score/Global.goal)*90.0,0.2)
	var dial_rand_jitter = randf_range(-5,5)
	$Visuals/SpeedBar/Dial.rotation_degrees = lerp($Visuals/SpeedBar/Dial.rotation_degrees,-195+dial_rand_jitter+(speed/10)*200,0.2)
	$DamageSplash.self_modulate.a = lerp($DamageSplash.self_modulate.a,0.0,0.05)
	
	#$Camera3D.position.x = lerp($Camera3D.position.x,car_position.x+10,5*delta)
	#$Camera3D.frustum_offset.x = lerp($Camera3D.frustum_offset.x,(car_angle.x/500),0.1)
	$Visuals.rotation = lerp($Visuals.rotation,visuals_angle*0.6,0.45)
	$Visuals.global_position.x = lerp($Visuals.global_position.x,(160+(visuals_angle*100)+((-visuals_angle*200)))+(car_shake.x),0.8)
	$Visuals.global_position.y = lerp($Visuals.global_position.y,130+(car_velocity.y*30),0.4)
	$Visuals.skew = ((-visuals_angle)*(1-friction))/2
	visual_asgore.position.x = lerp(visual_asgore.position.x,-210+(visuals_angle*100)+((-visuals_angle*200)*(1-friction)),0.3)
	visual_asgore.position.y = lerp(visual_asgore.position.y,-127+((hand.position.y)/50),0.2)
	


func _hand_visuals() -> void:
	if Input.is_action_pressed("click"):
		hand.frame = 1
		$Visuals/Hand/RigidBody2D/CollisionShape2D.disabled = false
	else:
		hand.frame = 0
		$Visuals/Hand/RigidBody2D/CollisionShape2D.disabled = true
	
	
	$Visuals/Hand/RigidBody2D.global_position = $Visuals/Hand.global_position
	
	var wheel_dragpoint = widget_wheel.get_node("DraggableItem")
	var gearbox_dragpoint = widget_gear.get_node("DraggableItem")
	var upperarm: Sprite2D = hand.get_node("Forearm/UpperArm")
	upperarm.look_at($Visuals/Asgore.global_position+Vector2(150,400))
	
	if wheel_dragpoint.drag:
		if not hand_on_wheel:
			hand_on_wheel = true
			Audio.play_sfx(preload("uid://bigavjv4ovlma"),1.0,-3)
		wheel_dragpoint.drag_speed = friction*0.1
		wheel_dragpoint.global_position = visual_wheel.global_position+visual_wheel.global_position.direction_to(wheel_dragpoint.global_position)*67
		hand.global_position = lerp(hand.global_position,wheel_dragpoint.global_position,0.7)
		hand.rotation = lerp_angle(hand.rotation,(visual_wheel.rotation*0.3) - 0.4,0.7)
	elif gearbox_dragpoint.drag:
		hand_on_wheel = false
		hand.global_position = visual_gear.global_position
		hand.rotation = visual_gear.rotation*1.5
		hand.global_position.y -= 65
		hand.global_position.x += (widget_gear.value-0.5)*50
	else:
		hand_on_wheel = false
		var mouse_pos = hand.get_global_mouse_position()
		mouse_pos = mouse_pos.clamp(Vector2(0,0),hand.get_viewport_rect().size)
		hand.global_position = lerp(hand.global_position,mouse_pos,0.9)
		hand.rotation = (-200+mouse_pos.x)/320


func _gear_mechanics() -> void:
	var last_gear = gear
	
	var gear_value = widget_gear.value
	if Global.modifiers.NoSlow == true:
		gear_value = 1
	gear = round(gear_value*2)+1
	
	if last_gear != gear:
		var tween = create_tween()
		tween.tween_property($CarEngine,'pitch_scale',gear,2.0)
		
		#var gear_change_sound = preload("uid://cf8yyq2r0tegw") if last_gear < gear else preload("uid://f4pdbbpsxjgt")
		#var gear_sound_val = float(gear)/10
		Audio.play_sfx(preload("uid://qbs4qdc8hem8"),1.01)
		#Audio.play_sfx(gear_change_sound,0.62+gear_sound_val,-13)
		screenshake_strength += 2
	
	if widget_gear.get_node("DraggableItem").drag:
		visual_gear.position.x = 95 + (gear_value-0.5)*30
		visual_gear.rotation_degrees = (gear_value-0.5)*50
	else:
		visual_gear.position.x = 95 + (gear-2)*15
		visual_gear.rotation_degrees = (gear-2)*25

func _steering_mechanics() -> void:
	
	steer_wiggle = randf_range(-speed*2,speed*2)
	turn_angle.x = widget_wheel.value.x
	if Global.modifiers.DrunkMode:
		$Visuals/BeerProgress.value = 100 - drunkness
		turn_angle.x += turn_angle.x*drunkness/50
	turn_angle.y = 1+(widget_wheel.value.y*0.5)
	turn_speed = turn_angle.x * turn_angle.y
	turn_speed = clamp(turn_speed,-1,1)
	visual_wheel.rotation_degrees = (turn_speed*90)
	turn_speed *= (speed/2)*(2-friction)
	friction = clamp(float(friction), 0.0, 1.0)
	friction = lerp(float(friction),1.0,0.1*(0.5+(0.5-(speed/20))))
	
	#car_velocity.x = lerp(car_velocity.x,car_angle.x,friction)
	#if Global.modifiers.DrunkMode:
	#	car_velocity.x += sin(drunk_steer+.24)*drunkness/180#+1
	
	
#
#func _physics_process(delta: float) -> void:
#
	#if Input.is_action_pressed("click"):
		#$Visuals/Hand.frame = 1
	#else:
		#$Visuals/Hand.frame = 0
	#
	#siner += delta
	#turn_angle.x = widget_wheel.value.x
	#turn_angle.y = 1+(widget_wheel.value.y*0.5)
	#turn_speed = turn_angle.x * turn_angle.y
	#turn_speed = clamp(turn_speed,-1,1)
	#visual_wheel.rotation_degrees = turn_speed*90
	#
	#if last_turn_speed != turn_speed:
		#last_turn_speed = lerp(last_turn_speed,float(turn_speed),0.2)
		#var difference = turn_speed - last_turn_speed
		#friction = max(friction-(speed*(abs(difference)*0.5)),0)
		##print(friction)
		#$Visuals.rotation_degrees = (difference*speed)/3
		#$Camera3D.rotation_degrees.z = (difference*speed)/3
		#
#
	#var gear_value = widget_gear.value
	#gear = round(gear_value*2)+1
	#speed = move_toward(speed,MAX_SPEED*gear,ACCELERATION)
	#

	#
	#var speed_to_turn_multiplier : float = (speed/13)*(car_velocity.length()/10)
	#
	##if Input.is_action_pressed("drift"):
		##drift = move_toward(drift,4,DRIFT_ACCELERATION)
		##if drift > 2:
			##speed = move_toward(speed,0,(drift/20))
		##speed_to_turn_multiplier *= 1-(drift/6)
#
#
	#var direction = (transform.basis * Vector3(0,0,-1)).normalized()
	#var projected_velocity = direction*speed*4
	#
	#velocity.y += get_gravity().y
	#if is_on_floor():
		#velocity.y = max(velocity.y,0)
	#else:
		#friction = move_toward(friction,0,1)
#
	#angle -= (turn_speed*speed_to_turn_multiplier)
	#rotation.y = lerp_angle(rotation.y,deg_to_rad(angle),0.2)	
	#
	#
	#if Input.is_action_pressed("click_right"):
		#friction = move_toward(friction,0,2)
		#car_velocity *= 0.985
	#else:
		#friction = move_toward(friction,speed*3,0.4)
	#
	#car_velocity = car_velocity.move_toward(direction*speed,friction)
	#velocity = Vector3(car_velocity.x, velocity.y, car_velocity.z)#velocity.move_toward(car_velocity,friction)
	#move_and_slide()
	#
	#$Visuals/Hand.global_position = $Visuals.get_global_mouse_position()
	#$Visuals/Hand.rotation = (-200+$Visuals.get_global_mouse_position().x)/320
	#if widget_wheel.get_node("DraggableItem").drag:
		#$Visuals/Hand.global_position = visual_wheel.global_position+visual_wheel.global_position.direction_to($Visuals/Hand.global_position)*62.5
		#$Visuals/Hand.rotation -= (visual_wheel.global_position.angle_to($Visuals/Hand.global_position))/2
#
	#$Background.global_position = global_position
#
#
#func _on_area_entered(area: Area3D) -> void:
	#var entity : Entity = area
	#
	#if entity:
		#if entity.solid:
			#var camera_pos = $Camera3D.global_position
			#if entity.stompable:
				#velocity.y = 200
			#else:
				#camera_pos.y = entity.global_position.y
			#var camera_normal = camera_pos.direction_to(entity.global_position)
			#var collision_speed = speed*entity.collision_shape.shape.radius
			#car_velocity = car_velocity.bounce(camera_normal)
			##velocity = -velocity.normalized()*collision_speed#/get_physics_process_delta_time()
			#friction = 0
		#else:

				#
		#
		#if entity.hp > 0:
			#entity.hp -= 1
			#if entity.hp <= 0:
				#entity.queue_free()
		#
		#
		#print("ENTITY COLLISION ", entity)
#
#
func _spawn_item(item: PackedScene) -> void:
	if not item:
		return
	var spawn_position = Vector2(randi_range($SpawnZone.global_position.x,$SpawnZone.global_position.x+$SpawnZone.size.x),randi_range($SpawnZone.global_position.y,$SpawnZone.global_position.y+$SpawnZone.size.y))
	var item_scene = item.instantiate()
	item_scene.global_position = spawn_position
	item_scene.player = self
	add_child(item_scene)



func _on_item_despawn_zone_body_entered(body: Node2D) -> void:
	if body is Item:
		body.queue_free()


func _item_entered_face(body: Node2D) -> void:
	if body is Item and body not in current_items_in_face_region:
		var item: Item = body
		if item.lifetime_in_seconds == -1:
			return
		current_items_in_face_region.append(item)
		#if item.use_sound:
			#item.audio.play()


func _item_exited_face(body: Node2D) -> void:
	if body is Item and body in current_items_in_face_region:
		var item: Item = body
		current_items_in_face_region.erase(item)
		#if item.use_sound:
			#item.audio.stop()
		#item.lifetimer.stop()


func _items_in_face() -> void:
	if current_items_in_face_region.size() == 0:
		return
	
	if $FaceTimer.is_stopped():
		$Visuals/Asgore/NoseAnimation.play("sniff")
		$Visuals/Asgore.position.y += 10
		$FaceTimer.wait_time = randf_range(0.05,0.2)
		$FaceTimer.start()
		if Global.level == 1:
			Audio.play_sfx(preload("uid://c7k4yupbu4vu2"),randf_range(0.9,1.0),-3)
		else:
			Audio.play_sfx(preload("uid://bwrewdkj3pqlf"),randf_range(0.3,0.6),-6) # Sniff.wav
		for item in current_items_in_face_region:
			item.lifetime -= $FaceTimer.wait_time
			item.lifetime = max(item.lifetime,0.0)
	

func _on_area_3d_area_entered(area):
	if area.get_parent() is Entity:
		var entity: Entity = area.get_parent()
		if entity.solid and entity.collision_shape:
			var camera_pos = $Camera3D.global_position
			#camera_pos.y = entity.global_position.y
			#camera_pos.z = entity.global_position.z
			var camera_normal = camera_pos.direction_to(entity.global_position)
			
			if reverse == Vector3(1,0,1):
				
				print("reverse")
				reverse = Vector3(-1,0,-1)
				
			else:
				speed = 0
				reverse = Vector3(0,0,0)
			#rotation.y += -widget_wheel.value.x*(speed/100)
			var shape = entity.collision_shape.shape
			var bump_amount = 0
			
			if shape is BoxShape3D:
				bump_amount = shape.size.x
			elif shape is CapsuleShape3D or shape is SphereShape3D:
				bump_amount = shape.radius*2
			
			#car_velocity.x += sign(camera_pos.x-entity.global_position.x)*(bump_amount/2)
			#car_position.x += sign(camera_pos.x-entity.global_position.x)*(bump_amount/2)
			#car_position.x += sign(camera_pos.x-entity.global_position.x)*(speed/5)
			
			friction = 0
			
			car_angle.x = (camera_pos.x-entity.global_position.x)/50
			var wheel_dragpoint = widget_wheel.get_node("DraggableItem")
			wheel_dragpoint.global_position.x += (camera_pos.x-entity.global_position.x)*3
			wheel_dragpoint.global_position.y -= abs((camera_pos.x-entity.global_position.x))*3
		if entity.stompable:
			car_velocity.y = 0.3*entity.car_jump_mult
			car_velocity.z *= 1.1
		if entity.damage != 0:
			hp -= entity.damage*(1+(speed/5))
		screenshake_strength += 5
			
		if entity.hit_sound_impact:
			Audio.play_sfx(entity.hit_sound_impact)
		if entity.hit_sound_effect:
			Audio.play_sfx(entity.hit_sound_effect)
		
		if entity.items:
			
			var items = entity.items.duplicate()
			var extra_chance = gear-1-[0,1].pick_random()
			if Global.level == 3:
				extra_chance = gear-4
			if Global.level == 7:
				extra_chance = 1
			for i in range(max(extra_chance,1)):
				for itemdata in items:
					if not itemdata:
						continue
					var chance = randf_range(1,100)
					var target = itemdata.drop_chance
					#print("Rolled for item: ", chance, " chance in ", itemdata.drop_chance)
					if chance <= target:
						_spawn_item(itemdata.item)
		entity.hit(self)


func _gravity_mechanics(delta: float) -> void:
	car_velocity.y -= 1*delta
	if car_velocity.y > 0:
		car_velocity.y *= 0.9
	
	#$Camera3D.position.z = 10+($Camera3D.position.y-8)
	
	if is_on_floor():
		$Camera3D.position.y = 8.0
		car_velocity.y = 0
		if in_air:
			#car_velocity.x += randf_range(-speed,speed)/20
			in_air = false
			car_velocity.z *= 0.8
	else:
		if not in_air:
			#car_velocity.x += randf_range(-speed,speed)/20
			car_velocity.y *= speed/10
			in_air = true
			car_velocity.z *= 1.1
		friction = 1.1



func _horn(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if Global.modifiers.DrunkMode:
					await get_tree().create_timer(randf_range(0,0.3)*drunkness/20).timeout
					car_velocity.x = drunkness*[-1,1].pick_random()/10
				horn = true
				$CarHonk.play()
				if is_on_floor():
					car_velocity.y = 1
					if Global.modifiers.FragileCar:
						if $FragileTimer.time_left != 0:
							hp -= 5
						$FragileTimer.start(1)
			elif not event.pressed:
				horn = false
				$CarHonk.stop()
				if car_velocity.y > 0:
					car_velocity.y *= 0.4


func _correct_sprite_size(object: Node) -> void:
	var children = object.get_children()
	
	for child in children:
		if child.get_child_count() > 0:
			_correct_sprite_size(child)
		if child is Sprite3D:
			child.pixel_size = 0.06
			child.offset.y = 64.0
			child.sorting_offset = -999999
			child.position.y += 2


func _get_shake(delta: float) -> Vector2:
	noise_i += delta * screenshake_speed
	screenshake_strength = lerp(screenshake_strength,0.0,screenshake_decay*delta)
	return Vector2(
		noise.get_noise_2d(1,noise_i) * screenshake_strength,
		noise.get_noise_2d(100, noise_i) * screenshake_strength
	)


func _health_changed(previous_hp, new_hp) -> void:
	var difference = previous_hp-new_hp
	if difference <= 0.0:
		Audio.play_sfx(preload("uid://dt6ay2ruaak7r"),1.01,3) # Heal.wav
		return
	var value = difference*10
	value = clamp(value,1,30)
	screenshake_strength += value
	$DamageSplash.self_modulate.a += value/30
	Audio.play_sfx(preload("uid://c4ta6hdrl6ci5"),1.01,2)
	#$CarHurt.play()

func particle_trigger(part_type = 0, value = 5):
	match part_type:
		0:
			value = max(value,1)
			Audio.play_sfx(preload("uid://d288lwxjk6ljm"),1.0,-6)
			var particlefx = preload("uid://dsdofauesj7ga").instantiate() # Shimmer.tscn
			particlefx.amount = value
			particlefx.scale_amount_min = min(0.05+float(value)/50,0.15)
			particlefx.scale_amount_max = min(0.1+float(value)/40,0.2)
			$Particles/Shimmer.add_child(particlefx)
			particlefx.emitting = true
		
		1:
			var particlefx = preload("uid://du0uq38sl2de1").instantiate() # Shimmer.tscn
			$Particles/Leaves.add_child(particlefx)
			particlefx.emitting = true
		
		2:
			var particlefx = preload("uid://ci1pueoaiu5vg").instantiate()
			$Particles/Explosion.add_child(particlefx)
			particlefx.emitting = true
		3:
			var particlefx = preload("res://Global/Particles/Glasspuff.tscn").instantiate()
			$Particles/Explosion.add_child(particlefx)
			particlefx.emitting = true

func shoot():
	var bullet = preload("res://Entities/Bullet.tscn").instantiate()
	add_sibling(bullet)
	bullet.global_position = $Camera3D.global_position + Vector3($Visuals/Hand.position.x/20,0,0)


func _on_drunk_timer_timeout():
	drunkness += 1
	drunk_steer = [-1,1].pick_random()


func _on_outofbounds_area_entered(area):
	print("OUT OF TBOUTJANSKBSJKA")
	var bestnode = null
	var nextnode = null
	var lowest = 99999999
	var childnum = 0
	for node in get_tree().get_nodes_in_group("progress_point"):
		if node.position.distance_squared_to(position) < lowest:
			lowest = node.position.distance_squared_to(position)
			bestnode = node
			if childnum == get_tree().get_nodes_in_group("progress_point").size():
				nextnode = get_tree().get_nodes_in_group("progress_point")[0]
			else:
				nextnode = get_tree().get_nodes_in_group("progress_point")[childnum+1]
		childnum += 1
		
	look_at(nextnode.position)
	rotation.z = 0
	rotation.x = 0
	position = bestnode.position
	position.y = 0
	speed = 0
