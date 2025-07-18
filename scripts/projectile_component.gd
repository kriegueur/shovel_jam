extends Node2D
class_name ProjectileComponent

@export var SPEED = 500
@export var DAMAGE = 20
@export var explosion_particle_scene: PackedScene

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
	parent.cleanse()
	
	if explosion_particle_scene:
		var explosion_instance = explosion_particle_scene.instantiate()
		parent.add_child(explosion_instance)
		explosion_instance.global_position = hit_position
		var particles = explosion_instance.get_node("ExplosionElement") as CPUParticles2D
		if particles:
			particles.emitting = true
	
	#parent.add_child(particles)
	#particles.global_position = hit_position
	#
	#particles.emitting = true
	#particles.amount = 30
	#particles.lifetime = 0.5
	#particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	#particles.emission_sphere_radius = 5.0
	#particles.direction = Vector2(1, 0)
	#particles.spread = 360.0
	#particles.initial_velocity_min = 180.0
	#particles.initial_velocity_max = 200.0
	#particles.scale_amount_min = 2.8
	#particles.scale_amount_max = 4.0
	#particles.color = Color(1.0, 0.6, 0.1, 1.0)
	#particles.gravity = Vector2(0, 0)
	#particles.linear_accel_min = -10.0
	#particles.linear_accel_max = -5.0
	#particles.color_ramp = create_explosion_gradient()
	#particles.one_shot = true
