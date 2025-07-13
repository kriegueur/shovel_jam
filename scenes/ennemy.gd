extends Node2D

var current_bullets = []

@onready var projectile = load("res://scenes/projectile.tscn")

@onready var SHOT_DIRS = [Vector2.LEFT, Vector2.LEFT.rotated(PI/20), Vector2.LEFT.rotated(-PI/20)]
var current_shot = 0

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	$Timer.connect("timeout", func():
		var dir_to_player : Vector2 = (global_position - player.global_position)
		for i in range(3):
			var proj = projectile.instantiate()
			proj.startPos = $shooting_point.global_position
			proj.dir = SHOT_DIRS[current_shot].rotated(dir_to_player.angle())
			current_shot = (current_shot+1)%len(SHOT_DIRS)
			add_child(proj)
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_shooting():
	$Timer.start()

func stop_shooting():
	$Timer.stop()
	var children = get_children(true)
	for child in children:
		if child is projectile:
			child.queue_free()
