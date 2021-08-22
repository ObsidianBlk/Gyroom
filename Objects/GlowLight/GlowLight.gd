extends Node2D
tool
class_name GlowLight


# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export var hide_base : bool = false							setget set_hide_base
export var base_color : Color = Color(1,1,1)				setget set_base_color
export var light_color : Color = Color(1,1,1)				setget set_light_color
export(float, 0.1, 10.0, 0.01) var light_base_energy = 1.0	setget set_light_base_energy
export(float, 0.1, 10.0, 0.01) var light_base_scale = 1.0	setget set_light_base_scale
export (float, 0.0, 10.0) var max_hover_height = 4.0
export (float, 0.0, 10.0) var hover_frequency = 4.0
export var hover_curve : Curve = null


# --------------------------------------------------
# Variables
# --------------------------------------------------
var _time : float = 0.0

# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var base_node = get_node("Base")
onready var gem_node = get_node("Light/Gem")
onready var light_node = get_node("Light/Light2D")
onready var light_contain_node = get_node("Light")


# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------

func set_hide_base(h : bool) -> void:
	hide_base = h
	_UpdateSprites()

func set_base_color(c : Color) -> void:
	base_color = c
	_UpdateSprites()

func set_light_color(c : Color) -> void:
	light_color = c
	_UpdateSprites()

func set_light_base_energy(e : float) -> void:
	if e > 0.0 and e < 10.0:
		light_base_energy = e
		_UpdateSprites()

func set_light_base_scale(s : float) -> void:
	if s > 0.0 and s < 10.0:
		light_base_scale = s
		_UpdateSprites()

# --------------------------------------------------
# Override Methods
# --------------------------------------------------
func _ready() -> void:
	_UpdateSprites()


func _process(delta : float) -> void:
	if hover_frequency >= 0.0:
		_time += delta
		if _time > hover_frequency:
			_time -= hover_frequency
		
		if not light_contain_node:
			light_contain_node = get_node_or_null("Light")
		if light_contain_node:
			light_contain_node.position.y = -_GetHeightUpdate()
	

# --------------------------------------------------
# Private Methods
# --------------------------------------------------
func _GetHeightUpdate() -> float:
	if hover_curve != null:
		return hover_curve.interpolate(_time / hover_frequency) * max_hover_height
	return 0.0


func _UpdateSprites() -> void:
	if not base_node:
		base_node = get_node_or_null("Base")
	if base_node:
		base_node.modulate = base_color
		base_node.visible = not hide_base
	
	if not gem_node:
		gem_node = get_node_or_null("Light/Gem")
	if gem_node:
		gem_node.modulate = light_color
	
	if not light_node:
		light_node = get_node_or_null("Light/Light2D")
	if light_node:
		light_node.color = light_color
		light_node.base_energy = light_base_energy
		light_node.base_scale = light_base_scale

