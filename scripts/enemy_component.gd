extends Node2D
class_name EnemyComponent

@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar


@export var shooting_point : Vector2 = Vector2(-68, 0)
@export var shot_interval : float = 1.0
@export var projectile : PackedScene
@export var shoot_towards_player : bool = true
@export var bullets_per_shot : int = 1
@export var time_offset : float = 0.0

@export var max_health : float = 100.0
var current_health : int
@onready var health_bar : ProgressBar

signal enemy_died
signal health_changed(new_health: int, max_health: int)

var SHOT_DIRS : Array[Vector2] = [Vector2.LEFT]
var current_shot = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = shot_interval
	timer.one_shot = false
	var player
	var shot_point = shooting_point + global_position
	if shoot_towards_player:
		player = get_tree().get_first_node_in_group("player")
	timer.connect("timeout", func():
		var angle_to_player : float = 0.0
		if shoot_towards_player:
			var dir_to_player = (global_position - player.global_position)
			angle_to_player = dir_to_player.angle()
		for i in range(bullets_per_shot):
			var proj = projectile.instantiate()
			proj.startPos = shot_point
			proj.dir = SHOT_DIRS[current_shot].rotated(angle_to_player)
			current_shot = (current_shot+1)%len(SHOT_DIRS)
			add_child(proj)
	)
	current_health = max_health
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	progress_bar.min_value = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(damage: int):
	current_health = max(0, current_health - damage)
	progress_bar.value = current_health
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		die()

func die():
	stop_shooting()
	enemy_died.emit()

func start_shooting():
	get_tree().create_timer(time_offset).connect("timeout", func():
		timer.start()
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
