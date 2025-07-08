extends CharacterBody3D

const MAX_SPEED = 9
const ACCELERATION = 0.1
const TURN_ACCELERATION = 0.05
const DRIFT_ACCELERATION = 0.01
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


#func _steering_wheel_get_y(event_position):
	#print(event_position-$WidgetGear/DraggableItem.position)
	#pass

func _ready() -> void:
	$Background.visible = true

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("click"):
		$Visuals/AsgoreArm.frame = 1
	else:
		$Visuals/AsgoreArm.frame = 0
	
	siner += delta
	turn_angle.x = $WidgetWheel.value.x
	turn_angle.y = 1+($WidgetWheel.value.y*0.5)
	turn_speed = turn_angle.x * turn_angle.y
	turn_speed = clamp(turn_speed,-1,1)
	$Visuals/SteeringWheel.rotation_degrees = turn_speed*90
	
	if last_turn_speed != turn_speed:
		last_turn_speed = lerp(last_turn_speed,turn_speed,0.2)
		var difference = turn_speed - last_turn_speed
		$Visuals.rotation_degrees = (difference*speed)/3
		$Camera3D.rotation_degrees.z = (difference*speed)/3

	var gear_value = $WidgetGear.value
	gear = round(gear_value*2)+1
	speed = move_toward(speed,MAX_SPEED*gear,ACCELERATION)
	
	if $WidgetGear/DraggableItem.drag:
		$Visuals/GearShift.position.x = 80 + (gear_value-0.5)*30
		$Visuals/GearShift.rotation_degrees = (gear_value-0.5)*50
	else:
		$Visuals/GearShift.position.x = 80 + (gear-2)*15
		$Visuals/GearShift.rotation_degrees = (gear-2)*25
		
	
	var speed_to_turn_multiplier : float = (speed/13)*(velocity.length()/50)
	
	#if Input.is_action_pressed("drift"):
		#drift = move_toward(drift,4,DRIFT_ACCELERATION)
		#if drift > 2:
			#speed = move_toward(speed,0,(drift/20))
		#speed_to_turn_multiplier *= 1-(drift/6)


	var direction = (transform.basis * Vector3(0,0,-1)).normalized()
	var projected_velocity = direction*speed*3
	
	velocity.y += get_gravity().y
	if is_on_floor():
		velocity.y = max(velocity.y,0)
	else:
		friction = move_toward(friction,0,3)

	angle -= (turn_speed*speed_to_turn_multiplier)*1.2
	rotation.y = lerp_angle(rotation.y,deg_to_rad(angle),0.2)	
	
	
	if Input.is_action_pressed("click_right"):
		friction = move_toward(friction,0,1)
		car_velocity *= 0.985
	else:
		friction = move_toward(friction,speed*3,0.2)
	
	car_velocity = car_velocity.move_toward(direction*speed*3,friction)
	velocity = Vector3(car_velocity.x, velocity.y, car_velocity.z)#velocity.move_toward(car_velocity,friction)
	move_and_slide()
	
	$Visuals/AsgoreArm.global_position = $Visuals.get_global_mouse_position()
	$Visuals/AsgoreArm.rotation = (-200+$Visuals.get_global_mouse_position().x)/320
	if $WidgetWheel/DraggableItem.drag:
		$Visuals/AsgoreArm.global_position = $Visuals/SteeringWheel.global_position+$Visuals/SteeringWheel.global_position.direction_to($Visuals/AsgoreArm.global_position)*62.5
		$Visuals/AsgoreArm.rotation -= ($Visuals/SteeringWheel.global_position.angle_to($Visuals/AsgoreArm.global_position))/2

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
					var item_scene = itemdata.item.instantiate()
					item_scene.global_position = Vector2(200,-20)
					add_child(item_scene)
					entity.items.erase(itemdata)
				
		
		if entity.hp > 0:
			entity.hp -= 1
			if entity.hp <= 0:
				entity.queue_free()
		
		
		print("ENTITY COLLISION ", entity)
