extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/PlayerActionsContainer/Attack.grab_focus()
	$UI/PlayerActionsContainer/Attack.connect("pressed",func ():
		$Timer.start()
		$Player.start_moving()
		$Ennemy.start_shooting()
		$UI.hide()
	)
	$Timer.connect("timeout", func():
		$Ennemy.stop_shooting()
		$UI.show()
		$UI/PlayerActionsContainer/Attack.grab_focus()
		$Player.stop_moving()
	)
	$Player.connect("player_hit", func():
		print("player loses HP TODO")
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
