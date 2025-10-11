extends Area2D
class_name RotatableItem

signal dragging(delta)

@export var drag_speed: float = 1.0
@export var momentum: float = 0.0
@export var initial_angle: float = 0
@export var max_angle: float = 360
@export var min_angle: float = -360
var velocity: float = 0
var drag: bool = false

@onready var drag_component = $MouseDragComponent as MouseDragComponent
@onready var rotationanchor = $RotationAnchor
@onready var previous_angle = rotationanchor.global_rotation
@onready var start_angle = global_rotation

func _ready() -> void :
    drag = false

func _on_item_drag_started(event_position):
    drag = true

func _on_item_drag_ended():
    drag = false

func _process(delta: float) -> void :
    previous_angle = rotationanchor.global_rotation

    if drag:
        previous_angle = rotationanchor.global_rotation
        $Parent.look_at(get_global_mouse_position())
        rotationanchor.reparent($Parent)
        if previous_angle != rotationanchor.global_rotation:
            if abs(velocity) < abs(rotationanchor.global_rotation - previous_angle):
                velocity += rotationanchor.global_rotation - previous_angle
            else:
                velocity *= momentum
        dragging.emit(delta)

    else:
        rotationanchor.reparent(self)
        rotationanchor.global_rotation += velocity
    velocity *= momentum
    rotationanchor.global_rotation = clamp(rotationanchor.global_rotation, deg_to_rad(min_angle) + start_angle, deg_to_rad(max_angle) + start_angle)
    $RichTextLabel.text = str(rotationanchor.global_rotation_degrees)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void :
    drag_component.object_held_down(event)
