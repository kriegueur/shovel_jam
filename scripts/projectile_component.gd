extends Node2D
class_name ProjectileComponent

@export var SPEED = 500
@export var DAMAGE = 20

@onready var parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent.global_translate(parent.dir * SPEED * delta)

func return_to_sender():
	var sender_position = get_parent().get_parent().global_position
	parent.dir = (sender_position - global_position).normalized()

func create_explosion_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 0.8, 1.0))  # Blanc chaud au début
	gradient.add_point(0.3, Color(1.0, 0.6, 0.1, 1.0))  # Orange vif
	gradient.add_point(0.7, Color(0.8, 0.2, 0.1, 0.8))  # Rouge foncé
	gradient.add_point(1.0, Color(0.3, 0.1, 0.1, 0.0))  # Disparition
	return gradient

func destroy_projectile(hit_position: Vector2):
	var parent_projectile = get_parent()
	var particles = CPUParticles2D.new()
	parent_projectile.cleanse()
		
	parent_projectile.add_child(particles)
	particles.global_position = hit_position
	
	particles.emitting = true
	particles.amount = 60
	particles.lifetime = 0.8
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 2.0
	particles.direction = Vector2(1, 0)
	particles.spread = 360.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 200.0
	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 2.0
	particles.color = Color(1.0, 0.6, 0.1, 1.0)
	particles.gravity = Vector2(0, 50)
	particles.linear_accel_min = -100.0
	particles.linear_accel_max = -50.0
	particles.color_ramp = create_explosion_gradient()
	
	var timer = Timer.new()
	get_parent().add_child(timer)
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(func(): 
		particles.queue_free()
		timer.queue_free()
	)
	timer.start()
