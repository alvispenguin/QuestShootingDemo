extends Control

## World-space controls rendered inside XRToolsViewport2DIn3D's SubViewport.

@export var target_material: ShaderMaterial

const DEFAULTS := {
	"warp_strength": 0.035,
	"swim_strength": 0.018,
	"edge_warp_boost": 1.4,
	"softness_pixels": 0.7,
	"grain_strength": 0.015,
	"vignette_strength": 0.2,
}

var _simulation: Node
var _sliders: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_simulation = get_tree().root.find_child("Quest3PassthroughSim", true, false)
	if not target_material and _simulation and _simulation.has_method("get_material"):
		target_material = _simulation.get_material() as ShaderMaterial
	if not target_material:
		push_warning("Passthrough controls could not find the simulation material.")
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
	panel_style.content_margin_left = 22.0
	panel_style.content_margin_top = 18.0
	panel_style.content_margin_right = 22.0
	panel_style.content_margin_bottom = 18.0
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "PASSTHROUGH CONTROLS"
	title.add_theme_font_size_override("font_size", 30)
	vbox.add_child(title)

	var instructions := Label.new()
	instructions.text = "Aim with the right controller; press B to interact."
	instructions.add_theme_font_size_override("font_size", 20)
	vbox.add_child(instructions)

	var enabled := CheckButton.new()
	enabled.text = "Simulation enabled"
	enabled.button_pressed = true
	enabled.disabled = not _simulation or not _simulation.has_method("set_enabled")
	enabled.toggled.connect(func(value: bool) -> void:
		_simulation.call("set_enabled", value)
	)
	vbox.add_child(enabled)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)
	grid.add_child(_make_slider("Warp Strength", 0.15, "warp_strength"))
	grid.add_child(_make_slider("Swim Strength", 0.08, "swim_strength"))
	grid.add_child(_make_slider("Edge Warp Boost", 3.0, "edge_warp_boost"))
	grid.add_child(_make_slider("Softness (pixels)", 3.0, "softness_pixels"))
	grid.add_child(_make_slider("Grain Strength", 0.1, "grain_strength"))
	grid.add_child(_make_slider("Edge Darkening", 1.0, "vignette_strength"))

	var reset_btn := Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.custom_minimum_size = Vector2(0, 52)
	reset_btn.add_theme_font_size_override("font_size", 22)
	reset_btn.pressed.connect(_on_reset)
	vbox.add_child(reset_btn)

func _make_slider(label_text: String, max_val: float, parameter: String) -> Control:
	var container := VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 4)

	var label_row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 20)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_row.add_child(label)

	var value_label := Label.new()
	value_label.text = "%.3f" % DEFAULTS[parameter]
	value_label.add_theme_font_size_override("font_size", 20)
	label_row.add_child(value_label)
	container.add_child(label_row)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = max_val
	slider.step = 0.001
	slider.value = DEFAULTS[parameter]
	slider.custom_minimum_size = Vector2(0, 36)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.focus_mode = Control.FOCUS_ALL
	slider.value_changed.connect(func(value: float) -> void:
		value_label.text = "%.3f" % value
		if target_material:
			target_material.set_shader_parameter(parameter, value)
	)
	container.add_child(slider)
	_sliders[parameter] = slider
	return container

func _on_reset() -> void:
	for parameter in DEFAULTS:
		_sliders[parameter].value = DEFAULTS[parameter]
