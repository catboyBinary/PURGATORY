extends CharacterBody3D

@onready var dash_cooldown = find_child("DashCooldownTimer")
@onready var logic: PlayerLogic = $Logic

@export_group("Camera")
@export var rotatable : Node3D
@export var spring_arm : SpringArm3D
@export var camera : Camera3D

@export var fov = 90
@export var mouse_sensitivity := 0.005
@export_range(0, 90) var max_look_up_angle: float:
	set(value):
		max_look_up_angle = deg_to_rad(value)
	
@export_range(0, 90) var max_look_down_angle: float:
	set(value):
		max_look_down_angle = -deg_to_rad(value)

var third_person = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_setup()

func _physics_process(delta):
	var input_dir := Input.get_vector(
		&"move_left", &"move_right", 
		&"move_forward", &"move_backward"
	)
	
	var player_basis: Basis = rotatable.transform.basis
	var direction := (player_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	logic.movement_controller.update_velocity(
		self,
		rotatable.transform.basis,
		direction,
		delta
	)
	move_and_slide()
	
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed(&"third_person"):
		third_person = !third_person
		spring_arm.spring_length = int(third_person)*5
	
	if event.is_action_pressed(&"ui_cancel"):
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if not is_mouse_captured()
			else Input.MOUSE_MODE_VISIBLE
		)
	
	if event.is_action_pressed(&"shoot"):
		$Gun.stop()
		$Gun.play("shoot")

	# Moves the camera according to the movement of the cursor.
	elif is_mouse_captured() and (event is InputEventMouseMotion):
		rotatable.rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		
		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x, 
			max_look_down_angle, 
			max_look_up_angle
		)

func is_mouse_captured() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func camera_setup() -> void:
	camera.current = true
	camera.fov = fov
	spring_arm.position = Vector3(0, 1.5, 0)
	spring_arm.spring_length = 0
