extends XRController3D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15
@export var bullet_speed: float = 25.0

var can_shoot := true

func _ready() -> void:
	button_pressed.connect(_on_button_pressed)

func _on_button_pressed(button_name: String) -> void:
	if button_name == "trigger_click" or button_name == "trigger":
		shoot()

func shoot() -> void:
	if not can_shoot or bullet_scene == null:
		return

	can_shoot = false

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	# Set the bullet position slightly in front of the controller
	bullet.global_position = global_position + (-global_transform.basis.z * 0.15)

	# Make the bullet face the same direction as the controller
	bullet.global_transform.basis = global_transform.basis

	# Give the bullet velocity in the direction the controller is pointing
	if bullet is RigidBody3D:
		bullet.linear_velocity = -global_transform.basis.z * bullet_speed

	# Fire rate cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
