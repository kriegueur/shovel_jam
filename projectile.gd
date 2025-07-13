extends Node2D

class_name Projectile

@export var SPEED = 500

var startPos : Vector2
var startRot : float
var dir : Vector2 = Vector2.LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = startPos
	global_rotation = startRot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_translate(dir * SPEED * delta)
