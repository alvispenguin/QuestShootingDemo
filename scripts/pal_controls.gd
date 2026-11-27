extends Control

const DEFAULT_STRENGTH_STEPS := 2
const MAX_STRENGTH_STEPS := 10

var _effect: MeshInstance3D
var _material: ShaderMaterial
var _panel_anchor: Node3D
var _panel_surface: XRToolsViewport2DIn3D
var _strength_steps := DEFAULT_STRENGTH_STEPS
var _strength_label: Label
var _button_theme: Theme
var _dragging := false

func _ready() -> void:
	_effect = get_node_or_null("../../../../XRCamera3D/PALDistortion") as MeshInstance3D
	if _effect:
		_material = _effect.material_override as ShaderMaterial
	_panel_anchor = get_tree().root.find_child("PALPanelAnchor", true, false) as Node3D
	_panel_surface = get_tree().root.find_child("PALControls3D", true, false) as XRToolsViewport2DIn3D
	if not _effect or not _material:
		push_error("PAL controls could not find the distortion effect or its material.")
	if not _panel_anchor or not _panel_surface:
		push_error("PAL controls could not find the movable panel anchor or surface.")
	_create_ui()
	_update_strength()

func _create_ui() -> void:
	_button_theme = _create_button_theme()
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.025, 0.045, 0.075, 0.98)
	background.border_color = Color(0.15, 0.78, 0.95)
	background.set_border_width_all(2)
	background.set_corner_radius_all(12)
	background.content_margin_left = 20
	background.content_margin_right = 20
	background.content_margin_top = 14
	background.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", background)
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var drag_handle := HBoxContainer.new()
	drag_handle.custom_minimum_size.y = 40
	drag_handle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drag_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	drag_handle.gui_input.connect(_on_drag_handle_gui_input)
	box.add_child(drag_handle)

	var title := Label.new()
	title.text = "PROGRESSIVE LENS SIMULATION"
	title.add_theme_font_size_override("font_size", 26)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_handle.add_child(title)

	var drag_hint := Label.new()
	drag_hint.text = "  Drag to move"
	drag_hint.add_theme_font_size_override("font_size", 16)
	drag_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drag_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	drag_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_handle.add_child(drag_hint)

	var note := Label.new()
	note.text = "Illustrative only - not a calibrated lens."
	note.add_theme_font_size_override("font_size", 20)
	box.add_child(note)

	var instructions := Label.new()
	instructions.text = "A show/hide, B interact. Drag title bar to move."
	instructions.add_theme_font_size_override("font_size", 18)
	box.add_child(instructions)

	var toggle := Button.new()
	toggle.theme = _button_theme
	toggle.text = "Simulation: OFF"
	toggle.toggle_mode = true
	toggle.disabled = not _effect or not _material
	toggle.custom_minimum_size.y = 56
	toggle.add_theme_font_size_override("font_size", 24)
	toggle.toggled.connect(func(enabled: bool) -> void:
		_effect.visible = enabled
		toggle.text = "Simulation: ON" if enabled else "Simulation: OFF"
	)
	box.add_child(toggle)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var label := Label.new()
	label.text = "Strength"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 22)
	row.add_child(label)
	var decrease := Button.new()
	decrease.theme = _button_theme
	decrease.text = "-0.1"
	decrease.custom_minimum_size = Vector2(100, 54)
	decrease.add_theme_font_size_override("font_size", 22)
	decrease.disabled = not _material
	decrease.pressed.connect(func() -> void: _change_strength(-1))
	row.add_child(decrease)
	_strength_label = Label.new()
	_strength_label.custom_minimum_size.x = 80
	_strength_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_strength_label.add_theme_font_size_override("font_size", 22)
	row.add_child(_strength_label)
	var increase := Button.new()
	increase.theme = _button_theme
	increase.text = "+0.1"
	increase.custom_minimum_size = Vector2(100, 54)
	increase.add_theme_font_size_override("font_size", 22)
	increase.disabled = not _material
	increase.pressed.connect(func() -> void: _change_strength(1))
	row.add_child(increase)

	var reset := Button.new()
	reset.theme = _button_theme
	reset.text = "Reset strength to 0.2"
	reset.custom_minimum_size.y = 48
	reset.add_theme_font_size_override("font_size", 20)
	reset.disabled = not _material
	reset.pressed.connect(func() -> void:
		_strength_steps = DEFAULT_STRENGTH_STEPS
		_update_strength()
	)
	box.add_child(reset)

func _on_drag_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		if _panel_anchor and _panel_surface:
			_panel_anchor.move_panel_by_screen_delta(
				event.relative,
				_panel_surface.screen_size,
				_panel_surface.viewport_size
			)
		accept_event()

func _create_button_theme() -> Theme:
	var button_theme := Theme.new()
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.10, 0.19, 0.27)
		style.border_color = Color(0.27, 0.57, 0.68)
		if state == "hover":
			style.bg_color = Color(0.16, 0.34, 0.43)
		elif state == "pressed" or state == "hover_pressed":
			style.bg_color = Color(0.05, 0.38, 0.47)
			style.border_color = Color(0.35, 0.92, 1.0)
		elif state == "disabled":
			style.bg_color = Color(0.09, 0.11, 0.14)
			style.border_color = Color(0.26, 0.30, 0.33)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		style.content_margin_left = 4
		style.content_margin_right = 4
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		button_theme.set_stylebox(state, "Button", style)
	return button_theme

func _change_strength(delta: int) -> void:
	_strength_steps = clampi(_strength_steps + delta, 0, MAX_STRENGTH_STEPS)
	_update_strength()

func _update_strength() -> void:
	var strength := _strength_steps * 0.1
	_strength_label.text = "%.1f" % strength
	if _material:
		_material.set_shader_parameter("strength", strength)
