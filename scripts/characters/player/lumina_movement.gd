class_name LuminaMovement
extends Node

signal started_floating()
signal stopped_floating()
signal jumped()
signal entered_water()
signal exited_water()

@export var jump_height : float = 10.0
@export var jump_time_to_peak : float = 0.5
@export var jump_time_to_descent : float = 0.4
@export var jump_time_buffer : float = 0.1
@export var coyote_time : float = 0.1

var buffer_timer : float = 0.0
var coyote_timer : float = 0.0

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))

@export var water_float_duration := 3.0

@export var water_detection_ray_length := 2.0

var jump_available := true
var is_floating := false
var is_in_water := false
var float_timer := 0.0
var character_body: CharacterBody3D

func _ready():
	check_for_character_body()

func check_for_character_body():
	character_body = get_parent()
	if not character_body is CharacterBody3D:
		push_error("LuminaMovement must be a child of CharacterBody3D!")

func _process(delta: float) -> void:
	buffer_timer -= delta

func process_movement(delta: float) -> void:

	var direction = get_movement_direction()

	check_water_state()
	
	handle_movement(direction, delta)
	handle_character_direction()
	handle_gravity(delta)
	handle_jump_availability()
	handle_jump()
	handle_floating(delta)

func check_water_state():

	var space_state = character_body.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		character_body.global_position,
		character_body.global_position + Vector3.DOWN * water_detection_ray_length
	)
	query.exclude = [character_body]
	
	var result = space_state.intersect_ray(query)
	
	var was_in_water = is_in_water
	is_in_water = false
	
	if result:
		var collider = result.collider
		if collider and (collider.is_in_group("water") or "water" in collider.name.to_lower()):
			is_in_water = true

	if was_in_water != is_in_water:
		if is_in_water:
			entered_water.emit()
		else:
			exited_water.emit()

func get_movement_direction() -> Vector3:
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	return input_dir.normalized()

func handle_movement(direction: Vector3, delta: float) -> void:
	
	character_body.velocity.x = Vector3(direction.x * 10, 0, 0).x

func handle_character_direction():

	if character_body.velocity.x > 0:
		character_body.rotation.y = 2 * PI
	elif character_body.velocity.x < 0:
		character_body.rotation.y = PI

func handle_gravity(delta: float) -> void:
	var current_gravity = gravity
	if character_body.velocity.y > 0.0:
		current_gravity = fall_gravity
	character_body.velocity.y += current_gravity * delta

func handle_jump_availability():
	if character_body.is_on_floor():
		jump_available = true
		coyote_timer = coyote_time
	
	if !character_body.is_on_floor() and coyote_timer <= 0:
		jump_available = true

func handle_jump() -> void:

	if Input.is_action_just_pressed("jump"):
		buffer_timer = jump_time_buffer

	if jump_available == true and buffer_timer > 0:
		character_body.velocity.y = jump_velocity
		jumped.emit()
		jump_available = false
	elif is_floating and float_timer > 0 and buffer_timer > 0 and jump_available == true:
		# Optional: Double jump while floating (only in water)
		if is_in_water:
			character_body.velocity.y = jump_velocity * 0.8
			jump_available = false
			start_floating()
			jumped.emit()

func handle_floating(delta: float) -> void:
	if is_floating:
		float_timer -= delta
		if float_timer <= 0:
			stop_floating()

func start_floating() -> void:
	if not is_floating:
		is_floating = true
		if is_in_water:
			float_timer = water_float_duration
		started_floating.emit()

func stop_floating() -> void:
	if is_floating:
		is_floating = false
		float_timer = 0.0
		stopped_floating.emit()

func is_currently_floating() -> bool:
	return is_floating

func is_in_water_area() -> bool:
	return is_in_water

func get_remaining_float_time() -> float:
	return float_timer

func cancel_floating() -> void:
	stop_floating()

# Method to manually set water state (for area-based detection)
func set_water_state(in_water: bool):
	if is_in_water != in_water:
		is_in_water = in_water
		if in_water:
			entered_water.emit()
		else:
			exited_water.emit()
