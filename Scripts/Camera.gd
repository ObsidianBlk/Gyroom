extends Camera2D


# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export var target_path : NodePath = ""					setget set_target_path

# --------------------------------------------------
# Variables
# --------------------------------------------------
var target = null
var last_pos = Vector2.ZERO

# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------

func set_target_path(t : NodePath) -> void:
	target_path = t
	if t == "":
		target = null
		last_pos = Vector2.ZERO
		current = false
	else:
		var tn = get_node_or_null(target_path)
		if tn:
			target = tn
			current = true

func set_target(t : Node2D) -> void:
	if t != target:
		target = t
		if target != null:
			var np = target.get_path()
			target_path = np
			current = true
		else:
			target_path = ""
			last_pos = Vector2.ZERO
			current = false

func get_target() -> Node2D:
	return target

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _ready() -> void:
	if target_path != "":
		var tn = get_node_or_null(target_path)
		if tn:
			target = tn
			current = true

func _process(delta : float) -> void:
	if target != null and target.global_position != last_pos:
		last_pos = target.global_position
		global_position = last_pos


