extends Control

const HEAL_PRICE = 1

@onready var balance_label: Label = $Balance
@onready var exit_button: Button = $Exit
@onready var heal_button: Button = $Heal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	balance_label.text = "Balance : " + str(GameState.cash)
	exit_button.connect("pressed", func():
		get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
	)
	heal_button.text = "Heal : " + str(HEAL_PRICE)
	heal_button.connect("pressed", func():
		if pay(HEAL_PRICE):
			print("TODO player healing")
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pay(value : int) -> bool:
	if GameState.cash < value:
		return false
	else:
		GameState.cash -= value
		balance_label.text = "Balance : " + str(GameState.cash)
		return true
