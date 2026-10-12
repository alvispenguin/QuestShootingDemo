@tool
extends Node
## Helper that automatically creates the full-screen post-process layer
## for the Quest 3 passthrough simulation.
## Drop this script on any node in your XR scene (or run the function manually).

@export var auto_setup_on_ready: bool = true
@export var layer: int = 100                # high layer so it draws on top
@export var shader_path: String = "res://shaders/quest3_passthrough_sim.gdshader"

var _canvas_layer: CanvasLayer
var _color_rect: ColorRect
var _material: ShaderMaterial

func _ready() -> void:
	if auto_setup_on_ready and not Engine.is_editor_hint():
		setup()

func setup() -> void:
	if _canvas_layer and is_instance_valid(_canvas_layer):
		return  # already set up

	# Create CanvasLayer
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = layer
	_canvas_layer.name = "Quest3PassthroughSimLayer"
	add_child(_canvas_layer)

	# Full-screen ColorRect
	_color_rect = ColorRect.new()
	_color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color_rect.name = "PassthroughSimRect"
	_canvas_layer.add_child(_color_rect)

	# Load shader and create material
	var shader = load(shader_path) as Shader
	if not shader:
		push_error("Could not load shader at: " + shader_path)
		return

	_material = ShaderMaterial.new()
	_material.shader = shader
	_color_rect.material = _material

	# Optional: attach the motion controller
	var controller = Node.new()
	controller.name = "PassthroughSimController"
	controller.set_script(load("res://scripts/passthrough_sim_controller.gd"))
	controller.set("shader_material", _material)
	# Try to find XRCamera3D automatically
	var cam = get_tree().get_first_node_in_group("xr_camera")
	if cam:
		controller.set("camera_path", cam.get_path())
	add_child(controller)

	print("Quest 3 Passthrough simulation layer created.")

func get_material() -> ShaderMaterial:
	return _material

func set_enabled(enabled: bool) -> void:
	if _color_rect:
		_color_rect.visible = enabled
