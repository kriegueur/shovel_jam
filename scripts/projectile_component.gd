extends Node2D

@export var SPEED = 500
@onready var parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent.global_translate(parent.dir * SPEED * delta)
