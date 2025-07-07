extends CharacterBody3D

const MAX_SPEED = 8
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
var last_direction = Vector2.ZERO


#func _steering_wheel_get_y(event_position):
	#print(event_position-$WidgetGear/DraggableItem.position)
	#pass

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
		$Visuals.rotation_degrees = difference*speed
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
		
	var speed_to_turn_multiplier : float = speed/8.5
	
	#if Input.is_action_pressed("drift"):
		#drift = move_toward(drift,4,DRIFT_ACCELERATION)
		#if drift > 2:
			#speed = move_toward(speed,0,(drift/20))
		#speed_to_turn_multiplier *= 1-(drift/6)


	var direction = (transform.basis * Vector3(0,0,-1)).normalized()
	var car_velocity = direction*speed

	angle -= turn_speed*speed_to_turn_multiplier
	rotation.y = lerp_angle(rotation.y,deg_to_rad(angle),0.2)	
	velocity = direction*speed*1.8
	move_and_slide()
	
	$Visuals/AsgoreArm.global_position = $Visuals.get_global_mouse_position()
	$Visuals/AsgoreArm.rotation = (-200+$Visuals.get_global_mouse_position().x)/320
	if $WidgetWheel/DraggableItem.drag:
		$Visuals/AsgoreArm.global_position = $Visuals/SteeringWheel.global_position+$Visuals/SteeringWheel.global_position.direction_to($Visuals/AsgoreArm.global_position)*62.5
		$Visuals/AsgoreArm.rotation -= ($Visuals/SteeringWheel.global_position.angle_to($Visuals/AsgoreArm.global_position))/2

	$Background.global_position = global_position
