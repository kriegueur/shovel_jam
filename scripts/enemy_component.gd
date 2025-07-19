extends Node2D
class_name EnemyComponent

@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var enemy_canvas: Sprite2D = get_parent().get_sprite()

@export var shooting_point : Vector2 = Vector2(-68, 0)
@export var shot_interval_max : float = 1.2
@export var shot_interval_min : float = 0.8
@export var projectile : PackedScene
@export var shoot_towards_player : bool = true
@export var bullets_per_shot : int = 1
@export var time_offset : float = 0.0

@export var death_particle : PackedScene
@export var hit_blinking_duration: float = 0.5
@export var hit_blink_speed: float = 0.1
var is_blinking: bool = false
var original_color_modulate: Color

@export var max_health : float = 100.0
var current_health : int
@onready var health_bar : ProgressBar

signal enemy_died
signal health_changed(new_health: int, max_health: int)

var SHOT_DIRS : Array[Vector2] = [Vector2.LEFT]
var current_shot = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_color_modulate = enemy_canvas.self_modulate
	var random = RandomNumberGenerator.new()
	timer.wait_time = random.randf_range(shot_interval_min, shot_interval_max)
	timer.one_shot = false
	var player
	var shot_point : Vector2 = shooting_point + global_position
	if shoot_towards_player:
		player = get_tree().get_first_node_in_group("player")
	timer.connect("timeout", func():
		var angle_to_player : float = 0.0
		if shoot_towards_player:
			var dir_to_player = (global_position - player.global_position)
			angle_to_player = dir_to_player.angle()
		for i in range(bullets_per_shot):
			var proj : Projectile = projectile.instantiate()
			proj.startPos = shot_point
			proj.dir = SHOT_DIRS[current_shot].rotated(angle_to_player)
			current_shot = (current_shot+1)%len(SHOT_DIRS)
			add_child(proj)
	)
	current_health = max_health
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	progress_bar.min_value = 0.0
	
	$hurtbox.connect("area_entered", func(area : Area2D):
		handle_hit(area)
	)
	
func handle_hit(area: Area2D):
	var projectile_component = area.get_parent() as ProjectileComponent
	var damage : int
	if projectile_component != null:
		damage = projectile_component.DAMAGE
	else:
		damage = 20
		print("WARNING projectile did not have projectile component")
		if projectile_component != null:
			damage = projectile_component.DAMAGE
		else:
			damage = 20
			print("WARNING projectile did not have projectile component")
	take_damage(damage * 0.5)
	start_hit_blink()
	projectile_component.destroy_projectile(area.global_position)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(damage: int):
	current_health = max(0, current_health - damage)
	progress_bar.value = current_health
	health_changed.emit(current_health, max_health)
	start_hit_blink()
	if current_health <= 0:
		die()

func die():
	stop_shooting()
	enemy_died.emit()

func play_death_particles():
	if death_particle:
		var death_particle_instance = death_particle.instantiate()
		add_child(death_particle_instance)
		var particles = death_particle_instance.get_node("CPUParticles2D")
		if particles:
			particles.emitting = true
			particles.one_shot = true
			print("should display particles")

func start_shooting():
	get_tree().create_timer(time_offset).connect("timeout", func():
		timer.start()
	)

func start_hit_blink():
	if is_blinking or current_health <= 0:
		return
	is_blinking = true
	var tween = create_tween()
	tween.set_loops(int(hit_blinking_duration / (hit_blink_speed * 2)))
	tween.tween_property(enemy_canvas, "self_modulate", Color.RED, hit_blink_speed)
	tween.tween_property(enemy_canvas, "self_modulate", original_color_modulate, hit_blink_speed)
	tween.connect("finished", func():
		is_blinking = false
		enemy_canvas.self_modulate = original_color_modulate
	)

func stop_shooting():
	timer.stop()
	var children = get_children(true)
	for child in children:
		if child is Projectile:
			child.queue_free()

func set_shot_dirs(dirs: Array[Vector2]):
	SHOT_DIRS = dirs

#Generic function for taking damage ?
func damage(damage: int):
	take_damage(damage)
