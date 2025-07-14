extends Node2D

enum BattleState {
	ACTION_CHOICE,
	TARGET_CHOICE,
	ENEMY_TURN
}
var state : BattleState = BattleState.ACTION_CHOICE

const MOB_GROUPS = {
	"world1" : [
		["tri_shot"],
		["simple_shot", "simple_shot"]
	]
}

var rng = RandomNumberGenerator.new()
var enemies : Array[Enemy] = []
var current_target = 0

@onready var cursor: TextureRect = $UI/Cursor
@onready var player_actions: VBoxContainer = $UI/PlayerActionsContainer
@onready var attack_button: Button = $UI/PlayerActionsContainer/Attack
@onready var timer: Timer = $Timer
@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_enemies()
	start_action_choice()
	attack_button.connect("pressed", start_target_choice)
	timer.connect("timeout", stop_enemy_turn)
	player.connect("player_hit", func():
		print("player loses HP TODO")
	)

func _input(event: InputEvent) -> void:
	match state:
		BattleState.TARGET_CHOICE:
			if event.is_action_pressed("ui_up"):
				current_target = (current_target - 1)%len(enemies)
				_set_cursor_position()
			elif event.is_action_pressed("ui_down"):
				current_target = (current_target + 1)%len(enemies)
				_set_cursor_position()
			elif event.is_action_pressed("ui_accept"):
				enemies[current_target].damage(GameState.player_damage)
				start_enemy_turn()
			elif event.is_action_pressed("ui_cancel"):
				start_action_choice()
		_:
			pass

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
		var spawned : Enemy = enemy_scene.instantiate()
		spawned.global_position = positions[i]
		add_child(spawned)
		enemies.append(spawned)
		spawned.get_component().connect("enemy_died", func():
			enemy_died(spawned)
		)
		i += 1


func start_enemy_turn():
	state = BattleState.ENEMY_TURN
	timer.start()
	player.start_moving()
	for enemy in enemies:
		enemy.start_shooting()
	$UI.hide()

func start_target_choice():
	state = BattleState.TARGET_CHOICE
	for button : Button in player_actions.get_children():
		button.disabled = true
	attack_button.release_focus()
	_set_cursor_position()
	cursor.show()

func stop_enemy_turn():
	for enemy in enemies:
			enemy.stop_shooting()
	player.stop_moving()
	$UI.show()
	start_action_choice()

func start_action_choice():
	state = BattleState.ACTION_CHOICE
	cursor.hide()
	for button : Button in player_actions.get_children():
		button.disabled = false
	attack_button.grab_focus()

func _set_cursor_position():
	const cursor_offset : Vector2 = Vector2(-100, 0)
	cursor.global_position = enemies[current_target].global_position + cursor_offset

func enemy_died(enemy : Enemy):
	var enemy_index = enemies.find(enemy)
	enemies.remove_at(enemy_index)
	enemy.queue_free()
	if enemies.is_empty():
		battle_over()

func battle_over():
	GameState.cash_reward()
	get_tree().change_scene_to_file("res://scenes/shop.tscn")
