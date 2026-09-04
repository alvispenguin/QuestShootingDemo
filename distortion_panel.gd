extends Node3D

@export var distortion_material: ShaderMaterial

@onready var vignette_strength_slider: HSlider = $UIViewport/UIRoot/VBoxContainer/VignetteStrengthSlider
@onready var vignette_radius_slider: HSlider = $UIViewport/UIRoot/VBoxContainer/VignetteRadiusSlider
@onready var vignette_softness_slider: HSlider = $UIViewport/UIRoot/VBoxContainer/VignetteSoftnessSlider
@onready var edge_distortion_slider: HSlider = $UIViewport/UIRoot/VBoxContainer/EdgeDistortionSlider
@onready var distortion_power_slider: HSlider = $UIViewport/UIRoot/VBoxContainer/DistortionPowerSlider

func _ready() -> void:
	# Connect sliders
	vignette_strength_slider.value_changed.connect(_on_vignette_strength_changed)
	vignette_radius_slider.value_changed.connect(_on_vignette_radius_changed)
	vignette_softness_slider.value_changed.connect(_on_vignette_softness_changed)
	edge_distortion_slider.value_changed.connect(_on_edge_distortion_changed)
	distortion_power_slider.value_changed.connect(_on_distortion_power_changed)

	# Set initial values from the material (optional)
	if distortion_material:
		vignette_strength_slider.value = distortion_material.get_shader_parameter("vignette_strength")
		vignette_radius_slider.value = distortion_material.get_shader_parameter("vignette_radius")
		vignette_softness_slider.value = distortion_material.get_shader_parameter("vignette_softness")
		edge_distortion_slider.value = distortion_material.get_shader_parameter("edge_distortion")
		distortion_power_slider.value = distortion_material.get_shader_parameter("distortion_power")

func _on_vignette_strength_changed(value: float) -> void:
	if distortion_material:
		distortion_material.set_shader_parameter("vignette_strength", value)

func _on_vignette_radius_changed(value: float) -> void:
	if distortion_material:
		distortion_material.set_shader_parameter("vignette_radius", value)

func _on_vignette_softness_changed(value: float) -> void:
	if distortion_material:
		distortion_material.set_shader_parameter("vignette_softness", value)

func _on_edge_distortion_changed(value: float) -> void:
	if distortion_material:
		distortion_material.set_shader_parameter("edge_distortion", value)

func _on_distortion_power_changed(value: float) -> void:
	if distortion_material:
		distortion_material.set_shader_parameter("distortion_power", value)
