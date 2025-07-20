extends Node2D

class_name Enemy

@onready var falling_spawner: FallingProjectileSpawner = $enemy_component/FallingProjectileSpawner

func start_shooting():
	$enemy_component.start_shooting()
	if falling_spawner:
		falling_spawner.start_spawning()

func stop_shooting():
	$enemy_component.stop_shooting()
	if falling_spawner:
		falling_spawner.stop_spawning()

func damage(value : int):
	$enemy_component.damage(value)
	
func die():
	$enemy_component.die()

func get_component() -> EnemyComponent:
	return $enemy_component
	
func get_sprite() -> Sprite2D:
	return $Sprite2D

func delete_visuals() -> void:
	$Sprite2D.queue_free()
	$enemy_component.cleanse()
	if falling_spawner:
		falling_spawner.queue_free()

func setup_falling_projectiles(projectile_scene: PackedScene):
	if falling_spawner:
		falling_spawner.setup_spawner(projectile_scene)
