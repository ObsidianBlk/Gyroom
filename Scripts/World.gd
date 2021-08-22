extends Node2D

# --------------------------------------------------
# Variables
# --------------------------------------------------

var _level : Level = null

# --------------------------------------------------
# Onready Variables
# --------------------------------------------------
onready var _container = get_node("Container")
onready var _player = get_node("Container/Player")
onready var _camera = get_node("Container/Camera")


# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _ready() -> void:
	_LoadLevel("res://Maps/Level_001.tscn")

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _LoadLevel(src : String) -> void:
	var LEVEL_SCENE = load(src)
	if LEVEL_SCENE:
		var level = LEVEL_SCENE.instance()
		if level is Level:
			if _level != null:
				_level.disconnect("request_level", self, "_on_request_level")
				_level.disconnect("request_exit", self, "_on_request_exit")
				_level.detach_player_to_container(_container)
				_level.detach_camera_to_container(_container)
				remove_child(_level)
				_level.queue_free()
				_level = null
			_level = level
			_level.connect("request_level", self, "_on_request_level")
			_level.connect("request_exit", self, "_on_request_exit")
			add_child(_level)
			_level.attach_player_node(_player)
			_level.attach_camera_node(_camera)
		else:
			print("ERROR: Loaded level not a Level class scene!")
	else:
		print("ERROR: Failed to load level!!")


# --------------------------------------------------
# Handler Methods
# --------------------------------------------------

func _on_request_exit() -> void:
	get_tree().quit()

func _on_request_level(level_src : String) -> void:
	_LoadLevel(level_src)


