extends Control

## World-space control panel for passthrough swimminess.
## This Control is rendered inside XRToolsViewport2DIn3D's SubViewport.

@export var target_material: ShaderMaterial

var warp_strength := 0.035
var swim_strength := 0.018
var edge_warp_boost := 1.4

var _sliders: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not target_material:
		_find_material()
	_create_ui()

func _find_material() -> void:
	var rect := get_tree().root.find_child("PassthroughSimRect", true, false) as ColorRect
	if rect and rect.material is ShaderMaterial:
		target_material = rect.material
		print("Passthrough control panel found the simulation material.")
	else:
		push_warning("Passthrough control panel could not find PassthroughSimRect; sliders will only update their labels.")

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

	vbox.add_child(_make_slider("Warp Strength", 0.0, 0.15, warp_strength, "warp_strength"))
	vbox.add_child(_make_slider("Swim Strength", 0.0, 0.08, swim_strength, "swim_strength"))
	vbox.add_child(_make_slider("Edge Warp Boost", 0.0, 3.0, edge_warp_boost, "edge_warp_boost"))

	var reset_btn := Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.custom_minimum_size = Vector2(0, 52)
	reset_btn.add_theme_font_size_override("font_size", 22)
	reset_btn.pressed.connect(_on_reset)
	vbox.add_child(reset_btn)

func _make_slider(label_text: String, min_val: float, max_val: float, default: float, parameter: String) -> Control:
	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)

	var label_row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 22)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_row.add_child(label)

	var value_label := Label.new()
	value_label.text = "%.3f" % default
	value_label.add_theme_font_size_override("font_size", 22)
	label_row.add_child(value_label)
	container.add_child(label_row)

	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 0.001
	slider.value = default
	slider.custom_minimum_size = Vector2(0, 42)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.focus_mode = Control.FOCUS_ALL
	slider.value_changed.connect(func(value: float) -> void:
		value_label.text = "%.3f" % value
		set(parameter, value)
		_update_shader(parameter, value)
	)
	container.add_child(slider)
	_sliders[parameter] = slider
	return container

func _update_shader(parameter: String, value: float) -> void:
	if target_material:
		target_material.set_shader_parameter(parameter, value)

func _on_reset() -> void:
	_sliders["warp_strength"].value = 0.035
	_sliders["swim_strength"].value = 0.018
	_sliders["edge_warp_boost"].value = 1.4
