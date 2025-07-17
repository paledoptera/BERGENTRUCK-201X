extends CharacterBody3D

const MAX_SPEED = 9
const ACCELERATION = 0.1
const TURN_ACCELERATION = 0.05
const DRIFT_ACCELERATION = 0.01
@export_category("Visuals")
@export var hand : Node2D
@export var widget_gear : Node
@export var widget_wheel : Node
@export var visual_gear : Node
@export var visual_wheel : Node
@export var visual_asgore : Node
@export var entities : Node
@export var entity_hitbox : Area3D
@export var screenshake_speed : float = 30.0
@export var screenshake_decay : float = 5.0



var turn_angle = Vector2(0.0,0.0)
var turn_speed = 0.0
var last_turn_speed = 0.0
var turn_start_y = 0.0
var gear: int = 1
var speed: float = 0.0
var in_air: bool = false
var horn: bool = false
var angle = 0.0
var drift = 0.0
var siner = 0.0
var friction = 1.0

var car_position = Vector3.ZERO
var car_velocity = Vector3.ZERO
var last_velocity = Vector3.ZERO
var car_angle = Vector2.ZERO
var car_shake = Vector2.ZERO
var screeching = false

var visuals_angle : float = 0.0
var steer_wiggle : float = 0.0

var last_direction = Vector2.ZERO
var hp = 100.0:
	set(value):
		_health_changed(hp, value)
		hp = value
		
var current_items_in_face_region : Array[Item]

var noise_i: float = 0.0
var screenshake_strength : float = 4.0

@onready var noise = FastNoiseLite.new()


func _ready() -> void:
	$Background.visible = true
	_correct_sprite_size($Ground)
	


func _physics_process(delta: float) -> void:
	last_velocity = car_velocity
	car_velocity.z = lerp(car_velocity.z,(0.003*speed),friction)
	$Ground.rotation.x += car_velocity.z
	entities.rotation.x += car_velocity.z
	
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
	#_horn_mechanics(delta)
	_gravity_mechanics(delta)
	_entity_mechanics()
	$Camera2D.offset=_get_shake(delta)
	
	
	car_position.x += car_velocity.x
	
	if last_angle != car_angle.x:
		var difference = abs(car_angle.x - last_angle)
		friction -= (difference*0.7)
		visuals_angle = (car_angle.x - last_angle)
		visuals_angle = clamp(visuals_angle,-0.1,0.1)
	else:
		visuals_angle *= 0.95
	
	visuals_angle += (noise.get_noise_2d(1,noise_i) * screenshake_strength)/100
	
	$Visuals/HealthBar/Dial.rotation_degrees = ((50.0-hp)/100)*90
	
	# DEBUG
	$Score.text = str("Score: ", Global.score, "/", Global.goal)
	$Visuals/SpeedBar/RichTextLabel.text = str("SPD: ", int(speed))
	$Visuals/HealthBar/RichTextLabel.text = str("HP: ", int(hp))
	
	$Camera3D.position.x = lerp($Camera3D.position.x,car_position.x+10,5*delta)
	$Camera3D.frustum_offset.x = lerp($Camera3D.frustum_offset.x,(car_angle.x/500),0.1)
	$Visuals.rotation = lerp($Visuals.rotation,visuals_angle*0.6,0.45)
	$Visuals.global_position.x = lerp($Visuals.global_position.x,(160+(visuals_angle*100)+((-visuals_angle*200)))+(car_shake.x),0.8)
	$Visuals.global_position.y = lerp($Visuals.global_position.y,130+(car_velocity.y*30),0.4)
	$Visuals.skew = ((-visuals_angle)*(1-friction))/2
	visual_asgore.position.x = lerp(visual_asgore.position.x,-210+(visuals_angle*100)+((-visuals_angle*200)*(1-friction)),0.3)
	visual_asgore.position.y = -127+((hand.position.y)/50)
	
	
	
func _hand_visuals() -> void:
	if Input.is_action_pressed("click"):
		hand.frame = 1
	else:
		hand.frame = 0
	
	
	var wheel_dragpoint = widget_wheel.get_node("DraggableItem")
	var gearbox_dragpoint = widget_gear.get_node("DraggableItem")

	if wheel_dragpoint.drag:
		wheel_dragpoint.drag_speed = friction*0.1
		wheel_dragpoint.global_position = visual_wheel.global_position+visual_wheel.global_position.direction_to(wheel_dragpoint.global_position)*67
		hand.global_position = lerp(hand.global_position,wheel_dragpoint.global_position,0.7)
		hand.rotation = lerp_angle(hand.rotation,(visual_wheel.rotation*0.3) - 0.4,0.7)
	elif gearbox_dragpoint.drag:
		hand.global_position = visual_gear.global_position
		hand.rotation = visual_gear.rotation*1.5
		hand.global_position.y -= 65
		hand.global_position.x += (widget_gear.value-0.5)*50
		
	else:
		var mouse_pos = hand.get_global_mouse_position()
		mouse_pos = mouse_pos.clamp(Vector2(0,0),hand.get_viewport_rect().size)
		hand.global_position = lerp(hand.global_position,mouse_pos,0.9)
		hand.rotation = (-200+mouse_pos.x)/320


func _gear_mechanics() -> void:
	var last_gear = gear
	
	var gear_value = widget_gear.value
	gear = round(gear_value*2)+1
	
	if last_gear != gear:
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
	turn_angle.y = 1+(widget_wheel.value.y*0.5)
	turn_speed = turn_angle.x * turn_angle.y
	turn_speed = clamp(turn_speed,-1,1)
	
	visual_wheel.rotation_degrees = (turn_speed*90)
	
	turn_speed *= (speed/5)*(2-friction)

	car_angle.x = lerp(car_angle.x,turn_speed,0.2)
	
	friction = clamp(float(friction), 0.0, 1.0)
	#print("SPEED = ", speed, " FRICTION = ", friction)
	friction = lerp(float(friction),1.0,0.1*(0.5+(0.5-(speed/20))))
	
	car_velocity.x = lerp(car_velocity.x,car_angle.x,friction)
	
	
	
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
	var spawn_position = Vector2(randi_range($SpawnZone.global_position.x,$SpawnZone.global_position.x+$SpawnZone.size.x),randi_range($SpawnZone.global_position.y,$SpawnZone.global_position.y+$SpawnZone.size.y))
	var item_scene = item.instantiate()
	item_scene.global_position = spawn_position
	add_child(item_scene)



func _on_item_despawn_zone_body_entered(body: Node2D) -> void:
	if body is Item:
		body.queue_free()


func _item_entered_face(body: Node2D) -> void:
	if body is Item and body not in current_items_in_face_region:
		var item: Item = body
		current_items_in_face_region.append(item)
		if item.use_sound:
			item.audio.play()
		item.lifetimer.start(item.lifetime_in_seconds)


func _item_exited_face(body: Node2D) -> void:
	if body is Item and body in current_items_in_face_region:
		var item: Item = body
		current_items_in_face_region.erase(item)
		if item.use_sound:
			item.audio.stop()
		item.lifetimer.stop()


func _entity_mechanics() -> void:
	if entity_hitbox.has_overlapping_areas():
		for area in entity_hitbox.get_overlapping_areas():
			if area.get_parent() is Entity:
				var entity: Entity = area.get_parent()
				entity.hit(self)
				if entity.solid:
					var camera_pos = $Camera3D.global_position
					camera_pos.y = entity.global_position.y
					camera_pos.z = entity.global_position.z
					var camera_normal = camera_pos.direction_to(entity.global_position)
			
					print("collision with ", entity.name)
					car_velocity.x = -car_velocity.x*(speed/10)
					
					var shape = entity.collision_shape.shape
					var bump_amount = 0
					
					if shape is BoxShape3D:
						bump_amount = shape.size.x
					elif shape is CapsuleShape3D or shape is SphereShape3D:
						bump_amount = shape.radius
					
					$Camera3D.position.x += sign(camera_pos.x-entity.global_position.x)*(bump_amount/2)
					car_position.x += sign(camera_pos.x-entity.global_position.x)*(bump_amount/2)
					car_position.x += (camera_pos.x-entity.global_position.x)*(speed/5)
					friction = 0
					print(car_velocity.x)
					car_angle.x = (camera_pos.x-entity.global_position.x)/50
					var wheel_dragpoint = widget_wheel.get_node("DraggableItem")
					wheel_dragpoint.global_position.x += (camera_pos.x-entity.global_position.x)*3
					wheel_dragpoint.global_position.y -= abs((camera_pos.x-entity.global_position.x))*3
				if entity.stompable:
					car_velocity.y = 0.3
					car_velocity.z *= 1.1
					entity.queue_free()
				if entity.damage != 0:
					hp -= entity.damage*(1+(speed/5))
				screenshake_strength += 5
				
				if entity.hit_sound_impact:
					$HitSoundImpact.stream = entity.hit_sound_impact
					$HitSoundImpact.play()
				if entity.hit_sound_effect:
					$HitSoundEffect.stream = entity.hit_sound_effect
					$HitSoundEffect.play()
				
				
				#velocity.y = 20
		#
				if entity.items:
					var items = entity.items.duplicate()
					for itemdata in items:
						var chance = randf_range(1,100)
						var chance_mult = int(speed/5)
						chance_mult = clampi(chance_mult,1,10)
						chance /= chance_mult
						var target = itemdata.drop_chance
						print("Rolled for item: ", chance, " chance in ", itemdata.drop_chance)
						if chance <= target:
							_spawn_item(itemdata.item)
							entity.items.erase(itemdata)

func _gravity_mechanics(delta: float) -> void:
	car_velocity.y -= 1*delta
	if car_velocity.y > 0:
		car_velocity.y *= 0.9
	
	$Camera3D.position.y += car_velocity.y
	$Camera3D.position.z = 10+($Camera3D.position.y-8)
	
	if $Camera3D.position.y <= 8.0:
		$Camera3D.position.y = 8.0
		car_velocity.y = 0
		if in_air:
			car_velocity.x += randf_range(-speed,speed)/20
			in_air = false
			car_velocity.z *= 0.8
	elif $Camera3D.position.y > 8.0:
		if not in_air:
			car_velocity.x += randf_range(-speed,speed)/20
			car_velocity.y *= speed/10
			in_air = true
			car_velocity.z *= 1.1
		friction = 0
func _horn(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				horn = true
				$CarHonk.play()
				if Global.level == 3:
					if $Camera3D.position.y == 8.0:
						car_velocity.y = 1
			elif not event.pressed:
				horn = false
				$CarHonk.stop()
				if Global.level == 3:
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
	pass

func _health_changed(previous_hp, new_hp) -> void:
	var difference = previous_hp-new_hp
	var value = difference*10
	value = clamp(value,1,30)
	screenshake_strength += value
	$CarHurt.play()
