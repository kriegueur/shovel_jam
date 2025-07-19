extends Node2D
class_name ProjectileComponent

@export var SPEED = 500
@export var DAMAGE = 20
@export var explosion_particle_scene: PackedScene
@export var trail_particle_scene: PackedScene

var trail_instance

@onready var parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent.global_translate(parent.dir * SPEED * delta)
	if trail_instance:
		trail_instance.global_position = parent.global_position


func _ready() -> void:
	if trail_particle_scene:
		trail_instance = trail_particle_scene.instantiate()
		add_child(trail_instance)
		var particles = trail_instance.get_node("CPUParticles2D") as CPUParticles2D
		if particles:
			particles.emitting = true
			particles.one_shot = false

func return_to_sender():
	var sender_position = get_parent().get_parent().global_position
	parent.dir = (sender_position - global_position).normalized()

func destroy_projectile(hit_position: Vector2):
	parent.cleanse()
	
	if trail_instance:
		var trail_particles = trail_instance.get_node("CPUParticles2D") as CPUParticles2D
		if trail_particles:
			trail_particles.emitting = false
	
	if explosion_particle_scene:
		var explosion_instance = explosion_particle_scene.instantiate()
		parent.add_child(explosion_instance)
		explosion_instance.global_position = hit_position
		explosion_instance.z_index = 1
		var particles = explosion_instance.get_node("CPUParticles2D") as CPUParticles2D
		if particles:
			particles.emitting = true
