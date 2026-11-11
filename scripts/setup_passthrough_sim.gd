@tool
extends Node
## Creates a camera-attached full-screen effect for the simulated environment.

@export var auto_setup_on_ready: bool = true
@export var shader_path: String = "res://shaders/quest3_passthrough_sim.gdshader"

var _effect: MeshInstance3D
var _material: ShaderMaterial

func _ready() -> void:
	if auto_setup_on_ready and not Engine.is_editor_hint():
		setup()

func _exit_tree() -> void:
	if is_instance_valid(_effect):
		_effect.queue_free()

func setup() -> void:
	if is_instance_valid(_effect):
		return

	var camera := get_tree().get_first_node_in_group("xr_camera") as Camera3D
	if not camera:
		push_error("PassthroughSim: No camera found in the xr_camera group.")
		return
	var shader := load(shader_path) as Shader
	if not shader:
		push_error("PassthroughSim: Could not load shader at: " + shader_path)
		return

	_material = ShaderMaterial.new()
	_material.shader = shader
	_material.render_priority = -128
	var quad := QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	_effect = MeshInstance3D.new()
	_effect.name = "PassthroughSimQuad"
	_effect.mesh = quad
	_effect.material_override = _material
	_effect.extra_cull_margin = 16384.0
	_effect.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	camera.add_child(_effect)

	var controller := Node.new()
	controller.name = "PassthroughSimController"
	controller.set_script(load("res://scripts/passthrough_sim_controller.gd"))
	controller.set("shader_material", _material)
	controller.set("camera_path", camera.get_path())
	add_child(controller)

func get_material() -> ShaderMaterial:
	return _material

func set_enabled(enabled: bool) -> void:
	if is_instance_valid(_effect):
		_effect.visible = enabled
