extends Node2D

enum GameStates {
	CHOICE,
	PLAYERATTACK,
	ENEMYATTACK,
}

var state : GameStates = GameStates.CHOICE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/PlayerActionsContainer/Attack.grab_focus()
	$UI/PlayerActionsContainer/Attack.connect("pressed",func ():
		$Player.start_moving()
		$UI.hide()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
