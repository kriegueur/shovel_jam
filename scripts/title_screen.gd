extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Play.connect("pressed", func():
		get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
	)
	$Play.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
