extends Control

@export var item_resource : Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/ItemHoverable.item_resource = item_resource
	$VBoxContainer/Button.connect("pressed", func():
		if GameState.can_purchase(item_resource):
			GameState.add_item(item_resource)
			GameState.pay(item_resource.price)
			queue_free()
	)
	$VBoxContainer/Button.text = "BUY : " + str(item_resource.price)
