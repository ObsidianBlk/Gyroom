extends Light2D
tool


# --------------------------------------------------
# Export Variables
# --------------------------------------------------
export(float, 0.1, 10.0, 0.01) var base_energy = 1.0
export(float, 0.1, 10.0, 0.01) var base_scale = 1.0
export var noise_texture : Texture = null
export var flame_node_path : NodePath = ""
export var use_flame_noise : bool = false


# --------------------------------------------------
# Variables
# --------------------------------------------------
var _time : float = 0.0

# --------------------------------------------------
# Override Methods
# --------------------------------------------------

func _process(delta : float) -> void:
	var noisetex = _GetNoiseTexture()
	if noisetex is NoiseTexture:
		_time += delta * 75
		var offset = noisetex.noise.get_noise_1d(_time)
		scale = Vector2(base_scale + offset/3, base_scale + offset/3)
		energy = base_energy + offset/3

# --------------------------------------------------
# Private Methods
# --------------------------------------------------

func _GetNoiseTexture() -> Texture:
	if use_flame_noise and flame_node_path != "":
		var flame_node = get_node_or_null(flame_node_path)
		var mat = flame_node.get_material()
		if mat is ShaderMaterial:
			return (mat.get_shader_param("noise") as NoiseTexture)
	return noise_texture
