extends CharacterBody3D

const MAX_SPEED = 9
const ACCELERATION = 0.1
const TURN_ACCELERATION = 0.05
const DRIFT_ACCELERATION = 0.01
@export var widget_gear : Node
@export var widget_wheel : Node
@export var visual_gear : Node
@export var visual_wheel : Node
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
var car_velocity = Vector3.ZERO
var last_direction = Vector2.ZERO
var hp = 100
var current_items_in_face_region : Array[Item]


#func _steering_wheel_get_y(event_position):
	#print(event_position-widget_gear/DraggableItem.position)
	#pass

func _ready() -> void:
	$Background.visible = true

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("click"):
		$Visuals/Hand.frame = 1
	else:
		$Visuals/Hand.frame = 0
	
	siner += delta
	turn_angle.x = widget_wheel.value.x
	turn_angle.y = 1+(widget_wheel.value.y*0.5)
	turn_speed = turn_angle.x * turn_angle.y
	turn_speed = clamp(turn_speed,-1,1)
	visual_wheel.rotation_degrees = turn_speed*90
	
	if last_turn_speed != turn_speed:
		last_turn_speed = lerp(last_turn_speed,float(turn_speed),0.2)
		var difference = turn_speed - last_turn_speed
		friction = max(friction-(speed*(abs(difference)*0.5)),0)
		#print(friction)
		$Visuals.rotation_degrees = (difference*speed)/3
		$Camera3D.rotation_degrees.z = (difference*speed)/3
		

	var gear_value = widget_gear.value
	gear = round(gear_value*2)+1
	speed = move_toward(speed,MAX_SPEED*gear,ACCELERATION)
	
	if widget_gear.get_node("DraggableItem").drag:
		visual_gear.position.x = 80 + (gear_value-0.5)*30
		visual_gear.rotation_degrees = (gear_value-0.5)*50
	else:
		visual_gear.position.x = 80 + (gear-2)*15
		visual_gear.rotation_degrees = (gear-2)*25
		
	
	var speed_to_turn_multiplier : float = (speed/13)*(car_velocity.length()/10)
	
	#if Input.is_action_pressed("drift"):
		#drift = move_toward(drift,4,DRIFT_ACCELERATION)
		#if drift > 2:
			#speed = move_toward(speed,0,(drift/20))
		#speed_to_turn_multiplier *= 1-(drift/6)


	var direction = (transform.basis * Vector3(0,0,-1)).normalized()
	var projected_velocity = direction*speed*4
	
	velocity.y += get_gravity().y
	if is_on_floor():
		velocity.y = max(velocity.y,0)
	else:
		friction = move_toward(friction,0,1)

	angle -= (turn_speed*speed_to_turn_multiplier)
	rotation.y = lerp_angle(rotation.y,deg_to_rad(angle),0.2)	
	
	
	if Input.is_action_pressed("click_right"):
		friction = move_toward(friction,0,2)
		car_velocity *= 0.985
	else:
		friction = move_toward(friction,speed*3,0.4)
	
	car_velocity = car_velocity.move_toward(direction*speed,friction)
	velocity = Vector3(car_velocity.x, velocity.y, car_velocity.z)#velocity.move_toward(car_velocity,friction)
	move_and_slide()
	
	$Visuals/Hand.global_position = $Visuals.get_global_mouse_position()
	$Visuals/Hand.rotation = (-200+$Visuals.get_global_mouse_position().x)/320
	if widget_wheel.get_node("DraggableItem").drag:
		$Visuals/Hand.global_position = visual_wheel.global_position+visual_wheel.global_position.direction_to($Visuals/Hand.global_position)*62.5
		$Visuals/Hand.rotation -= (visual_wheel.global_position.angle_to($Visuals/Hand.global_position))/2

	$Background.global_position = global_position


func _on_area_entered(area: Area3D) -> void:
	var entity : Entity = area
	
	if entity:
		if entity.solid:
			var camera_pos = $Camera3D.global_position
			if entity.stompable:
				velocity.y = 200
			else:
				camera_pos.y = entity.global_position.y
			var camera_normal = camera_pos.direction_to(entity.global_position)
			var collision_speed = speed*entity.collision_shape.shape.radius
			car_velocity = car_velocity.bounce(camera_normal)
			#velocity = -velocity.normalized()*collision_speed#/get_physics_process_delta_time()
			friction = 0
		else:
			if entity.stompable:
				velocity.y = 20
		
		if entity.items:
			var items = entity.items.duplicate()
			for itemdata in items:
				var chance = randf_range(1,100)
				var target_mult = 1.0-((itemdata.speed_effect/100)-(speed/27))
				var target = itemdata.drop_chance * target_mult
				if chance <= target:
					_spawn_item(itemdata.item)
					entity.items.erase(itemdata)
				
		
		if entity.hp > 0:
			entity.hp -= 1
			if entity.hp <= 0:
				entity.queue_free()
		
		
		print("ENTITY COLLISION ", entity)


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
