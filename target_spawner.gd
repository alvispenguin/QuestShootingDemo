extends Node3D

@export var target_scene: PackedScene
@export var spawn_area_size: Vector3 = Vector3(4, 2, 4)  # How big the random area is
@export var spawn_height: float = 1.5                    # Average height of targets

var current_target: Node3D = null

func _ready() -> void:
	spawn_target()

func spawn_target() -> void:
	if target_scene == null:
		push_error("Target scene is not assigned!")
		return

	# Create the target
	current_target = target_scene.instantiate()
	add_child(current_target)

	# Random position
	var random_pos = Vector3(
		randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
		spawn_height + randf_range(-0.5, 0.8),
		randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	)
	current_target.position = random_pos

	# Connect the signal so we know when it is destroyed
	current_target.target_destroyed.connect(_on_target_destroyed)

func _on_target_destroyed() -> void:
	current_target = null
	# Wait 1 second, then spawn a new target
	await get_tree().create_timer(1.0).timeout
	spawn_target()
