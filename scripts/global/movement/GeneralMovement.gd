extends Node

class_name GeneralMovement

static func move(
	velocity: Vector3, 
	direction: Vector3,
	decel_factor: float,
	accel_factor: float,
	speed_cap: float,
	speed_cap_strength: float,
	delta: float
) -> Vector3:
	var decel := -velocity.normalized() * decel_factor
	var accel := direction.normalized() * accel_factor
	
	velocity = (velocity + accel)
	
	if (velocity.length_squared() < decel.length_squared()):
		velocity = Vector3.ZERO
	else:
		velocity += decel
	
	var cap_squared := speed_cap * speed_cap
	
	if (velocity.length_squared() >= cap_squared):
		velocity = velocity.lerp(velocity.limit_length(speed_cap), speed_cap_strength)
	
	return velocity
