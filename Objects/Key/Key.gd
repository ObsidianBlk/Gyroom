extends Node2D
tool
class_name Key


# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export var key_name : String = ""
export var key_color : Color = Color(1,1,1)				setget set_key_color
export (float, 0.0, 10.0) var max_height = 4.0
export (float, 0.0, 10.0) var frequency = 1.0
export var float_curve : Curve = null

# --------------------------------------------------
# Variables
# --------------------------------------------------
var _time : float = 0.0

# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var sprite_node = get_node("Sprite")
onready var light_node = get_node("Light2D")


# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------
func set_key_color(c : Color) -> void:
	key_color = c
	_UpdateSprite()

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _process(delta : float) -> void:
	if frequency > 0.0:
		_time += delta
		if _time >= frequency:
			_time -= frequency
		
		if float_curve != null and sprite_node:
			sprite_node.position.y = -_GetHeight()


# --------------------------------------------------
# Private Methods
# --------------------------------------------------
func _GetHeight() -> float:
	if float_curve != null:
		return float_curve.interpolate(_time / frequency) * max_height
	return 0.0

func _UpdateSprite() -> void:
	if not sprite_node:
		sprite_node = get_node_or_null("Sprite")
	if sprite_node:
		sprite_node.modulate = key_color
	
	if not light_node:
		light_node = get_node_or_null("Light2D")
	if light_node:
		light_node.color = key_color

func _Free() -> void:
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()


# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_body_entered(body):
	if not visible:
		return
	
	if key_name != "" and body.has_method("give_item"):
		body.give_item(key_name)
		visible = false
		var audio = get_node_or_null("AudioSFX")
		if audio:
			audio.play()


func _on_AudioSFX_finished():
	_Free()
