extends Control

## World-space controls rendered inside XRToolsViewport2DIn3D's SubViewport.

@export var target_material: ShaderMaterial

const CONTROLS := {
	"warp_strength": {"default": 20, "max": 20},
	"edge_warp_boost": {"default": 14, "max": 30},
}

var _simulation: Node
var _values: Dictionary = {}
var _value_labels: Dictionary = {}

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
	instructions.text = "Right controller: A show/hide, B interact."
	instructions.add_theme_font_size_override("font_size", 20)
	vbox.add_child(instructions)

	var enabled := Button.new()
	enabled.toggle_mode = true
	enabled.text = "Simulation: ON"
	enabled.button_pressed = true
	enabled.custom_minimum_size = Vector2(0, 80)
	enabled.add_theme_font_size_override("font_size", 28)
	enabled.disabled = not _simulation or not _simulation.has_method("set_enabled")
	enabled.toggled.connect(func(value: bool) -> void:
		enabled.text = "Simulation: ON" if value else "Simulation: OFF"
		_simulation.call("set_enabled", value)
	)
	vbox.add_child(enabled)

	vbox.add_child(_make_stepper("Warp Strength", "warp_strength"))
	vbox.add_child(_make_stepper("Edge Warp Boost", "edge_warp_boost"))

	var reset_btn := Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.custom_minimum_size = Vector2(0, 52)
	reset_btn.add_theme_font_size_override("font_size", 22)
	reset_btn.pressed.connect(_on_reset)
	vbox.add_child(reset_btn)

func _make_stepper(label_text: String, parameter: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 24)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var decrease := Button.new()
	decrease.text = "<"
	decrease.custom_minimum_size = Vector2(80, 68)
	decrease.add_theme_font_size_override("font_size", 30)
	decrease.pressed.connect(func() -> void: _change_value(parameter, -1))
	row.add_child(decrease)

	var value_label := Label.new()
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.custom_minimum_size = Vector2(72, 0)
	value_label.add_theme_font_size_override("font_size", 26)
	row.add_child(value_label)
	_value_labels[parameter] = value_label
	_set_value(parameter, CONTROLS[parameter]["default"])

	var increase := Button.new()
	increase.text = ">"
	increase.custom_minimum_size = Vector2(80, 68)
	increase.add_theme_font_size_override("font_size", 30)
	increase.pressed.connect(func() -> void: _change_value(parameter, 1))
	row.add_child(increase)
	return row

func _change_value(parameter: String, delta: int) -> void:
	_set_value(parameter, _values[parameter] + delta)

func _set_value(parameter: String, steps: int) -> void:
	var bounded := clampi(steps, 0, CONTROLS[parameter]["max"])
	_values[parameter] = bounded
	var value := bounded / 10.0
	_value_labels[parameter].text = "%.1f" % value
	if target_material:
		target_material.set_shader_parameter(parameter, value)

func _on_reset() -> void:
	for parameter in CONTROLS:
		_set_value(parameter, CONTROLS[parameter]["default"])
