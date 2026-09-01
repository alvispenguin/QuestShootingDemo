extends XRController3D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15  # seconds between shots

var can_shoot := true

func _ready() -> void:
	# Connect the trigger button
	button_pressed.connect(_on_button_pressed)

func _on_button_pressed(button_name: String) -> void:
	if button_name == "trigger_click" or button_name == "trigger":
		shoot()

func shoot() -> void:
	if not can_shoot or bullet_scene == null:
		return

	can_shoot = false

	var bullet = bullet_scene.instantiate()
	# Spawn slightly in front of the controller
	get_tree().current_scene.add_child(bullet)
	bullet.global_transform = global_transform
	bullet.global_position += -global_transform.basis.z * 0.15  # offset forward

	# Simple cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
