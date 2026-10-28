extends Node3D

## Places the world-space passthrough panel in front of the user's initial view.

@export var panel_path: NodePath = NodePath("PassthroughControls3D")
@export var distance: float = 1.2
@export var vertical_offset: float = -0.12

func _ready() -> void:
	var panel := get_node_or_null(panel_path) as Node3D
	if panel:
		panel.visible = false

	# Let OpenXR provide the initial head pose before placing the panel.
	await get_tree().create_timer(0.35).timeout

	var camera := get_tree().get_first_node_in_group("xr_camera") as Camera3D
	if not camera:
		push_warning("Passthrough panel anchor could not find the XR camera.")
		if panel:
			panel.visible = true
		return

	var camera_basis := camera.global_transform.basis.orthonormalized()
	global_transform = Transform3D(
		camera_basis,
		camera.global_position
			- camera_basis.z * distance
			+ camera_basis.y * vertical_offset
	)

	if panel:
		panel.visible = true
