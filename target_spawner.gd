extends Node3D

@export var target_scene: PackedScene
@export var spawn_area_size: Vector3 = Vector3(12.0, 3.0, 10.0)  # Width, Height, Depth
@export var spawn_height_offset: float = 1.5
@export var respawn_delay: float = 1.0

var current_target: Node3D = null
var is_spawning: bool = false

func _ready() -> void:
	spawn_target()

func spawn_target() -> void:
	if current_target != null or is_spawning:
		return

	if target_scene == null:
		push_error("Target scene is not assigned!")
		return

	is_spawning = true

	current_target = target_scene.instantiate()
	add_child(current_target)

	# Random position relative to the TargetSpawner
	var random_x = randf_range(-spawn_area_size.x / 2.0, spawn_area_size.x / 2.0)
	var random_y = spawn_height_offset + randf_range(-spawn_area_size.y / 2.0, spawn_area_size.y / 2.0)
	var random_z = randf_range(-spawn_area_size.z / 2.0, spawn_area_size.z / 2.0)

	current_target.position = Vector3(random_x, random_y, random_z)

	if current_target.has_signal("target_destroyed"):
		current_target.target_destroyed.connect(_on_target_destroyed)

	is_spawning = false

func _on_target_destroyed() -> void:
	current_target = null
	await get_tree().create_timer(respawn_delay).timeout
	spawn_target()
