extends ProjectileComponent
class_name HomingProjectile

@export var turn_speed: float = 2.0
@export var acceleration: float = 100.0
@export var max_speed: float = 600.0
var current_speed: float = 200.0

func _process(delta: float):
	if status == ProjectileState.PARRIED:
		var sender_position = get_parent().get_parent().global_position
		parent.dir = (sender_position - global_position).normalized()
		parent.global_translate(parent.dir * SPEED * delta)
	else:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var target_dir = (player.global_position - parent.global_position).normalized()
			if player.global_position.x -10 < global_position.x:
				parent.dir = parent.dir.lerp(target_dir, turn_speed * delta)
			current_speed = min(current_speed + acceleration * delta, max_speed)
			parent.global_translate(parent.dir * current_speed * delta)
			parent.rotation = parent.dir.angle()
