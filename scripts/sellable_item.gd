extends Control
class_name SellableItem

@export var item : Item

var index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/ItemHoverable.item_resource = item
	$HBoxContainer/Button.connect("pressed", func():
		GameState.remove_item(index)
	)
