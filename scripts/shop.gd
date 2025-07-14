extends Control

@onready var balance_label: Label = $Balance
@onready var exit_button: Button = $Exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	balance_label.text = "Balance : " + str(GameState.cash)
	exit_button.connect("pressed", func():
		get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
