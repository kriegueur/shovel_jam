extends Node

const STARTING_WORLD : int = 1
var current_world : int = STARTING_WORLD

const STARTING_CASH : int = 0
var cash : int = STARTING_CASH
const INTEREST_RATE : float = 1.2

const CASHPRIZES : Array[int] = [5]

var player_damage = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func cash_reward():
	var world_index
	if current_world > len(CASHPRIZES):
		world_index = len(CASHPRIZES) - 1
	else:
		world_index = current_world - 1
	var gain = CASHPRIZES[world_index]
	var interest_gain : int = ceil(cash * INTEREST_RATE) - cash
	print(gain)
	print(interest_gain)
	cash += gain
	cash += interest_gain
