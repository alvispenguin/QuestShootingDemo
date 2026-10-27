extends CanvasLayer

## Live control panel for Quest 3 Passthrough swimminess
## Attach this script to a CanvasLayer (or any node) in your scene.

@export var target_material: ShaderMaterial   # drag the material here, or it will find it automatically

# Default values (same as the shader)
var warp_strength := 0.035
var swim_strength := 0.018
var edge_warp_boost := 1.4

func _ready() -> void:
	layer = 128   # make sure it draws above everything

	# Try to find the material automatically if not assigned
	if not target_material:
		_find_material()

	_create_ui()

func _find_material() -> void:
	# Look for the ColorRect created by the setup script
	var rect = get_tree().root.find_child("PassthroughSimRect", true, false)
	if rect and rect.material is ShaderMaterial:
		target_material = rect.material
		print("Control panel found the passthrough material automatically.")
	else:
		push_warning("Could not find PassthroughSimRect material. Please assign it manually.")

func _create_ui() -> void:
	# Background panel
	var panel = PanelContainer.new()
	panel.name = "ControlPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(340, 220)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Passthrough Swimminess Controls"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	# --- Warp Strength ---
	vbox.add_child(_make_slider("Warp Strength", 0.0, 0.15, warp_strength, 
		func(value): 
			warp_strength = value
			_update_shader("warp_strength", value)
	))

	# --- Swim Strength ---
	vbox.add_child(_make_slider("Swim Strength", 0.0, 0.08, swim_strength, 
		func(value): 
			swim_strength = value
			_update_shader("swim_strength", value)
	))

	# --- Edge Warp Boost ---
	vbox.add_child(_make_slider("Edge Warp Boost", 0.0, 3.0, edge_warp_boost, 
		func(value): 
			edge_warp_boost = value
			_update_shader("edge_warp_boost", value)
	))

	# Reset button
	var reset_btn = Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.pressed.connect(_on_reset)
	vbox.add_child(reset_btn)

func _make_slider(label_text: String, min_val: float, max_val: float, default: float, on_change: Callable) -> Control:
	var container = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "%s: %.3f" % [label_text, default]
	container.add_child(label)

	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 0.001
	slider.value = default
	slider.custom_minimum_size = Vector2(300, 20)
	
	slider.value_changed.connect(func(value):
		label.text = "%s: %.3f" % [label_text, value]
		on_change.call(value)
	)
	
	container.add_child(slider)
	return container

func _update_shader(param: String, value: float) -> void:
	if target_material:
		target_material.set_shader_parameter(param, value)

func _on_reset() -> void:
	warp_strength = 0.035
	swim_strength = 0.018
	edge_warp_boost = 1.4
	
	_update_shader("warp_strength", warp_strength)
	_update_shader("swim_strength", swim_strength)
	_update_shader("edge_warp_boost", edge_warp_boost)
	
	# Force UI update by recreating (simple way)
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame
	_create_ui()
