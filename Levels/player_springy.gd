extends "res://Levels/player.gd"

var current_hand = true
@onready var arm_l_pos = $Camera3D/ArmL.position
@onready var arm_r_pos = $Camera3D/ArmR.position
var hand_jiggle_siner: float = 0

func _physics_process(delta: float) -> void:
	super(delta)
	hand_jiggle_siner += delta
	
	$Camera3D/ArmL.rotation.y = (car_angle.x/3)
	$Camera3D/ArmL.rotation.z = (car_angle.x/2)
	$Camera3D/ArmL.position = $Camera3D/ArmL.position.lerp(arm_l_pos+Vector3((car_angle.x*1.5)+Utility.get_sine(hand_jiggle_siner,0.2,3.5),(car_angle.x/2)+Utility.get_sine(hand_jiggle_siner,0.2,7.0),abs(car_angle.x)/5),0.2)
	
	$Camera3D/ArmR.rotation.y = (car_angle.x/3)
	$Camera3D/ArmR.rotation.z = (car_angle.x/2)
	$Camera3D/ArmR.position = $Camera3D/ArmR.position.lerp(arm_r_pos+Vector3((car_angle.x*1.5)+Utility.get_sine(hand_jiggle_siner,0.2,3.5),(-car_angle.x/2)+Utility.get_sine(hand_jiggle_siner,0.2,7.0),abs(car_angle.x)/5),0.2)

func _horn(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				#if current_hand:
					
				horn = true
				$CarHonk.play()
				if current_hand and not $ArmAnimationR.is_playing():
					$Camera3D/ArmR/GloveR/Area3D.monitoring = true
					$ArmAnimationR.play("punch")
				elif not current_hand and not $ArmAnimationL.is_playing():
					$Camera3D/ArmL/GloveL/Area3D.monitoring = true
					$ArmAnimationL.play("punch")
				else:
					return
				current_hand = not current_hand
				#if $Camera3D.position.y == 8.0:
					#car_velocity.y = 0.5
			elif not event.pressed:
				horn = false
				$CarHonk.stop()
				#if car_velocity.y > 0:
					#car_velocity.y *= 0.4


func _punch_collision(area: Area3D) -> void:
	$Camera3D/ArmL/GloveL/Area3D.monitoring = false
	$Camera3D/ArmR/GloveR/Area3D.monitoring = false
	
	if area.get_parent() is Entity:
		var entity: Entity = area.get_parent()
		entity.hit(self)
