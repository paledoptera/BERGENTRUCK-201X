extends RigidBody2D
var strength = 50

func _ready() -> void:
	$DraggableItem.top_level = true
	$DraggableItem.global_position = global_position
	$DraggableItem.global_rotation = global_rotation

func _integrate_forces(state) -> void:
	if $DraggableItem.drag:
		linear_velocity = global_position.direction_to($DraggableItem.global_position) * (global_position.distance_to($DraggableItem.global_position) * strength)

func _physics_process(delta: float) -> void:
	if $DraggableItem.drag:
		global_position = $DraggableItem.global_position
		global_rotation = $DraggableItem.global_rotation
	else:
		$DraggableItem.global_position = global_position
		$DraggableItem.global_rotation = global_rotation


func _on_input_event(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var new_event = event
		print(new_event.position)
		new_event.position = global_position + new_event.position + $GrabBox.position
		$DraggableItem/MouseDragComponent.object_held_down(event)
