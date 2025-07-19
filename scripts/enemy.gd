extends Node2D

class_name Enemy

func start_shooting():
	$enemy_component.start_shooting()

func stop_shooting():
	$enemy_component.stop_shooting()

func damage(value : int):
	$enemy_component.damage(value)
	
func die():
	$enemy_component.die()

func get_component() -> EnemyComponent:
	return $enemy_component
	
func get_sprite() -> Sprite2D:
	return $Sprite2D

func delete_sprite() -> void:
	$Sprite2D.queue_free()
