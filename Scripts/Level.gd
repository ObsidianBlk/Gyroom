extends Node2D
class_name Level


# --------------------------------------------------
# Signals
# --------------------------------------------------
signal request_level(level_res)
signal request_exit

# --------------------------------------------------
# Variables
# --------------------------------------------------
var _player_node : Player = null
var _camera_node : Camera2D = null

# --------------------------------------------------
# Setters / Getters
# --------------------------------------------------


# --------------------------------------------------
# Override Methods
# --------------------------------------------------


# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _PositionPlayer() -> void:
	if _player_node != null:
		var start_pos_node = get_node_or_null("Player_Start")
		if not start_pos_node:
			print("WARNING: Level scene missing 'Player_Start' node!")
			_player_node.position = Vector2.ZERO
		else:
			_player_node.position = start_pos_node.position

# --------------------------------------------------
# Public Methods
# --------------------------------------------------
func attach_player_node(p : Player) -> void:
	if _player_node == null:
		var pc = get_node_or_null("Player_Container")
		if not pc:
			print("WARNING: Level scene missing 'Player_Container' node!")
			return
		var player_parent_node = p.get_parent()
		if player_parent_node:
			player_parent_node.remove_child(p)
		pc.add_child(p)
		_player_node = p
		_player_node.connect("request_respawn", self, "_on_request_respawn")
		if _camera_node != null and _camera_node.has_method("set_target"):
			_camera_node.set_target(p)
		_PositionPlayer()


func detach_player_to_container(container : Node2D) -> void:
	if _player_node != null:
		var pparent = _player_node.get_parent()
		if pparent:
			_player_node.disconnect("request_respawn", self, "_on_request_respawn")
			if _camera_node != null and _camera_node.has_method("get_target"):
				if _camera_node.get_target() == _player_node:
					_camera_node.set_target(null)
			pparent.remove_child(_player_node)
		container.add_child(_player_node)
		_player_node = null


func attach_camera_node(c : Camera2D) -> void:
	if _camera_node == null:
		var cc = get_node_or_null("Camera_Container")
		if not cc:
			print("WARNING: Level scene missing 'Camera_Container' node!")
			return
		var camera_parent_node = c.get_parent()
		if camera_parent_node:
			camera_parent_node.remove_child(c)
		cc.add_child(c)
		_camera_node = c
		if _player_node != null and _camera_node.has_method("set_target"):
			_camera_node.set_target(_player_node)
		_camera_node.current = true

func detach_camera_to_container(container : Node2D) -> void:
	if _camera_node != null:
		var cparent = _camera_node.get_parent()
		if cparent:
			if _player_node != null and _camera_node.has_method("get_target"):
				if _camera_node.get_target() == _player_node:
					_camera_node.set_target(null)
			cparent.remove_child(_camera_node)
		container.add_child(_camera_node)
		_camera_node = null


# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_request_respawn() -> void:
	_PositionPlayer()


func _on_call_exit(next_level_res) -> void:
	if next_level_res != "":
		if next_level_res == "exit":
			emit_signal("request_exit")
		else:
			emit_signal("request_level", next_level_res)
