extends Control

## World-space controls rendered inside XRToolsViewport2DIn3D's SubViewport.

@export var target_material: ShaderMaterial

const COEFFICIENTS := {
	"k1": {"name": "Primary radial (k1)", "min": -100, "max": 100, "default": 0, "step": 0.01, "coarse_steps": 10, "coarse_label": "0.1", "format": "%.2f"},
	"k2": {"name": "Secondary radial (k2)", "min": -100, "max": 100, "default": 0, "step": 0.01, "coarse_steps": 10, "coarse_label": "0.1", "format": "%.2f"},
	"k3": {"name": "Outer-edge radial (k3)", "min": -100, "max": 100, "default": 0, "step": 0.01, "coarse_steps": 10, "coarse_label": "0.1", "format": "%.2f"},
	"p1": {"name": "Tangential 1 (p1)", "min": -100, "max": 100, "default": 0, "step": 0.01, "coarse_steps": 10, "coarse_label": "0.1", "format": "%.2f"},
	"p2": {"name": "Tangential 2 (p2)", "min": -100, "max": 100, "default": 0, "step": 0.01, "coarse_steps": 10, "coarse_label": "0.1", "format": "%.2f"},
}

var _simulation: Node
var _panel_anchor: Node3D
var _panel_surface: Node
var _values: Dictionary = {}
var _value_labels: Dictionary = {}
var _dragging := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_simulation = get_tree().root.find_child("Quest3PassthroughSim", true, false)
	_panel_anchor = get_tree().root.find_child("PassthroughControlsAnchor", true, false) as Node3D
	_panel_surface = get_tree().root.find_child("PassthroughControls3D", true, false)
	if not target_material and _simulation and _simulation.has_method("get_material"):
		target_material = _simulation.get_material() as ShaderMaterial
	if not target_material:
		push_warning("Passthrough controls could not find the simulation material.")
	if not _panel_anchor or not _panel_surface:
		push_warning("Passthrough controls could not find the movable panel anchor or surface.")
	_create_ui()

func _create_ui() -> void:
	var panel := PanelContainer.new()
	panel.name = "ControlPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.045, 0.075, 0.97)
	panel_style.border_color = Color(0.15, 0.78, 0.95, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 18.0
	panel_style.content_margin_top = 12.0
	panel_style.content_margin_right = 18.0
	panel_style.content_margin_bottom = 12.0
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var drag_handle := HBoxContainer.new()
	drag_handle.custom_minimum_size.y = 36
	drag_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	drag_handle.gui_input.connect(_on_drag_handle_gui_input)
	vbox.add_child(drag_handle)

	var title := Label.new()
	title.text = "CAMERA DISTORTION"
	title.add_theme_font_size_override("font_size", 26)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_handle.add_child(title)

	var instructions := Label.new()
	instructions.text = "A show/hide, B interact. Drag title to move."
	instructions.add_theme_font_size_override("font_size", 18)
	vbox.add_child(instructions)

	var calibration_note := Label.new()
	calibration_note.text = "Enter distortion coefficients; defaults are zero."
	calibration_note.add_theme_font_size_override("font_size", 16)
	vbox.add_child(calibration_note)

	var enabled := Button.new()
	enabled.toggle_mode = true
	enabled.text = "Simulation: ON"
	enabled.button_pressed = true
	enabled.custom_minimum_size = Vector2(0, 64)
	enabled.add_theme_font_size_override("font_size", 26)
	enabled.disabled = not _simulation or not _simulation.has_method("set_enabled")
	enabled.toggled.connect(func(value: bool) -> void:
		enabled.text = "Simulation: ON" if value else "Simulation: OFF"
		_simulation.call("set_enabled", value)
	)
	vbox.add_child(enabled)

	for parameter in COEFFICIENTS:
		vbox.add_child(_make_stepper(parameter))

	var reset_btn := Button.new()
	reset_btn.text = "Reset Coefficients to Zero"
	reset_btn.custom_minimum_size = Vector2(0, 44)
	reset_btn.add_theme_font_size_override("font_size", 20)
	reset_btn.pressed.connect(_on_reset)
	vbox.add_child(reset_btn)

func _on_drag_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		if _panel_anchor and _panel_surface:
			var screen_size: Vector2 = _panel_surface.get("screen_size")
			var viewport_size: Vector2 = _panel_surface.get("viewport_size")
			_panel_anchor.call("move_panel_by_screen_delta", event.relative, screen_size, viewport_size)
		accept_event()

func _make_stepper(parameter: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var coefficient: Dictionary = COEFFICIENTS[parameter]

	var label := Label.new()
	label.text = coefficient["name"]
	label.add_theme_font_size_override("font_size", 20)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var coarse_step: int = coefficient["coarse_steps"]
	var coarse_label: String = coefficient["coarse_label"]
	var fine_label: String = (coefficient["format"] as String) % coefficient["step"]
	row.add_child(_make_step_button("-" + coarse_label, parameter, -coarse_step))
	row.add_child(_make_step_button("-" + fine_label, parameter, -1))

	var value_label := Label.new()
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.custom_minimum_size = Vector2(100, 0)
	value_label.add_theme_font_size_override("font_size", 20)
	row.add_child(value_label)
	_value_labels[parameter] = value_label
	_set_value(parameter, COEFFICIENTS[parameter]["default"])

	row.add_child(_make_step_button("+" + fine_label, parameter, 1))
	row.add_child(_make_step_button("+" + coarse_label, parameter, coarse_step))
	return row

func _make_step_button(label: String, parameter: String, delta: int) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(76, 56)
	button.add_theme_font_size_override("font_size", 20)
	button.pressed.connect(func() -> void: _change_value(parameter, delta))
	return button

func _change_value(parameter: String, delta: int) -> void:
	_set_value(parameter, _values[parameter] + delta)

func _set_value(parameter: String, steps: int) -> void:
	var coefficient: Dictionary = COEFFICIENTS[parameter]
	var bounded := clampi(steps, coefficient["min"], coefficient["max"])
	var value: float = bounded * coefficient["step"]
	_values[parameter] = bounded
	_value_labels[parameter].text = (coefficient["format"] as String) % value
	if target_material:
		target_material.set_shader_parameter(parameter, value)

func _on_reset() -> void:
	for parameter in COEFFICIENTS:
		_set_value(parameter, COEFFICIENTS[parameter]["default"])
