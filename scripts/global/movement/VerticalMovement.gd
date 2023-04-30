extends Node
class_name VerticalMovement

const gravity: float = 15

static func move(
	vertical_velocity: float, 
	on_floor: bool,
	delta: float
) -> float:
	if (!on_floor):
		vertical_velocity -= gravity * delta
		
	return vertical_velocity

static func jump(
	jump_velocity: float
) -> float:
	return jump_velocity
