@tool
extends ConvexPolygonShape3D
class_name PrismlikeColliderShape

@export_group("Collider")
@export var height : float

@export_range(0.1, 20, 0.1) var radius: float:
	set(value):
		radius = value
		update_points()
@export var sides_count: int = 3:
	set(value):
		sides_count = value
		update_points()

@export_group("Chamfer")
@export_range(0, 10) var upper_height: float = 0:
	set(value):
		upper_height = value
		update_points()
		
@export_range(0, 20) var upper_radius: float:
	set(value):
		upper_radius = value
		update_points()
		
@export_range(0, 10) var lower_height: float = 0:
	set(value):
		lower_height = value
		update_points()
@export_range(0, 20) var lower_radius : float:
	set(value):
		lower_radius = value
		update_points()
		
@export var twist = false:
	set(value):
		twist = value
		update_points()

func update_points():
	var new_points = PackedVector3Array()
	var angle_per_side := deg_to_rad(360/sides_count)
	var my_twist: float = angle_per_side / 2.0 if twist else 0.0
	
	if (lower_height != 0):
		if (lower_radius != 0):
			for i in range(sides_count):
				new_points.append(Vector3(
					lower_radius * cos(i * angle_per_side),
					- height / 2,
					lower_radius * sin(i * angle_per_side)
				))
		else:
			new_points.append(Vector3(
				0,
				-height / 2,
				0
			))
	
	for i in range(sides_count):
		new_points.append(Vector3(
			radius * cos(i * angle_per_side),
			- height / 2 + lower_height,
			radius * sin(i * angle_per_side)
		))
	
	for i in range(sides_count):
		new_points.append(Vector3(
			radius * cos(i * angle_per_side + my_twist),
			height / 2 - upper_height,
			radius * sin(i * angle_per_side + my_twist)
		))
		
	if (upper_height != 0):
		if (upper_radius != 0):
			for i in range(sides_count):
				new_points.append(Vector3(
					upper_radius * cos(i * angle_per_side + my_twist),
					height / 2,
					upper_radius * sin(i * angle_per_side + my_twist)
				))
		else:
			new_points.append(Vector3(
				0,
				height / 2,
				0
			))
	set_points(new_points)
