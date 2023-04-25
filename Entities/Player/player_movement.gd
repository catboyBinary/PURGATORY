extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()
@export var rotatable : Node3D

@export var SPEED := 5
@export var sprint_multiplier := 1.3
@export var jump_velocity := 5.0
@export var coyote := 0.1

const MAX_SPEED: float = 5

# Get the global gravity from the project settings. RigidBody3D nodes also use this value.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var crouching: bool
var running: bool
var on_floor_coyote: bool
var coyote_time: float

const decel_time: float = 1 / 10

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")
	var direction := (rotatable.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var velocity: Vector3 = player.velocity
	var plane_velocity := velocity
	plane_velocity.y = 0
	
	running = Input.is_action_pressed(&"run")
	
	on_floor_coyote = coyote_floor(delta)
	velocity = vertical_movement(velocity, direction, delta)
	
	var decel := -plane_velocity.normalized() / 5
	
	if (plane_velocity.length_squared() < decel.length_squared()):
		plane_velocity = Vector3.ZERO
	else:
		plane_velocity += decel
		
	var accel := direction.normalized()
	
	plane_velocity = (plane_velocity + accel).limit_length(MAX_SPEED)
	
	player.velocity = plane_velocity
	player.velocity.y = velocity.y
	player.move_and_slide()

func coyote_floor(delta: float) -> bool:
	if player.is_on_floor(): coyote_time = coyote
	elif coyote_time > 0: coyote_time -= delta
	return coyote_time > 0
	
func vertical_movement(velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	if on_floor_coyote:
		if Input.is_action_just_pressed(&"jump"):
			velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta
		
	return velocity
