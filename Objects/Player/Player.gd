extends KinematicBody2D


var up_normal : Vector2 = Vector2.UP

var speed = 600
var jump_speed = 1000
var gravity = 800
var acceleration = 0.25
var friction = 0.1

var velocity : Vector2 = Vector2.ZERO
var jump : bool = false

func getInput() -> void:
	var dir = 0
	if Input.is_action_pressed("Left"):
		dir += -1
	if Input.is_action_pressed("Right"):
		dir += 1
	if Input.is_action_just_pressed("Jump"):
		jump = true
	
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)

func _physics_process(delta : float) -> void:
	getInput()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, up_normal, true)
	if jump:
		jump = false
		if is_on_floor():
			velocity.y -= jump_speed
