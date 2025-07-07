extends CharacterBody3D

const MAX_SPEED = 7
const ACCELERATION = 0.1
const TURN_ACCELERATION = 0.05
const DRIFT_ACCELERATION = 0.01
var turn_angle = Vector2(0.0,0.0)
var turn_speed = 0.0
var turn_start_y = 0.0
var gear: int = 1
var speed: float = 0.0
var angle = 0.0
var drift = 0.0
var siner = 0.0


#func _steering_wheel_get_y(event_position):
	#print(event_position-$WidgetGear/DraggableItem.position)
	#pass

func _physics_process(delta: float) -> void:
	siner += delta
	
	turn_angle.x = $WidgetWheel.value.x
	turn_angle.y = 1+($WidgetWheel.value.y*0.5)
	turn_speed = turn_angle.x * turn_angle.y
	turn_speed = clamp(turn_speed,-1,1)
	$Visuals/SteeringWheel.rotation_degrees = turn_speed*90
	
	var gear_value = $WidgetGear.value
	gear = round(gear_value*2)+1
	speed = move_toward(speed,MAX_SPEED*gear,ACCELERATION)
	
	if $WidgetGear/DraggableItem.drag:
		$Visuals/GearShift.position.x = 320 + (gear_value-0.5)*30
		$Visuals/GearShift.rotation_degrees = (gear_value-0.5)*50
	else:
		$Visuals/GearShift.position.x = 320 + (gear-2)*15
		$Visuals/GearShift.rotation_degrees = (gear-2)*25
		
	var speed_to_turn_multiplier : float = speed/8.5
	
	#if Input.is_action_pressed("drift"):
		#drift = move_toward(drift,4,DRIFT_ACCELERATION)
		#if drift > 2:
			#speed = move_toward(speed,0,(drift/20))
		#speed_to_turn_multiplier *= 1-(drift/6)


	var direction = (transform.basis * Vector3(0,0,-1)).normalized()
	var car_velocity = direction*speed
	
	#print(turn_speed*speed_to_turn_multiplier)
	
	
	angle -= turn_speed*speed_to_turn_multiplier
	#angle = clamp(angle,-90,90)
	rotation_degrees.y = angle
	
	
	velocity = direction*speed
	move_and_slide()
