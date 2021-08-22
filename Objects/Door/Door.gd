extends StaticBody2D
tool
class_name Door


# --------------------------------------------------
# Enums
# --------------------------------------------------

enum DIRECTION {LEFT=0, RIGHT=1}


const DOOR_OPEN = preload("res://Assets/Audio/SFX/door_open.wav")
const DOOR_CLOSE = preload("res://Assets/Audio/SFX/door_close.wav")
const DOOR_SHUT = preload("res://Assets/Audio/SFX/door_shut.wav")

# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export var frame_color : Color = Color(1,1,1)				setget set_frame_color
export var door_color : Color = Color(1,1,1)				setget set_door_color
export (DIRECTION) var open_direction = DIRECTION.RIGHT		setget set_open_direction
export var key_item_name : String = ""
export var allow_trigger : bool = true
export (float, 0.0, 10.0) var time_to_open = 1.0
export var open_curve : Curve = null
export var start_open : bool = false						setget set_start_open



# --------------------------------------------------
# Variables
# --------------------------------------------------
var _ready : bool = false
var _time : float = 0.0
var _opened : bool = false
var _col_layer_val = 0
var _col_mask_val = 0

var _player : Player = null


# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var frame_node = get_node("Frame")
onready var door_node = get_node("Door")
onready var colshape_node = get_node("CollisionShape2D")

onready var audio_node = get_node("AudioSFX")


# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------
func set_frame_color(c : Color) -> void:
	frame_color = c
	_UpdateSprites()

func set_door_color(c : Color) -> void:
	door_color = c
	_UpdateSprites()

func set_start_open(o : bool) -> void:
	start_open = o
	_UpdateSprites()
	if start_open:
		_time = time_to_open
		_opened = true
		if door_node:
			door_node.scale.x = 1
	else:
		_time = 0
		_opened = false
		if door_node:
			door_node.scale.x = 0
	_UpdateCollision()

func set_open_direction(d : int) -> void:
	open_direction = d
	_UpdateSprites()
	_UpdateCollision()

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _ready() -> void:
	_col_layer_val = collision_layer
	_col_mask_val = collision_mask
	_ready = true
	set_start_open(start_open)


func _process(delta : float) -> void:
	if _opened:
		if time_to_open > 0.0 and open_curve != null:
			if _time < time_to_open:
				_time = min(_time + delta, time_to_open)
				door_node.scale.x = open_curve.interpolate(_time / time_to_open)
				_UpdateCollision()
		else:
			door_node.scale.x = 1.0
			_UpdateCollision()
	else:
		if time_to_open > 0.0 and open_curve != null:
			if _time > 0.0:
				_time = max(_time - delta, 0.0)
				door_node.scale.x = open_curve.interpolate(_time / time_to_open)
				if not Engine.editor_hint and door_node.scale.x < 0.01:
					audio_node.stream = DOOR_SHUT
					audio_node.play()
				_UpdateCollision()
		else:
			door_node.scale.x = 0.0
			_UpdateCollision()


# --------------------------------------------------
# Private Methods
# --------------------------------------------------
func _UpdateCollision() -> void:
	if not colshape_node:
		colshape_node = get_node_or_null("CollisionShape2D")
	if colshape_node:
		if open_direction == DIRECTION.LEFT:
			colshape_node.position = Vector2(1, -8)
		else:
			colshape_node.position = Vector2(-1, -8)
	
	if not Engine.editor_hint and _ready and door_node:
		if door_node.scale.x < 0.5:
			collision_layer = _col_layer_val
			collision_mask = _col_mask_val
		else:
			collision_layer = 0
			collision_mask = 0


func _UpdateSprites() -> void:
	if not frame_node:
		frame_node = get_node_or_null("Frame")
	if frame_node:
		frame_node.modulate = frame_color
		if open_direction == DIRECTION.LEFT:
			frame_node.position = Vector2(1, 0)
		else:
			frame_node.position = Vector2(-1, 0)
	
	if not door_node:
		door_node = get_node_or_null("Door")
	if door_node:
		door_node.modulate = door_color
		if open_direction == DIRECTION.LEFT:
			door_node.flip_h = true
			door_node.offset.x = -4
		else:
			door_node.flip_h = false
			door_node.offset.x = 4


# --------------------------------------------------
# Public Methods
# --------------------------------------------------



# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_use_door(user : Node2D) -> void:
	if user is Player:
		if not _opened:
			if key_item_name != "":
				if user.has_item(key_item_name):
					user.take_item(key_item_name)
					key_item_name = ""
					_opened = true
			else:
				_opened = true
		else:
			_opened = false
		
		if not Engine.editor_hint:
			if _opened:
				audio_node.stream = DOOR_OPEN
				audio_node.play()
			else:
				audio_node.stream = DOOR_CLOSE
				audio_node.play()


func _on_body_entered(body : Node2D) -> void:
	if _player == null and body is Player:
		_player = body
		_player.connect("use", self, "_on_use_door", [_player])


func _on_body_exited(body : Node2D) -> void:
	if _player == body:
		_player.disconnect("use", self, "_on_use_door")
		_player = null
