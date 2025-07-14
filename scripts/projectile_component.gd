extends Node2D
class_name ProjectileComponent

@export var SPEED = 500
@onready var parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent.global_translate(parent.dir * SPEED * delta)

func return_to_sender():
	var sender_position = get_parent().get_parent().global_position
	parent.dir = (sender_position - global_position).normalized()
