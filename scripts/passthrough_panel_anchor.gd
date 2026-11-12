extends Node3D

## Places the world-space passthrough panel in front of the user's initial view.

@export var panel_path: NodePath = NodePath("PassthroughControls3D")
@export var controller_path: NodePath = NodePath("../RightHandController")
@export var distance: float = 1.2
@export var vertical_offset: float = -0.12

var _panel: Node3D
var _panel_visible := true
var _placement_ready := false

func _ready() -> void:
	_panel = get_node_or_null(panel_path) as Node3D
	if not _panel:
		push_warning("Passthrough panel anchor could not find the control panel.")
		return
	_panel.visible = false

	var controller := get_node_or_null(controller_path) as XRController3D
	if controller:
		controller.button_pressed.connect(_on_controller_button_pressed)
	else:
		push_warning("Passthrough panel anchor could not find the right controller; panel toggle is unavailable.")

	# Let OpenXR provide the initial head pose before placing the panel.
	await get_tree().create_timer(0.35).timeout

	var camera := get_tree().get_first_node_in_group("xr_camera") as Camera3D
	if not camera:
		push_warning("Passthrough panel anchor could not find the XR camera.")
	else:
		var camera_basis := camera.global_transform.basis.orthonormalized()
		global_transform = Transform3D(
			camera_basis,
			camera.global_position
				- camera_basis.z * distance
				+ camera_basis.y * vertical_offset
		)

	_placement_ready = true
	_panel.visible = _panel_visible

func _on_controller_button_pressed(button_name: String) -> void:
	if button_name == "ax_button":
		_panel_visible = not _panel_visible
		if _placement_ready:
			_panel.visible = _panel_visible
