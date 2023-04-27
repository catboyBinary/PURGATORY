extends Node

@onready var player_logic: PlayerLogic = get_parent()
@onready var player: CharacterBody3D = get_parent().get_parent()
@export var rotatable : Node3D

@export var max_speed := 5
@export var jump_velocity := 7.0
@export var coyote := 0.1
@export var dash_speed := 7

var raw_decel: float = 0.2
var raw_accel: float = 1

# Get the global gravity from the project settings. RigidBody3D nodes also use this value.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var on_floor_coyote: bool
var coyote_time: float

var landing : bool

var dash_direction: Vector3

signal land
signal dashed

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(
		&"move_left", &"move_right", 
		&"move_forward", &"move_backward"
	)
	var direction := (rotatable.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if (player.is_on_floor()):
		if landing:
			land.emit()
			landing = false
		player_logic.coyote = true
		player_logic.coyote_timer.stop()
	else:
		if !landing:
			landing = true
		player_logic.coyote_timer.start()
	
	match player_logic.state:
		PlayerLogic.State.DASHING:
			dashed.emit()
			if (dash_direction == Vector3.ZERO):
				dash_direction = direction
			player.velocity = dash(dash_direction)
		PlayerLogic.State.OTHER:
			dash_direction = Vector3.ZERO
			player.velocity = general_movement(player.velocity, direction, delta)
		
	player.move_and_slide()

func dash(direction: Vector3) -> Vector3:
	return direction * dash_speed
	
func general_movement(
	velocity: Vector3, 
	direction: Vector3, 
	delta: float
) -> Vector3:
	var new_vertical_velocity = get_vertical_velocity(velocity, delta)
	
	#flatten that
	velocity.y = 0
	
	var decel := -velocity.normalized() * raw_decel
	var accel := direction.normalized() * raw_accel
	
	if (velocity.length_squared() < decel.length_squared()):
		velocity = Vector3.ZERO
	else:
		velocity += decel
		
	velocity = (velocity + accel).limit_length(max_speed)
	velocity.y = new_vertical_velocity
	
	return velocity
	
func get_vertical_velocity(velocity: Vector3, delta: float) -> float:
	if (not player.is_on_floor()):
		velocity.y -= gravity * delta
		
	if (player_logic.coyote):
		if Input.is_action_just_pressed(&"jump"):
			velocity.y = jump_velocity
			player_logic.coyote = false
			player_logic.coyote_timer.stop()

	return velocity.y
