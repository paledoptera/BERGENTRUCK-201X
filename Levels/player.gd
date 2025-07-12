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
var turn_angle = Vector2(0.0,0.0)
var turn_speed = 0.0
var last_turn_speed = 0.0
var turn_start_y = 0.0
var gear: int = 1
var speed: float = 0.0
var angle = 0.0
var drift = 0.0
var siner = 0.0
var friction = 1.0

var car_position = Vector3.ZERO
var car_velocity = Vector3.ZERO
var car_angle = Vector2.ZERO
var car_shake = Vector2.ZERO

var visuals_angle : float = 0.0
var steer_wiggle : float = 0.0

var last_direction = Vector2.ZERO
var hp = 100
var current_items_in_face_region : Array[Item]



func _ready() -> void:
	$Background.visible = true


func _physics_process(delta: float) -> void:
	car_velocity.z = lerp(car_velocity.z,(0.003*speed),friction)
	$Ground.rotation.x += car_velocity.z
	#$Ground.rotation.x += (0.003*speed)*friction
	
	var last_velocity = car_velocity
	
	_gear_mechanics()
	speed = lerp(speed,float(gear*3.34),friction*delta)
	_steering_mechanics()
	_hand_visuals()
	_shake(delta)
	
	
	$Camera3D.position = lerp($Camera3D.position,car_position+Vector3(10,8,10),(friction*5)*delta)
	$Camera3D.frustum_offset.x = lerp($Camera3D.frustum_offset.x,(car_angle.x/500),0.1)
	$Visuals.rotation = lerp($Visuals.rotation,visuals_angle*0.6,0.45)
	$Visuals.global_position.x = (160+(visuals_angle*100)+((-visuals_angle*200)*(1-friction)))+(car_shake.x)
	$Visuals.global_position.y = (130+(car_shake.y))
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
		wheel_dragpoint.global_position = visual_wheel.global_position+visual_wheel.global_position.direction_to(wheel_dragpoint.global_position)*67
		hand.global_position = lerp(hand.global_position,wheel_dragpoint.global_position,0.7)
		hand.rotation = lerp_angle(hand.rotation,(visual_wheel.rotation*0.3) - 0.4,0.7)
	elif gearbox_dragpoint.drag:
		hand.global_position = visual_gear.global_position
		hand.rotation = visual_gear.rotation*1.5
		hand.global_position.y -= 65
		hand.global_position.x += (widget_gear.value-0.5)*50
		
	else:
		hand.global_position = lerp(hand.global_position,hand.get_global_mouse_position(),0.9)
		hand.rotation = (-200+hand.get_global_mouse_position().x)/320


func _gear_mechanics() -> void:
	var gear_value = widget_gear.value
	gear = round(gear_value*2)+1
	
	if widget_gear.get_node("DraggableItem").drag:
		visual_gear.position.x = 255 + (gear_value-0.5)*30
		visual_gear.rotation_degrees = (gear_value-0.5)*50
	else:
		visual_gear.position.x = 255 + (gear-2)*15
		visual_gear.rotation_degrees = (gear-2)*25


func _steering_mechanics() -> void:
	
	var last_angle = car_angle.x
	
	steer_wiggle = randf_range(-speed*2,speed*2)
	
	turn_angle.x = widget_wheel.value.x
	turn_angle.y = 1+(widget_wheel.value.y*0.5)
	turn_speed = turn_angle.x * turn_angle.y
	turn_speed = clamp(turn_speed,-1,1)
	
	visual_wheel.rotation_degrees = (turn_speed*90)
	
	turn_speed *= (speed/5)

	car_angle.x = lerp(car_angle.x,turn_speed,0.2)
		
	if last_angle != car_angle.x:
		var difference = abs(car_angle.x - last_angle)
		friction -= (difference*0.7)
		visuals_angle = (car_angle.x - last_angle)
		visuals_angle = clamp(visuals_angle,-0.2,0.2)
	else:
		visuals_angle *= 0.95
	
	friction = clamp(friction, 0.0, 1.0)
	friction = lerp(friction,1.0,0.1)
	
	car_position.x += (car_angle.x)*friction
	
	
	
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
			#if entity.stompable:
				#velocity.y = 20
		#
		#if entity.items:
			#var items = entity.items.duplicate()
			#for itemdata in items:
				#var chance = randf_range(1,100)
				#var target_mult = 1.0-((itemdata.speed_effect/100)-(speed/27))
				#var target = itemdata.drop_chance * target_mult
				#if chance <= target:
					#_spawn_item(itemdata.item)
					#entity.items.erase(itemdata)
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
#func _spawn_item(item: PackedScene) -> void:
	#var spawn_position = Vector2(randi_range($SpawnZone.global_position.x,$SpawnZone.global_position.x+$SpawnZone.size.x),randi_range($SpawnZone.global_position.y,$SpawnZone.global_position.y+$SpawnZone.size.y))
	#var item_scene = item.instantiate()
	#item_scene.global_position = spawn_position
	#add_child(item_scene)
#
#
#
#func _on_item_despawn_zone_body_entered(body: Node2D) -> void:
	#if body is Item:
		#body.queue_free()
#
#
#func _item_entered_face(body: Node2D) -> void:
	#if body is Item and body not in current_items_in_face_region:
		#var item: Item = body
		#current_items_in_face_region.append(item)
		#if item.use_sound:
			#item.audio.play()
		#item.lifetimer.start(item.lifetime_in_seconds)
#
#
#func _item_exited_face(body: Node2D) -> void:
	#if body is Item and body in current_items_in_face_region:
		#var item: Item = body
		#current_items_in_face_region.erase(item)
		#if item.use_sound:
			#item.audio.stop()
		#item.lifetimer.stop()


func _shake(delta: float) -> void:
	pass
	#siner += 1
	#if friction < 0.5:
		#car_shake.x = lerp(car_shake.x,randf_range(-100,100),0.1)
		#car_shake.y = lerp(car_shake.y,randf_range(-100,100),0.1)
#
		#
	#print("car_shake: ", car_shake)
	#car_shake *= 0.9
