extends Node2D

class_name Projectile

var startPos : Vector2
var startRot : float
var dir : Vector2 = Vector2.LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = startPos
	global_rotation = startRot

func cleanse() -> void:
	for i in range(0, get_child_count()):
		get_child(i).queue_free()
