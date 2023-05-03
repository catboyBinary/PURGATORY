extends Node

class_name GeneralMovement

static func move(
	velocity: Vector3, 
	direction: Vector3,
	decel_factor: float,
	accel_factor: float,
	speed_hard_cap: float,
	delta: float
) -> Vector3:
	var decel := -velocity.normalized() * decel_factor
	var accel := direction.normalized() * accel_factor
	
	if (velocity.length_squared() < decel.length_squared()):
		velocity = Vector3.ZERO
	else:
		velocity += decel
		
	velocity = (velocity + accel).limit_length(speed_hard_cap)
	
	return velocity
