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
	_tween = Tween.new()
	add_child(_tween)
	_tween.connect("tween_all_completed", self, "_on_tween_complete")

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _RotTween() -> void:
	_tween.remove_all()
	var todeg = rotation_degrees + _degrees_per_second
	_tween.interpolate_property(self, "rotation_degrees", rotation_degrees, todeg, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.start()

# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_tween_complete() -> void:
	if _degrees_per_second != 0.0:
		_RotTween()

func _on_gyro(dps : float) -> void:
	_degrees_per_second = dps
	if dps != 0:
		_RotTween()
