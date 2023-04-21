extends CharacterBody3D


@export var SPEED := 5.0
@export var sprint_multiplier := 1.3
@export var jump_velocity := 5.0
@export_group("Camera")
@export var fov = 90
@export var mouse_sensitivity := 0.005
@export var camera_max_vertical_angle := 30
@export var camera_min_vertical_angle := -10

# Get the global gravity from the project settings. RigidBody3D nodes also use this value.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Nodes for camera management, replace these nodes by yours and remove the initialization in _ready.
var spring_arm := SpringArm3D.new()
var camera := Camera3D.new()
var third_person = false
var crouching
var running


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Nodes for the camera, a SpringArm3D that has a Camera3D as a child (to be deleted when using your nodes).
	camera.current = true
	camera.fov = fov
	spring_arm.position = Vector3(0, 1, 0) # Camera position relative to the player origin.
	spring_arm.spring_length = 0 # Set to 0 to get an FPS-like camera.
	spring_arm.add_child(camera)
	add_child(spring_arm)


func _unhandled_input(event) -> void:
	if event.is_action_pressed(&"third_person"):
		third_person = !third_person
		spring_arm.spring_length = int(third_person)*5
	# The mouse cursor is not visible in the game, you can toggle the behavior with the escape key.
	if event.is_action_pressed(&"ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE)

	# Moves the camera according to the movement of the cursor.
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(camera_min_vertical_angle), deg_to_rad(camera_max_vertical_angle))


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# As good practice, you should replace UI actions with custom gameplay actions.
	running = int(Input.is_action_pressed(&"run"))*(sprint_multiplier-1)+1

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Allow jumping only when on the floor.
	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = jump_velocity
		velocity += direction*SPEED

	# Get the input direction and handle the movement/deceleration.
	if direction:
		if is_on_floor():
			velocity.x = lerpf(velocity.x, direction.x*SPEED*running, SPEED*delta*4)
			velocity.z = lerpf(velocity.z, direction.z*SPEED*running, SPEED*delta*4)
		else:
			velocity.x = lerpf(velocity.x, direction.x*SPEED*running, SPEED*delta)
			velocity.z = lerpf(velocity.z, direction.z*SPEED*running, SPEED*delta)
	else:
		if is_on_floor():
			velocity.x = lerpf(velocity.x, 0, SPEED*delta*4)
			velocity.z = lerpf(velocity.z, 0, SPEED*delta*4)
		else:
			velocity.x = lerpf(velocity.x, 0, SPEED*delta/4)
			velocity.z = lerpf(velocity.z, 0, SPEED*delta/4)

	move_and_slide()