extends Area3D

signal target_destroyed

func _ready() -> void:
	# Detect when a bullet hits this target
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bullet"):
		# Tell the spawner that this target is gone
		target_destroyed.emit()
		queue_free()  # Destroy the target
