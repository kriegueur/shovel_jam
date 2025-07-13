extends Node2D

class_name Enemy

func start_shooting():
	$enemy_component.start_shooting()

func stop_shooting():
	$enemy_component.stop_shooting()
