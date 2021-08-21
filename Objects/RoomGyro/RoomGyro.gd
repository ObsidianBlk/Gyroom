extends Node2D


# --------------------------------------------------
# Signals
# --------------------------------------------------
signal gyro(dps)

# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export (float, 0.0, 360.0) var max_degrees_per_second = 30.0
export (float, 0.01, 360.0) var acceleration = 30.0

# --------------------------------------------------
# Variables
# --------------------------------------------------
var _body_node : Player = null
var direction : int = 0
var dps : float = 0.0

# --------------------------------------------------
# Onready Variables
# --------------------------------------------------

onready var anim_node = get_node("Anim")

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _ready() -> void:
	set_process_unhandled_input(false)

func _unhandled_input(event):
	if event.is_action_released("Up"):
		direction = 0
		set_process_unhandled_input(false)
		if _body_node != null:
			_body_node.lock_controls(false)
	if event.is_action_pressed("Left", false):
		direction = -1
	if event.is_action_pressed("Right", false):
		direction = 1
	if event.is_action_released("Left") or event.is_action_released("Right"):
		direction = 0

func _process(delta : float) -> void:
	if direction != 0:
		if abs(dps) < max_degrees_per_second:
			dps += direction * acceleration * delta
			if abs(dps) > max_degrees_per_second:
				dps = direction * max_degrees_per_second
			print("UP: ", dps)
			emit_signal("gyro", dps)
			_UpdateAnimation()
	elif dps != 0.0:
		var dir = sign(dps)
		dps -= dir * acceleration * delta
		if sign(dps) != dir or abs(dps) < 0.001:
			dps = 0.0
		emit_signal("gyro", dps)
		_UpdateAnimation()

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _UpdateAnimation() -> void:
	var lowmid = max_degrees_per_second * 0.15
	var midfast = max_degrees_per_second * 0.5
	var fastvfast = max_degrees_per_second * 0.85
	
	var cdps = abs(dps)
	if cdps < 0.001:
		if anim_node.current_animation != "idle":
			anim_node.play("idle")
	elif cdps > 0.0 and cdps < lowmid:
		if anim_node.current_animation != "slow":
			anim_node.play("slow")
	elif cdps >= lowmid and cdps < midfast:
		if anim_node.current_animation != "medium":
			anim_node.play("medium")
	elif cdps >= midfast and cdps < fastvfast:
		if anim_node.current_animation != "fast":
			anim_node.play("fast")
	elif cdps >= fastvfast:
		if anim_node.current_animation != "vfast":
			anim_node.play("vfast")

# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_use_gyro() -> void:
	if _body_node != null:
		_body_node.lock_controls()
		set_process_unhandled_input(true)

func _on_body_entered(body):
	if body is Player and _body_node == null:
		_body_node = body
		_body_node.connect("use", self, "_on_use_gyro")


func _on_body_exited(body):
	if body == _body_node:
		_body_node.disconnect("use", self, "_on_use_gyro")
		direction = 0
		_body_node.lock_controls(false)
		_body_node = null


