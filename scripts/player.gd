extends CharacterBody2D

class_name Player

enum PlayerState {
	WAIT,
	MOVE,
	DASHING
}

signal player_hit

var state : PlayerState = PlayerState.WAIT

const SPEED = 200
const DASH_SPEED = 600
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 2.0

var dash_direction : Vector2 = Vector2.ZERO
var dash_timer : float = 0.0
var dash_cooldown_timer : float = 0.0
var can_dash : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$hurtbox.connect("area_entered", func(area : Area2D):
		player_hit.emit()
	)
	$DashCooldownBar.min_value = 0
	$DashCooldownBar.max_value = DASH_COOLDOWN
	$DashCooldownBar.value = DASH_COOLDOWN
	

func show_dash_progressbar(delta: float) -> void:
	if not can_dash:
		dash_cooldown_timer += delta
		$DashCooldownBar.value = dash_cooldown_timer
		$DashCooldownBar.visible = true
		
		if dash_cooldown_timer >= DASH_COOLDOWN:
			can_dash = true
			dash_cooldown_timer = 0.0
			$DashCooldownBar.visible = false

func movement_handler(delta: float) -> void:
	var input_vector = Input.get_vector("left","right","up","down")
	velocity = input_vector * SPEED
	if Input.is_action_just_pressed("dash") and can_dash and input_vector != Vector2.ZERO:
		start_dash(input_vector.normalized())
	move_and_slide()

func dashing_handler(delta: float):
	dash_timer += delta
	if dash_timer >= DASH_DURATION:
		stop_dash()
		return
	
	var dash_progress = dash_timer / DASH_DURATION
	var dash_intensity = 1.0 - (dash_progress * dash_progress)
	velocity = dash_direction * DASH_SPEED * dash_intensity
	move_and_slide()

func start_dash(direction: Vector2):
	state = PlayerState.DASHING
	dash_direction = direction
	dash_timer = 0.0
	can_dash = false
	dash_cooldown_timer = 0.0
	create_dash_effect()
	
func stop_dash():
	state = PlayerState.MOVE
	dash_timer = 0.0
	velocity = Vector2.ZERO

func create_dash_effect():
	var particles = CPUParticles2D.new()
	add_child(particles)
	
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = 0.5
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	
	var angle_spread = PI / 6
	particles.direction = Vector2(dash_direction.x, dash_direction.y)
	particles.spread = angle_spread * 180 / PI
	
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.0
	particles.color = Color(0.5, 0.8, 1.0, 0.8)
	
	particles.gravity = Vector2(0, 98)
	particles.linear_accel_min = -50.0
	particles.linear_accel_max = -30.0
		
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(func(): 
		particles.queue_free()
		timer.queue_free()
	)
	timer.start()

func _physics_process(delta: float) -> void:
	show_dash_progressbar(delta)
	match state:
		PlayerState.MOVE:
			movement_handler(delta)
		PlayerState.DASHING:
			dashing_handler(delta)
		_:
			pass

func start_moving():
	state = PlayerState.MOVE

func stop_moving():
	state = PlayerState.WAIT
