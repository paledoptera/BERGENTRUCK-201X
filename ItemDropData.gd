class_name ItemDropData
extends Resource

@export var item : PackedScene
@export_range(0,100,1) var drop_chance : int = 30
@export_range(0,100,1) var speed_effect : int = 100
@export var drop_amount_min : int = 0
@export var drop_amount_max : int = 1
