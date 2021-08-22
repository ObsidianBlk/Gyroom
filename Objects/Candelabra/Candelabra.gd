extends Node2D
tool

# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export var light_color : Color = Color(1,1,1)			setget set_light_color
export(float, 0.1, 10.0, 0.01) var base_energy = 1.0	setget set_base_energy
export(float, 0.1, 10.0, 0.01) var base_scale = 1.0		setget set_base_scale


# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var light_node = get_node("Light2D")

# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------

func set_light_color(c : Color) -> void:
	light_color = c
	_UpdateLightNode()

func set_base_energy(e : float) -> void:
	if e >= 0.1 and e <= 10.0:
		base_energy = e
		_UpdateLightNode()

func set_base_scale(s : float) -> void:
	if s >= 0.1 and s <= 10.0:
		base_scale = s
		_UpdateLightNode()



# --------------------------------------------------
# Private Methods
# --------------------------------------------------
func _UpdateLightNode() -> void:
	if not light_node:
		light_node = get_node_or_null("Light2D")
	if light_node:
		light_node.color = light_color
		light_node.base_scale = base_scale
		light_node.base_energy = base_energy



