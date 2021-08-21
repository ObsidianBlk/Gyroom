extends KinematicBody2D
class_name Player

# --------------------------------------------------
# Signals
# --------------------------------------------------
signal use

# --------------------------------------------------
# Variables
# --------------------------------------------------

var up_normal : Vector2 = Vector2.UP

var speed = 120
var jump_speed = 200#180
var gravity = 588
var acceleration = 0.25
var friction = 0.1

var velocity : Vector2 = Vector2.ZERO
var jump : bool = false
var directionals = [0, 0]

var _gravity_enabled : bool = true

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _unhandled_input(event):
	if event.is_action_pressed("Left", false):
		directionals[0] = -1
	elif event.is_action_released("Left"):
		directionals[0] = 0
	
	if event.is_action_pressed("Right", false):
		directionals[1] = 1
	elif event.is_action_released("Right"):
		directionals[1] = 0
	
	if event.is_action_pressed("Up", false):
		emit_signal("use")
	
	if event.is_action_pressed("Jump", false):
		jump = true

func _physics_process(delta : float) -> void:
	_UpdateVelocity(delta)
	velocity = move_and_slide(velocity, up_normal, true, 2, 0.349066)
	if jump:
		jump = false
		if is_on_floor():
			velocity.y -= jump_speed

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _GetDirection() -> float:
	return directionals[0] + directionals[1]

func _UpdateVelocity(delta : float) -> void:
	var dir = _GetDirection()
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)
	velocity.y += gravity * delta if _gravity_enabled else 0

# --------------------------------------------------
# Public Methods
# --------------------------------------------------

func lock_controls(lock : bool = true) -> void:
	if lock:
		directionals = [0,0]
		set_process_unhandled_input(false)
	else:
		set_process_unhandled_input(true)


func enable_gravity(enable : bool = true) -> void:
	_gravity_enabled = enable
