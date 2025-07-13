extends Enemy

@onready var SHOT_DIRS : Array[Vector2] = [Vector2.LEFT, Vector2.LEFT.rotated(PI/20), Vector2.LEFT.rotated(-PI/20)]

func _ready() -> void:
	$enemy_component.set_shot_dirs(SHOT_DIRS)
