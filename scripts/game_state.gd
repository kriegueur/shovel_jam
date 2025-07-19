extends Node

signal cash_changed
signal inventory_changed # True if adding to inventory

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

var inventory : Array[Item] = []
const INVENTORY_SIZE = 8

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

func can_purchase(item : Item) -> bool:
	return (
		cash >= item.price and
		len(inventory) < 8
	)

func add_item(item : Item):
	inventory.append(item)
	inventory_changed.emit(true, len(inventory) - 1)
	for itemeffect : ItemEffect in item.effects:
		match itemeffect.type:
			ItemEffect.EffectType.ATTACK:
				damage_addon += round(itemeffect.value)
				player_damage = BASE_DAMAGE + damage_addon
			ItemEffect.EffectType.MAXHP:
				hp_addon += round(itemeffect.value)
				max_hp = BASE_HP + hp_addon
				player_hp += round(itemeffect.value)
			ItemEffect.EffectType.MAXMANA:
				mana_addon += round(itemeffect.value)
				max_mana = BASE_MANA + mana_addon
				player_mana += round(itemeffect.value)
			ItemEffect.EffectType.SPEED:
				speed_multiplier += itemeffect.value
			ItemEffect.EffectType.DASHCOOLDOWN:
				dash_cooldown_multiplier += itemeffect.value
			ItemEffect.EffectType.DASHDURATION:
				dash_duration_multiplier += itemeffect.value
			ItemEffect.EffectType.SHIELD:
				shield_efficiency_multiplier += itemeffect.value
			ItemEffect.EffectType.PARRYCOOLDOWN:
				parry_cooldown_multiplier += itemeffect.value

func pay(price : int):
	cash -= price
	cash_changed.emit(cash)

func remove_item(index : int):
	var item : Item = inventory.pop_at(index)
	cash += item.price / 2
	inventory_changed.emit(false, index)
	cash_changed.emit(cash)
