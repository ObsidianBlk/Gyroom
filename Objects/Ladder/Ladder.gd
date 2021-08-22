tool
extends Node2D
class_name Ladder

# --------------------------------------------------
# Constants and ENUMS
# --------------------------------------------------
enum MODE {VERTICLE=0, HORIZONTAL=1}
enum GROW {LEFT=0, RIGHT=1}

const MID_LADDER_REGION = Rect2(16, 64, 16, 16)
const TOP_LADDER_REGION = Rect2(16, 48, 16, 16)

# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export var main_color : Color = Color(1,1,1)				setget set_main_color
export var support_color : Color = Color(1,1,1)				setget set_support_color
export (MODE) var mode = MODE.VERTICLE						setget set_mode
export (GROW) var grow = GROW.RIGHT							setget set_grow
export (int, 1, 32) var segments = 4						setget set_segments
export (float, 0.0, 1.0) var segment_extend_time = 0.2
export var extended : bool = false							setget set_extended

# --------------------------------------------------
# Variables
# --------------------------------------------------

var _spr_list = []

# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var _tween_node = get_node("Tween")
onready var _refsprite_node = get_node("Core/RefSprite")
onready var _hanchor_l_node = get_node("Core/HAnchor_L")
onready var _hanchor_r_node = get_node("Core/HAnchor_R")
onready var _vanchor_node = get_node("Core/VAnchor")
onready var _colshape_node = get_node("Area/ColShape")

# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------

func set_main_color(c : Color) -> void:
	main_color = c
	if _vanchor_node:
		_vanchor_node.modulate = c
	for spr in _spr_list:
		spr.modulate = c

func set_support_color(c : Color) -> void:
	support_color = c
	if _hanchor_l_node:
		_hanchor_l_node.modulate = c
	if _hanchor_r_node:
		_hanchor_r_node.modulate = c

func set_mode(m : int) -> void:
	mode = m
	if extended:
		_Extend()
	else:
		_PositionAnchors()

func set_grow(g : int) -> void:
	grow = g
	if extended:
		_Extend()
	else:
		_PositionAnchors()

func set_segments(s : int) -> void:
	if s >= 1 and s <= 32:
		segments = s
		if extended:
			_Extend()
		else:
			_PositionAnchors()

func set_extended(e : bool) -> void:
	extended = e
	if extended:
		_Extend()
	else:
		_RemoveSegements()

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _ready() -> void:
	if not Engine.editor_hint:
		set_main_color(main_color)
		set_support_color(support_color)
		_RemoveSegements()
		if extended:
			_Extend()
		else:
			_PositionAnchors()

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _CheckForNodes() -> void:
	if not _tween_node:
		_tween_node = get_node_or_null("Tween")
	if not _refsprite_node:
		_refsprite_node = get_node_or_null("Core/RefSprite")
	if not _hanchor_l_node:
		_hanchor_l_node = get_node_or_null("Core/HAnchor_L")
	if not _hanchor_r_node:
		_hanchor_r_node = get_node_or_null("Core/HAnchor_R")
	if not _vanchor_node:
		_vanchor_node = get_node_or_null("Core/VAnchor")
	if not _colshape_node:
		_colshape_node = get_node_or_null("Area/ColShape")


func _RemoveSegements() -> void:
	if _spr_list.size() > 0:
		for spr in _spr_list:
			remove_child(spr)
			spr.queue_free()
		_spr_list = []
	for child in get_children():
		if child is Sprite:
			remove_child(child)
			child.queue_free()

func _PositionAnchors() -> void:
	_CheckForNodes()
	if not _vanchor_node or not _hanchor_l_node or not _hanchor_r_node:
		return
	
	match mode:
		MODE.VERTICLE:
			_vanchor_node.visible = true
			_hanchor_l_node.visible = false
			_hanchor_l_node.position = Vector2(-1,-8)
			_hanchor_r_node.visible = false
			_hanchor_r_node.position = Vector2(1, -8)
		MODE.HORIZONTAL:
			_vanchor_node.visible = false
			var dist = segments * 16
			match grow:
				GROW.LEFT:
					_hanchor_l_node.position = Vector2(-(dist+1), -8)
					_hanchor_l_node.visible = true
					_hanchor_r_node.position = Vector2(1, -8)
					_hanchor_r_node.visible = true
				GROW.RIGHT:
					_hanchor_r_node.position = Vector2(dist + 1, -8)
					_hanchor_r_node.visible = true
					_hanchor_l_node.position = Vector2(-1,-8)
					_hanchor_l_node.visible = true

func _Extend() -> void:
	_CheckForNodes()
	if _spr_list.size() > 0:
		return

	if extended and _refsprite_node and _tween_node:
		_RemoveSegements()
		_PositionAnchors()
		match mode:
			MODE.VERTICLE:
				_SpawnSegment(_vanchor_node.position)
			MODE.HORIZONTAL:
				var dist = segments * 16
				match grow:
					GROW.LEFT:
						_SpawnSegment(Vector2(-8, -8), true)
					GROW.RIGHT:
						_SpawnSegment(Vector2(8, -8), true)


func _SpawnSegment(from : Vector2, nogrow : bool = false) -> void:
	var spr = _refsprite_node.duplicate()
	spr.region_rect = MID_LADDER_REGION
	spr.modulate = main_color
	spr.visible = true
	_spr_list.append(spr)

	var spr_to = from

	match mode:
		MODE.VERTICLE:
			spr_to -= Vector2(0, 16)
		MODE.HORIZONTAL:
			spr.rotate(1.5708)
			if grow == GROW.LEFT:
				spr_to -= Vector2(16, 0)
			else:
				spr_to += Vector2(16, 0)
	
	if _colshape_node:
		var size = (_spr_list.size() * 16.0) * 0.5
		if mode == MODE.VERTICLE:
			size += 8
		
		var pos = Vector2(0, -size)
		if mode == MODE.HORIZONTAL:
			if grow == GROW.LEFT:
				pos = pos.rotated(-1.5708)
			else:
				pos = pos.rotated(1.5708)
			pos.y = -8
		_colshape_node.position = pos
		if abs(pos.x) < 0.01:
			pos.x = 8
			pos.y = size
		else:
			pos.y = 8
			pos.x = size
		_colshape_node.shape.extents = pos
	
	
	if segment_extend_time <= 0.0 or nogrow:
		add_child(spr)
		spr.position = from if nogrow else spr_to
		_on_tween_all_completed()
	else:
		add_child(spr)
		spr.position = from
		
		if _tween_node:
			_tween_node.remove_all()
			_tween_node.interpolate_property(spr, "position", spr.position, spr_to, segment_extend_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			_tween_node.start()

# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_tween_all_completed():
	if _spr_list.size() < segments:
		_SpawnSegment(_spr_list[_spr_list.size() - 1].position)


func _on_body_entered(body):
	if extended:
		if body is Player:
			body.enable_gravity(false)


func _on_body_exited(body):
	if body is Player:
		body.enable_gravity(true)
