extends Node3D

@export var target_scene: PackedScene
@export var spawn_area_size: Vector3 = Vector3(4.0, 2.0, 4.0)  # Width, Height range, Depth
@export var spawn_height: float = 1.5
@export var respawn_delay: float = 1.0

var current_target: Node3D = null
var is_spawning: bool = false

func _ready() -> void:
	spawn_target()

func spawn_target() -> void:
	# Prevent spawning if a target already exists or we are in the process of spawning
	if current_target != null or is_spawning:
		return

	if target_scene == null:
		push_error("Target scene is not assigned in TargetSpawner!")
		return

	is_spawning = true

	# Create the target
	current_target = target_scene.instantiate()
	add_child(current_target)

	# Random position within the defined area
	var random_x = randf_range(-spawn_area_size.x / 2.0, spawn_area_size.x / 2.0)
	var random_y = spawn_height + randf_range(-spawn_area_size.y / 2.0, spawn_area_size.y / 2.0)
	var random_z = randf_range(-spawn_area_size.z / 2.0, spawn_area_size.z / 2.0)

	current_target.position = Vector3(random_x, random_y, random_z)

	# Connect the destroyed signal
	if current_target.has_signal("target_destroyed"):
		current_target.target_destroyed.connect(_on_target_destroyed)
	else:
		push_warning("Target does not have 'target_destroyed' signal!")

	is_spawning = false

func _on_target_destroyed() -> void:
	current_target = null

	# Wait before spawning the next one
	await get_tree().create_timer(respawn_delay).timeout
	spawn_target()
