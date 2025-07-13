extends Node2D

class_name Enemy

var current_bullets = []

@onready var SHOT_DIRS : Array[Vector2] = [Vector2.LEFT, Vector2.LEFT.rotated(PI/20), Vector2.LEFT.rotated(-PI/20)]

func _ready() -> void:
	$enemy_component.set_shot_dirs(SHOT_DIRS)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_shooting():
	$enemy_component.start_shooting()

func stop_shooting():
	$enemy_component.stop_shooting()
