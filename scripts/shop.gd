extends Control

const HEAL_PRICE = 1
const REROLL_PRICE = 3

@onready var balance_label: Label = $Balance
@onready var exit_button: Button = $Exit
@onready var heal_button: Button = $Heal
@onready var inventory_display: VBoxContainer = $InventoryDisplay
@onready var reroll_button: Button = $Items/Reroll


const SHOP_WEIGHTS = {
	"biker_jacket": 2,
	"cool_boots": 2,
	"copper_crown": 2,
	"old_glove": 2,
	"purple_amulet": 1,
	"red_amulet": 2,
	"skateboard": 1,
	"stone_sword": 1,
	"sunglasses": 2,
	"wood_sword": 2
}

var inventoryItem : PackedScene = preload("res://scenes/sellable_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	balance_label.text = "Balance : " + str(GameState.cash)
	exit_button.connect("pressed", func():
		get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
	)
	heal_button.text = "Heal : " + str(HEAL_PRICE)
	heal_button.connect("pressed", func():
		if pay(HEAL_PRICE):
			GameState.player_hp = GameState.max_hp
			GameState.player_mana = GameState.max_mana
	)
	GameState.connect("cash_changed", func(cash : int):
		balance_label.text = "Balance : " + str(cash)
	)
	for item : Item in GameState.inventory:
		var sellable : SellableItem = inventoryItem.instantiate()
		sellable.item = item
		sellable.custom_minimum_size = item.texture.get_size() * 2
		inventory_display.add_child(sellable)
	set_inventory_indexes()
	GameState.connect("inventory_changed", func(adding : bool, index : int):
		if adding:
			var sellable :SellableItem = inventoryItem.instantiate()
			sellable.item = GameState.inventory[index]
			sellable.custom_minimum_size = GameState.inventory[index].texture.get_size() * 2
			sellable.index = len(GameState.inventory) - 1
			inventory_display.add_child(sellable)
		else:
			var deleted = false
			var i : int = 0
			for element : SellableItem in inventory_display.get_children(true):
				if i == index and !deleted:
					element.queue_free()
					deleted = true
				else:
					element.index = i
					i += 1
	)
	set_shop_items()
	reroll_button.connect("pressed", func():
		if pay(REROLL_PRICE):
			get_tree().reload_current_scene()
	)
	if GameState.current_battle >= GameState.WAVESPERWORLD:
		$Warning.show()

func set_inventory_indexes():
	var i : int = 0
	for element : SellableItem in inventory_display.get_children(true):
		element.index = i
		i += 1


func pay(value : int) -> bool:
	if GameState.cash < value:
		return false
	else:
		GameState.pay(value)
		return true

var total_weight : int = 0
var rng = RandomNumberGenerator.new()
func set_shop_items():
	if total_weight == 0:
		for item in SHOP_WEIGHTS.values():
			total_weight += item
	var keys = SHOP_WEIGHTS.keys()
	for buyable in $Items.get_children():
		if buyable is not BuyableItem:
			continue
		var choice =  rng.randi_range(0, total_weight - SHOP_WEIGHTS.values()[-1])
		var weight : int = 0
		var i = 0
		while weight < choice:
			weight += SHOP_WEIGHTS[keys[i]]
			i += 1
		var key : String = keys[i]
		var item : Item = load("res://Resources/Items/" + key + ".tres")
		buyable.item_resource = item
		buyable.init()
