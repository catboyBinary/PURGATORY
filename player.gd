extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export_range(0.05, 0.2) var SENSITIVITY = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera := $Camera3D

func _input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * SENSITIVITY/10)
			camera.rotate_x(-event.relative.y * SENSITIVITY/10)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(90))

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var prev_vel = velocity
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		velocity += direction*SPEED/2

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		if is_on_floor():
			velocity.x = move_toward(prev_vel.x, direction.x*SPEED, 0.2)
			velocity.z = move_toward(prev_vel.z, direction.z*SPEED, 0.2)
		else:
			velocity.x = move_toward(prev_vel.x, direction.x*SPEED, SPEED*delta)
			velocity.z = move_toward(prev_vel.z, direction.z*SPEED, SPEED*delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(prev_vel.x, 0, 0.2)
			velocity.z = move_toward(prev_vel.z, 0, 0.2)
		else:
			velocity.x = move_toward(prev_vel.x, 0, SPEED*delta/2)
			velocity.z = move_toward(prev_vel.z, 0, SPEED*delta/2)
			
	print((velocity*Vector3(1,0,1)).normalized())
	prev_vel = velocity
	move_and_slide()
