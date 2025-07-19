extends CharacterBody2D

class_name Player

enum PlayerState {
	WAIT,
	MOVE,
	DASHING,
	PARRYING,
	SHIELD,
	RECOVERY
}

signal player_hit(percent: float)
signal projectile_parried(projectile, direction_to_sender)

var state : PlayerState = PlayerState.WAIT

const SPEED = 200
const RECOVERY_SPEED = 100
const DASH_SPEED = 600
const DASH_DURATION = 0.3
const DASH_COOLDOWN = 1.5

const PARRY_FRAME = 3
const SHIELD_DAMAGE_REDUCTION = 0.2
const PARRY_COOLDOWN = 2.0

const RECOVERY_FRAMES = 60
const RECOVERY_BLINK_FRAMES = 8

var dash_direction : Vector2 = Vector2.ZERO
var dash_timer : float = 0.0
var dash_cooldown_timer : float = 0.0
var can_dash : bool = true

var parry_frame_count: int = 0
var parry_cooldown_timer : float = 0.0
var can_parry: bool = true
var last_enemy_position: Vector2

var recovery_frames_remaining = 0
var recovery_blink_counter = 0
var is_invulnerable: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$hurtbox.connect("area_entered", func(area : Area2D):
		handle_hit(area)
	)
	dash_setup()
	parry_setup()

func handle_hit(area: Area2D):
	if is_invulnerable and state != PlayerState.PARRYING:
		return
		
	var projectile_component = area.get_parent() as ProjectileComponent
	var damage : int
	
	match state:
		PlayerState.PARRYING:
			parry_projectile(area)
		PlayerState.SHIELD:
			if projectile_component != null:
				damage = projectile_component.DAMAGE
			else:
				damage = 20
				print("WARNING projectile did not have projectile component")
			player_hit.emit(round(damage * SHIELD_DAMAGE_REDUCTION * GameState.shield_efficiency_multiplier))
			start_recovery()
			destroy_projectile(projectile_component)
		_:
			if projectile_component != null:
				damage = projectile_component.DAMAGE
			else:
				damage = 20
				print("WARNING projectile did not have projectile component")
			player_hit.emit(damage)
			start_recovery()
			destroy_projectile(projectile_component)

func destroy_projectile(projectile_node: ProjectileComponent):
	if projectile_node != null and is_instance_valid(projectile_node):
		projectile_node.destroy_projectile(projectile_node.global_position)


func parry_projectile(projectile_area: Area2D):
	var projectile_component : ProjectileComponent = projectile_area.get_parent()
	projectile_component.return_to_sender()
	print("PARRY1")

func start_parry():
	if not can_parry or state == PlayerState.DASHING:
		return
	
	state = PlayerState.PARRYING
	parry_frame_count = 0
	velocity = Vector2.ZERO
	$Shield.visible = true
	$Shield.modulate = Color(1, 1, 1, 0.8)
	
	var tween = create_tween()
	tween.tween_property($Shield, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1)
	tween.tween_property($Shield, "modulate", Color(1, 1, 1, 0.8), 0.1)

func update_parry_state():
	parry_frame_count += 1
	if parry_frame_count >= PARRY_FRAME:
		state = PlayerState.SHIELD
		$Shield.modulate = Color(0.8, 0.8, 1.0, 0.6)


func stop_parry():
	if state == PlayerState.PARRYING or state == PlayerState.SHIELD:
		state = PlayerState.MOVE
		$Shield.visible = false
		can_parry = false

func dash_setup():
	$DashCooldownBar.min_value = 0
	$DashCooldownBar.max_value = DASH_COOLDOWN
	$DashCooldownBar.value = DASH_COOLDOWN

func parry_setup():
	$ParryCooldown.min_value = 0
	$ParryCooldown.max_value = PARRY_COOLDOWN * GameState.parry_cooldown_multiplier
	$ParryCooldown.value = PARRY_COOLDOWN * GameState.parry_cooldown_multiplier

func show_dash_progressbar(delta: float) -> void:
	if not can_dash:
		dash_cooldown_timer += delta
		$DashCooldownBar.value = dash_cooldown_timer
		$DashCooldownBar.visible = true
		
		if dash_cooldown_timer >= DASH_COOLDOWN:
			can_dash = true
			dash_cooldown_timer = 0.0
			$DashCooldownBar.visible = false

func show_parry_progressbar(delta: float) -> void:
	if not can_parry:
		parry_cooldown_timer += delta
		$ParryCooldown.value = parry_cooldown_timer
		$ParryCooldown.visible = true
		
		if parry_cooldown_timer >= PARRY_COOLDOWN:
			can_parry = true
			parry_cooldown_timer = 0.0
			$ParryCooldown.visible = false

func movement_handler(delta: float) -> void:
	var input_vector = Input.get_vector("left","right","up","down")
	velocity = input_vector * SPEED * GameState.speed_multiplier
	if Input.is_action_just_pressed("dash") and can_dash and input_vector != Vector2.ZERO:
		start_dash(input_vector.normalized())
	if Input.is_action_just_pressed("parry&shield") and can_parry:
		start_parry()
		return
	move_and_slide()

func parrying_handler(delta: float):
	velocity = Vector2.ZERO
	update_parry_state()
	if Input.is_action_just_released("parry&shield"):
		stop_parry()

func shielding_handler(delta: float):
	velocity = Vector2.ZERO
	if Input.is_action_just_released("parry&shield"):
		stop_parry()

func dashing_handler(delta: float):
	dash_timer += delta
	if dash_timer >= DASH_DURATION * GameState.dash_duration_multiplier:
		stop_dash()
		return
	
	var dash_progress = dash_timer / (DASH_DURATION * GameState.dash_duration_multiplier)
	var dash_intensity = 1.0 - (dash_progress * dash_progress)
	velocity = dash_direction * DASH_SPEED * dash_intensity
	move_and_slide()

func start_dash(direction: Vector2):
	if (state == PlayerState.RECOVERY):
		stop_recovery()
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

# make directly an element rather that manually shit like I did
func create_dash_effect():
	var particles = CPUParticles2D.new()
	add_child(particles)
	
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = DASH_DURATION
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
	
	particles.one_shot = true

func start_recovery():
	if state == PlayerState.RECOVERY or state == PlayerState.SHIELD:
		return
	
	state = PlayerState.RECOVERY
	recovery_frames_remaining = RECOVERY_FRAMES
	recovery_blink_counter = RECOVERY_BLINK_FRAMES
	is_invulnerable = true
	
func update_recovery_state():
	recovery_blink_counter += 1
	recovery_frames_remaining -= 1
	if recovery_blink_counter >= RECOVERY_BLINK_FRAMES:
		recovery_blink_counter = 0
		modulate.a = 1.0 - modulate.a
	if recovery_frames_remaining <= 0:
		stop_recovery()

func stop_recovery():
	state = PlayerState.MOVE
	is_invulnerable = false
	recovery_blink_counter = 0
	recovery_frames_remaining = 0
	modulate.a = 1.0

func recovery_handler(delta: float):
	update_recovery_state()
	
	var input_vector = Input.get_vector("left","right","up","down")
	velocity = input_vector * RECOVERY_SPEED * GameState.speed_multiplier * 0.7
	
	if Input.is_action_just_pressed("dash") and can_dash and input_vector != Vector2.ZERO:
		stop_recovery()
		start_dash(input_vector.normalized())
		return
		
	if Input.is_action_just_pressed("parry&shield") and can_parry:
		stop_recovery()
		start_parry()
		return
		
	move_and_slide()

func _physics_process(delta: float) -> void:
	show_dash_progressbar(delta)
	show_parry_progressbar(delta)
	
	match state:
		PlayerState.MOVE:
			movement_handler(delta)
		PlayerState.DASHING:
			dashing_handler(delta)
		PlayerState.PARRYING:
			parrying_handler(delta)
		PlayerState.SHIELD:
			shielding_handler(delta)
		PlayerState.RECOVERY:
			recovery_handler(delta)
		_:
			pass

func reset_dash():
	$DashCooldownBar.value = DASH_COOLDOWN * GameState.dash_cooldown_multiplier
	$DashCooldownBar.visible = false
	dash_direction = Vector2.ZERO
	dash_timer = 0.0
	dash_cooldown_timer = 0.0
	can_dash = true
	
func reset_parry():
	can_parry = true
	parry_cooldown_timer = 0.0
	parry_frame_count = 0
	$Shield.visible = false
	$ParryCooldown.value = PARRY_COOLDOWN
	$ParryCooldown.visible = false

func start_moving():
	state = PlayerState.MOVE

func stop_moving():
	stop_recovery()

	state = PlayerState.WAIT
	reset_dash()
	reset_parry()
