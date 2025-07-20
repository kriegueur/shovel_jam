extends ProjectileComponent
class_name FallingProjectile

@export var gravity: float = 200.0
@export var max_fall_speed: float = 600.0
var fall_speed: float = 0.0

func _ready():
	super._ready()
	if trail_instance:
		trail_instance.queue_free()

func _process(delta: float):
	if status == ProjectileState.PARRIED:
		var sender_position = get_parent().get_parent().global_position
		parent.dir = (sender_position - global_position).normalized()
		parent.global_translate(parent.dir * SPEED * delta)
	else:
		fall_speed = min(fall_speed + gravity * delta, max_fall_speed)
		parent.global_translate(Vector2.DOWN * fall_speed * delta)
		if parent.global_position.y > get_viewport().size.y + 100:
			parent.queue_free()
