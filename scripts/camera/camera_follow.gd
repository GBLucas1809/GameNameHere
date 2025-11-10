extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 3, -6)

func _process(delta: float) -> void:
	if target == null:
		return

	# Get the desired camera position (relative to the player)
	var desired_position = target.global_transform.origin + offset

	# Smoothly interpolate to it
	global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_speed)
