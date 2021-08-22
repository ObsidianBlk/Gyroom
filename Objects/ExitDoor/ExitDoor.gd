extends Node2D
tool
class_name ExitDoor

# --------------------------------------------------
# Signals
# --------------------------------------------------
signal call_exit(next_level_path)


# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export var next_level_res : String = ""
export var door_color : Color = Color(1,1,1)		setget set_door_color

# --------------------------------------------------
# Variables
# --------------------------------------------------
var _player : Player = null


# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var sprite_node = get_node("Sprite")

# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------
func set_door_color(c : Color) -> void:
	door_color = c
	_UpdateSprite()

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _UpdateSprite() -> void:
	if not sprite_node:
		sprite_node = get_node_or_null("Sprite")
	if sprite_node:
		sprite_node.modulate = door_color

# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_use_exit() -> void:
	if _player != null:
		_player.disconnect("use", self, "_on_use_exit")
		_player = null
		emit_signal("call_exit", next_level_res)


func _on_body_entered(body : Node2D) -> void:
	if Engine.editor_hint or next_level_res == "":
		return
	
	if _player == null and body is Player:
		_player = body
		_player.connect("use", self, "_on_use_exit")


func _on_body_exited(body : Node2D) -> void:
	if Engine.editor_hint or next_level_res == "":
		return
	
	if _player == body:
		_player.disconnect("use", self, "_on_use_exit")
		_player = null

