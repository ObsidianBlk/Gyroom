extends Node2D
class_name GyroMap


# --------------------------------------------------
# Variables
# --------------------------------------------------
var _degrees_per_second : float = 0.0
var _tween : Tween = null

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _ready() -> void:
	_tween = Tween.instance()
	add_child(_tween)
	_tween.connect("tween_all_completed", self, "_on_tween_complete")

# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_tween_complete() -> void:
	if _degrees_per_second 

func _on_gyro(dps : float) -> void:
	rotation_degrees += dps
