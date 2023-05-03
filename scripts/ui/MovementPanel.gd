extends Panel

@export var ui: PlayerUI
var flat_velocity: Vector2 = Vector2.ZERO
var last_velocity: Vector2 = Vector2.ZERO
var orientation_camera := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("orientation_toggle"):
		orientation_camera = not orientation_camera

func _physics_process(delta: float) -> void:
	last_velocity = flat_velocity
	flat_velocity = Vector2(ui.player.velocity.x, ui.player.velocity.z)
	
	var speed = snappedf(flat_velocity.length(), 0.01)
	var accel := (flat_velocity - last_velocity)
	
	var accel_value = snappedf(accel.length(), 0.01)
	$Speed.text = "Velocity: " + str(speed)
	$Acceleration.text = "Acceleration: " + str(accel_value)
	$Orientation.text = "Orientation: "
	
	$Orientation.text += "Camera" if orientation_camera else "World"
	
	var presented_velocity := flat_velocity.limit_length(5) * 5
	var presented_accel    := accel.limit_length(5) * 20
	
	if (orientation_camera):
		presented_velocity = presented_velocity.rotated(ui.player.rotatable.rotation.y)
		presented_accel = presented_accel.rotated(ui.player.rotatable.rotation.y)
	
	$VelocityArrow.set_point_position(1, presented_velocity)
	$AccelArrow.set_point_position(0, presented_velocity)
	$AccelArrow.set_point_position(1, presented_velocity + presented_accel)
