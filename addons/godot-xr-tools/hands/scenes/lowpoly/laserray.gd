extends XRController3D

var ui_viewport: SubViewport
var panel_mesh: MeshInstance3D
@onready var laser: RayCast3D = $LaserRay

var is_pressing := false
var last_position := Vector2.ZERO

func _ready() -> void:
	# Find the UI nodes in the scene
	ui_viewport = get_tree().current_scene.find_child("UIViewport", true, false)
	panel_mesh = get_tree().current_scene.find_child("PanelMesh", true, false)

	if ui_viewport == null:
		print("UIViewport not found!")
	if panel_mesh == null:
		print("PanelMesh not found!")

func _process(_delta: float) -> void:
	if ui_viewport == null or panel_mesh == null:
		return

	if not laser.is_colliding():
		return

	var collider = laser.get_collider()
	
	# Accept collision with the PanelMesh or its StaticBody child
	if collider != panel_mesh and collider.get_parent() != panel_mesh:
		return

	# Get the hit position in local space of the panel
	var hit_pos = laser.get_collision_point()
	var local_pos = panel_mesh.to_local(hit_pos)

	# Convert local position to UV coordinates (0 to 1)
	# Assuming the Quad size is 1.2 x 0.9
	var uv = Vector2(
		(local_pos.x / 1.2) + 0.5,
		0.5 - (local_pos.y / 0.9)
	)
	uv = uv.clamp(Vector2.ZERO, Vector2.ONE)

	var mouse_pos = uv * Vector2(ui_viewport.size)

	# Send mouse motion event
	var motion_event = InputEventMouseMotion.new()
	motion_event.position = mouse_pos
	motion_event.relative = mouse_pos - last_position
	ui_viewport.push_input(motion_event)
	last_position = mouse_pos

	# Handle trigger press / release
	var trigger_pressed = is_button_pressed("trigger_click") or is_button_pressed("trigger")

	if trigger_pressed and not is_pressing:
		is_pressing = true
		var click_event = InputEventMouseButton.new()
		click_event.button_index = MOUSE_BUTTON_LEFT
		click_event.pressed = true
		click_event.position = mouse_pos
		ui_viewport.push_input(click_event)

	elif not trigger_pressed and is_pressing:
		is_pressing = false
		var release_event = InputEventMouseButton.new()
		release_event.button_index = MOUSE_BUTTON_LEFT
		release_event.pressed = false
		release_event.position = mouse_pos
		ui_viewport.push_input(release_event)
