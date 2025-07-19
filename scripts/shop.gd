extends Control

const HEAL_PRICE = 1

@onready var balance_label: Label = $Balance
@onready var exit_button: Button = $Exit
@onready var heal_button: Button = $Heal
@onready var inventory_display: VBoxContainer = $InventoryDisplay

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
		sellable.custom_minimum_size = item.texture.get_size()
		inventory_display.add_child(sellable)
	set_inventory_indexes()
	GameState.connect("inventory_changed", func(adding : bool, index : int):
		if adding:
			var sellable :SellableItem = inventoryItem.instantiate()
			sellable.item = GameState.inventory[index]
			sellable.custom_minimum_size = GameState.inventory[index].texture.get_size()
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
		GameState.cash -= value
		return true
