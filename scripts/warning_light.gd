extends Node2D
class_name WarningLine

@onready var line: Line2D = $Line2D

@export var warning_color: Color = Color.YELLOW
@export var danger_color: Color = Color.RED
@export var line_width: float = 8.0
@export var line_length: float = 1000.0
@export var blink_speed: float = 1.0
@export var particle_intensity: float = 50.0

var is_warning: bool = false
var warning_tween: Tween

func _ready():
	setup_line()
	visible = false

func setup_line():
	line.width = line_width
	line.default_color = warning_color
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2(0, line_length))

func show_warning(duration: float):
	if is_warning:
		return
	
	is_warning = true
	visible = true
	
	warning_tween = create_tween()
	warning_tween.set_loops(int(duration / (blink_speed * 2)))
	warning_tween.tween_method(blink_warning, 0.0, 1.0, blink_speed)
	warning_tween.tween_method(blink_warning, 1.0, 0.0, blink_speed)
	var intensify_timer = duration * 0.7
	get_tree().create_timer(intensify_timer).connect("timeout", intensify_warning)
	get_tree().create_timer(duration).connect("timeout", hide_warning)

func blink_warning(alpha: float):
	line.modulate.a = alpha

func intensify_warning():
	if not is_warning:
		return
		
	line.default_color = danger_color
	blink_speed *= 0.3
	
func hide_warning():
	is_warning = false
	visible = false
	
	if warning_tween:
		warning_tween.kill()
	
	get_tree().create_timer(2.0).connect("timeout", func(): queue_free())

func set_line_direction(direction: Vector2, length: float = -1):
	if length <= 0:
		length = line_length
	
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(direction.normalized() * length)
	
	var box_size = Vector3(line_width/2, length/2, 0)
	if abs(direction.x) > abs(direction.y):
		box_size = Vector3(length/2, line_width/2, 0)
