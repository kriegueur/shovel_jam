extends Node2D
class_name FallingProjectileSpawner

@export var projectile_scene: PackedScene
@export var spawn_interval: float = 0.2
@export var spawn_width: float = 450.0
@export var spawn_x_min: float = 150.0

@export var fall_speed: float = 300.0
@export var warning_duration: float = 3.0

@onready var spawn_timer: Timer = $Timer
var warning_line_scene: PackedScene = preload("res://scenes/warning_light.tscn")
var is_spawning: bool = false

func _ready():
	setup_timer()

func setup_timer():
	if not spawn_timer:
		spawn_timer = Timer.new()
		add_child(spawn_timer)
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", spawn_falling_projectile)

func setup_spawner(proj_scene: PackedScene):
	projectile_scene = proj_scene

func start_spawning():
	if projectile_scene and not is_spawning:
		is_spawning = true
		spawn_timer.start()

func stop_spawning():
	is_spawning = false
	spawn_timer.stop()

func spawn_falling_projectile():
	if not is_spawning or not projectile_scene:
		return
	var spawn_x = randf_range(spawn_x_min, spawn_x_min + spawn_width)
	var warning_pos = Vector2(spawn_x, 0)
	var spawn_pos = Vector2(spawn_x, 0)
	
	show_warning_at(warning_pos)
	get_tree().create_timer(warning_duration).connect("timeout", func():
		if is_spawning:
			create_falling_projectile(spawn_pos)
	)

func show_warning_at(pos: Vector2):
	var warning = warning_line_scene.instantiate()
	get_parent().add_child(warning)
	warning.global_position = pos
	warning.show_warning(warning_duration)

func create_falling_projectile(spawn_pos: Vector2):
	var proj = projectile_scene.instantiate()
	if proj.has_method("set_start_position"):
		proj.set_start_position(spawn_pos)
	else:
		proj.startPos = spawn_pos
	proj.dir = Vector2.DOWN
	get_parent().add_child(proj)
