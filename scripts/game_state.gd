extends Node

const STARTING_WORLD : int = 1
var current_world : int = STARTING_WORLD

const STARTING_CASH : int = 0
var cash : int = STARTING_CASH
const INTEREST_RATE : float = 1.2

const CASHPRIZES : Array[int] = [5]

const BASE_DAMAGE : int = 50
var damage_addon : int = 0
var player_damage : int = BASE_DAMAGE + damage_addon

const BASE_HP : int = 100
var hp_addon : int = 0
var max_hp : int = BASE_HP + hp_addon
var player_hp : int = max_hp

var speed_multiplier : float = 1.0

var dash_cooldown_multiplier : float = 1.0

var dash_duration_multiplier : float = 1.0

var shield_efficiency_multiplier : float = 1.0

var parry_cooldown_multiplier : float = 1.0

const BASE_MANA : int = 100
var mana_addon : int = 0
var max_mana : int = BASE_MANA + mana_addon
var player_mana : int = max_mana

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
