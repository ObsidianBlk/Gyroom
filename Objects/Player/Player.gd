extends KinematicBody2D
class_name Player

# --------------------------------------------------
# Signals
# --------------------------------------------------
signal use
signal request_respawn
signal item_given(item_name, count)
signal item_taken(item_name, count)


const FOOTSTEPS = [
	preload("res://Assets/Audio/SFX/foot_step_001.wav"),
	preload("res://Assets/Audio/SFX/foot_step_002.wav"),
	preload("res://Assets/Audio/SFX/foot_step_003.wav")
]
const GRUNT = preload("res://Assets/Audio/SFX/grunt.wav")

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
var directionals = [0, 0, 0, 0]

var _gravity_enabled : bool = true


var _item_database = {}

# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var anim_node = get_node("Anim")
onready var audio_node = get_node("AudioSFX")

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
		if _gravity_enabled:
			emit_signal("use")
		else:
			directionals[2] = -1
	elif event.is_action_released("Up"):
		directionals[2] = 0
	
	if event.is_action_pressed("Down", false):
		if not _gravity_enabled:
			directionals[3] = 1
	elif event.is_action_released("Down"):
		directionals[3] = 0
	
	if event.is_action_pressed("Jump", false):
		jump = true


func _physics_process(delta : float) -> void:
	_UpdateVelocity(delta)
	velocity = move_and_slide(velocity, up_normal, true, 2, 0.349066)
	if global_position.y > 1000.0:
		emit_signal("request_respawn")
	
	if abs(velocity.x) < 6.0:
		velocity.x = 0.0
	if abs(velocity.y) < 1.0:
		velocity.y = 0.0
	_UpdateAnimations()
	
	if jump:
		jump = false
		if is_on_floor():
			velocity.y -= jump_speed
	_UpdateAudio()

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _UpdateAnimations() -> void:
	if abs(velocity.y) == 0.0:
		if abs(velocity.x) == 0.0:
			anim_node.play("idle")
		else:
			anim_node.play("run")
	else:
		if _gravity_enabled:
			if velocity.y < 0.0:
				if anim_node.current_animation != "jumping":
					anim_node.play("jumping")
			else:
				if anim_node.current_animation != "falling":
					anim_node.play("falling")
		else:
			if anim_node.current_animation != "climb":
				anim_node.play("climb")

func _UpdateAudio() -> void:
	match anim_node.current_animation:
		"run":
			if not audio_node.playing:
				var fsidx = floor(FOOTSTEPS.size() * randf())
				audio_node.stream = FOOTSTEPS[fsidx]
				audio_node.play()
		"jumping":
			if audio_node.stream != GRUNT:
				audio_node.stop()
				audio_node.stream = GRUNT
				audio_node.play()
		_:
			if not audio_node.playing:
				audio_node.stream = null


func _GetDirectionX() -> float:
	return directionals[0] + directionals[1]

func _GetDirectionY() -> float:
	return directionals[2] + directionals[3]

func _UpdateVelocity(delta : float) -> void:
	var dir = _GetDirectionX()
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)
	
	if _gravity_enabled:
		velocity.y += gravity * delta
	else:
		dir = _GetDirectionY()
		if dir != 0:
			velocity.y = lerp(velocity.y, dir * (speed*0.5), acceleration)
		else:
			velocity.y = lerp(velocity.y, 0, friction*2)

# --------------------------------------------------
# Public Methods
# --------------------------------------------------

func lock_controls(lock : bool = true) -> void:
	if lock:
		directionals = [0,0,0,0]
		set_process_unhandled_input(false)
	else:
		set_process_unhandled_input(true)


func enable_gravity(enable : bool = true) -> void:
	_gravity_enabled = enable


func give_item(item_name : String) -> void:
	if not item_name in _item_database:
		_item_database[item_name] = 0
	_item_database[item_name] += 1
	emit_signal("item_given", item_name, _item_database[item_name])

func take_item(item_name : String) -> void:
	if item_name in _item_database:
		_item_database[item_name] -= 1
		if _item_database[item_name] == 0:
			_item_database.erase(item_name)
			emit_signal("item_taken", item_name, 0)
		else:
			emit_signal("item_taken", item_name, _item_database[item_name])

func has_item(item_name : String) -> bool:
	return item_name in _item_database

