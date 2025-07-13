extends CharacterBody2D

class_name Player

enum PlayerState {
	WAIT,
	MOVE
}

var state : PlayerState = PlayerState.WAIT

const SPEED = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	match state:
		PlayerState.MOVE:
			var input_vector = Input.get_vector("left","right","up","down")
			velocity = input_vector * SPEED
			move_and_slide()
		_:
			pass

func start_moving():
	state = PlayerState.MOVE

func stop_moving():
	state = PlayerState.WAIT
