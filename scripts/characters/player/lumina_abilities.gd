extends Node

var character_body: CharacterBody3D
var body_mesh: MeshInstance3D
var face_mesh: MeshInstance3D
var hurt_box: Area3D

@onready var cooldownTimer = $GlowCooldown

@onready var div_attack_mode = preload("res://scripts/mechanics/divergence/attack_mode.gd")
@onready var div_defense_mode = preload("res://scripts/mechanics/divergence/defense_mode.gd")

var is_glowing := false
var is_on_cooldown := false

func _ready() -> void:
	check_for_character_body()
	define_needed_nodes_from_children()

func check_for_character_body():
	character_body = get_parent()
	if not character_body is CharacterBody3D:
		push_error("LuminaMovement must be a child of CharacterBody3D!")

func define_needed_nodes_from_children():
	var children = character_body.get_children()
	for child in children:
		if child.name == "MeshInstance3D":
			body_mesh = child
		elif child.name == "FaceMesh":
			face_mesh = child
		elif child.name == "HurtBox":
			hurt_box = child

func _process(delta: float) -> void:
	# Glowing 
	handle_glowing()

func handle_glowing():
	if Input.is_action_pressed("glow") and !is_glowing and !is_on_cooldown:
		character_body._on_started_glowing()
		is_glowing = true
		body_mesh.mesh.surface_get_material(0).emission_enabled = true
		hurt_box.set_deferred("monitoring", false)
		character_body.set_collision_layer_value(2, false)
		character_body.set_collision_mask_value(2, false)

	if Input.is_action_just_released("glow") and is_glowing:
		character_body._on_stopped_glowing()
		is_glowing = false
		body_mesh.mesh.surface_get_material(0).emission_enabled = false
		hurt_box.set_deferred("monitoring", true)
		character_body.set_collision_layer_value(2, true)
		character_body.set_collision_mask_value(2, true)
		is_on_cooldown = true
		cooldownTimer.start()

	# Divergence
	var attacked = Input.is_action_just_pressed("attack") 

	var defended = Input.is_action_pressed("defend")

	if attacked and defended:
		print("You can't attack and defend at the same time!")
		
	elif attacked:
		div_attack_mode.do_attack()
		print("Attack activated: " + str(div_attack_mode.is_mode_on))

	elif defended:
		div_defense_mode.defend()
		print("Defense activated: " + str(div_defense_mode.is_mode_on))
	

func _on_glow_cooldown_timeout() -> void:
	is_on_cooldown = false
