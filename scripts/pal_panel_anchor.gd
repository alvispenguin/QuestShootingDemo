extends Node3D

@onready var _panel: Node3D = $PALControls3D
var _panel_visible := true
var _placement_ready := false

func _ready() -> void:
	_panel.visible = false
	var controller := get_node_or_null("../RightHandController") as XRController3D
	if controller:
		controller.button_pressed.connect(_on_controller_button_pressed)
	else:
		push_warning("PAL controls could not find the right controller.")

	await get_tree().create_timer(0.35).timeout
	var camera := get_node_or_null("../XRCamera3D") as XRCamera3D
	if camera:
		var camera_basis := camera.global_basis.orthonormalized()
		global_transform = Transform3D(
			camera_basis, camera.global_position - camera_basis.z * 1.0 - camera_basis.y * 0.12
		)
	else:
		push_error("PAL controls could not find the XR camera for panel placement.")
		return
	_placement_ready = true
	_panel.visible = _panel_visible

func _on_controller_button_pressed(button_name: String) -> void:
	if button_name == "ax_button":
		_panel_visible = not _panel_visible
		if _placement_ready:
			_panel.visible = _panel_visible
