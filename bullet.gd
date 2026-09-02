extends RigidBody3D

@export var lifetime: float = 3.0

func _ready() -> void:
	add_to_group("bullet")
	
	# Automatically remove the bullet after some time
	await get_tree().create_timer(lifetime).timeout
	queue_free()
