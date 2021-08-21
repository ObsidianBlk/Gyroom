extends Area2D

# --------------------------------------------------
# Variables
# --------------------------------------------------

var _body_node : Player = null

# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var parent = get_parent()

# --------------------------------------------------
# Override Method
# --------------------------------------------------

func _ready() -> void:
	set_physics_process(false)
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _physics_process(delta : float) -> void:
	if _body_node != null:
		var uvec = Vector2.UP.rotated(parent.rotation)

# --------------------------------------------------
# Handler Method
# --------------------------------------------------

func _on_body_entered(body : Node2D) -> void:
	if body is Player and _body_node == null:
		_body_node = body
		set_physics_process(true)

func _on_body_exited(body : Node2D) -> void:
	if _body_node == body:
		set_physics_process(false)
		_body_node = null
