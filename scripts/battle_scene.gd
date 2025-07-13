extends Node2D

const MOB_GROUPS = {
	"world1" : [
		["tri_shot"],
		["simple_shot", "simple_shot"]
	]
}

var rng = RandomNumberGenerator.new()
var enemies = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_enemies()
	$UI/PlayerActionsContainer/Attack.grab_focus()
	$UI/PlayerActionsContainer/Attack.connect("pressed",func ():
		$Timer.start()
		$Player.start_moving()
		for enemy in enemies:
			enemy.start_shooting()
		$UI.hide()
	)
	$Timer.connect("timeout", func():
		for enemy in enemies:
			enemy.stop_shooting()
		$UI.show()
		$UI/PlayerActionsContainer/Attack.grab_focus()
		$Player.stop_moving()
	)
	$Player.connect("player_hit", func():
		print("player loses HP TODO")
	)

func init_enemies():
	var current_world = GameState.current_world
	var possible_groups = MOB_GROUPS["world" + str(current_world)]
	var chosen_group = rng.randi_range(0,len(possible_groups) - 1)
	var positions = []
	match len(possible_groups[chosen_group]):
		1:
			positions.append($Spawnpoints/Middle.global_position)
		2:
			positions.append($Spawnpoints/Top.global_position - ($Spawnpoints/Top.global_position-$Spawnpoints/Middle.global_position)/2)
			positions.append($Spawnpoints/Bottom.global_position - ($Spawnpoints/Bottom.global_position-$Spawnpoints/Middle.global_position)/2)
		3:
			positions.append($Spawnpoints/Top)
			positions.append($Spawnpoints/Middle)
			positions.append($Spawnpoints/Bottom)
		_:
			print("extreme error")
	var i = 0
	for enemy in possible_groups[chosen_group]:
		var enemy_scene : PackedScene = load("res://scenes/enemies/" + enemy + ".tscn")
		var spawned = enemy_scene.instantiate()
		spawned.global_position = positions[i]
		add_child(spawned)
		enemies.append(spawned)
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
