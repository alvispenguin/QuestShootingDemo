extends Node
## Quest 3 Passthrough Simulation Controller
## Attach this to a node that has access to the XRCamera3D (or the root of your XR scene).
## It drives the "head_motion" uniform so the swimminess reacts to real head movement.

@export var shader_material: ShaderMaterial
@export var camera_path: NodePath          # path to XRCamera3D
@export var motion_sensitivity: float = 4.0
@export var motion_smoothing: float = 0.12

var _camera: Camera3D
var _prev_basis: Basis
var _motion_amount: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	if camera_path:
		_camera = get_node_or_null(camera_path) as Camera3D
	if not _camera:
		# Fallback: try to find the first XRCamera3D
		_camera = get_tree().get_first_node_in_group("xr_camera") as Camera3D
		if not _camera:
			push_warning("PassthroughSim: No XRCamera3D found. Swimminess will be time-only.")
	if _camera:
		_prev_basis = _camera.global_transform.basis

func _process(delta: float) -> void:
	_time += delta
	if shader_material:
		shader_material.set_shader_parameter("time", _time)

	if not _camera or not shader_material:
		return

	# Measure rotational change as a rough "head motion" value
	var current_basis := _camera.global_transform.basis
	var rot_diff := _prev_basis.inverse() * current_basis
	var angle = rot_diff.get_euler().length()          # radians

	# Simple rotation-based motion metric
	var instant_motion = clamp(angle * motion_sensitivity, 0.0, 1.0)
	_motion_amount = lerp(_motion_amount, instant_motion, 1.0 - exp(-delta / motion_smoothing))

	shader_material.set_shader_parameter("head_motion", _motion_amount)
	_prev_basis = current_basis

## Convenience methods to tweak the look at runtime
func set_warp(value: float) -> void:
	if shader_material:
		shader_material.set_shader_parameter("warp_strength", value)

func set_swim(value: float) -> void:
	if shader_material:
		shader_material.set_shader_parameter("swim_strength", value)
