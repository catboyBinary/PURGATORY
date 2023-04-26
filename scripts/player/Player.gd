extends CharacterBody3D

@onready var dash_cooldown = find_child("DashCooldownTimer")

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
var crouching
var running


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_setup()

func _unhandled_input(event) -> void:
	if event.is_action_pressed(&"third_person"):
		third_person = !third_person
		spring_arm.spring_length = int(third_person)*5
	
	if event.is_action_pressed(&"ui_cancel"):
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if not is_mouse_captured()
			else Input.MOUSE_MODE_VISIBLE
		)

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
