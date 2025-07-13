extends CharacterBody2D

const SPEED = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	var input_vector = Input.get_vector("left","right","up","down")
	velocity = input_vector * SPEED
	move_and_slide()
