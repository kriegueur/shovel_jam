extends ProjectileComponent
class_name MortarProjectile

@export var gravity: float = 980.0
@export var arc_height: float = 300.0

@export var steps := 50
@export var step_time := 0.1

var velocity: Vector2
var has_landed: bool = false

var predicted_points := []

func _ready() -> void:
	super._ready()
	
	var target = get_tree().get_first_node_in_group("player")
	var start = global_position
	var end = target.global_position
	var displacement = end - start
	
	var height = -arc_height
	var time_to_peak = sqrt(-2 * height / gravity)
	var total_height = displacement.y - height
	var time_from_peak = sqrt(2 * total_height / gravity)
	var total_time = time_to_peak + time_from_peak
	
	var vx = displacement.x / total_time * 0.9
	var vy = sqrt(-2 * gravity * height)
	velocity = Vector2(vx, -vy)

func _process(delta: float) -> void:
	if status == ProjectileState.PARRIED:
		var sender_position = get_parent().get_parent().global_position
		parent.dir = (sender_position - global_position).normalized()
		parent.rotation = velocity.angle()
		parent.global_translate(parent.dir * SPEED * delta)

	elif not has_landed:
		velocity.y += gravity * delta
		parent.global_translate(velocity * delta)
		parent.rotation = velocity.angle()

func explode():
	destroy_projectile(parent.global_position)
