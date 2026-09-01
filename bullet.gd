extends RigidBody3D

@export var speed: float = 25.0
@export var lifetime: float = 3.0

func _ready() -> void:
	add_to_group("bullet")
	# Give it an initial velocity forward
	linear_velocity = -global_transform.basis.z * speed
	# Auto-despawn
	await get_tree().create_timer(lifetime).timeout
	queue_free()
