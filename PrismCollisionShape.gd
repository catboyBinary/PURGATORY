@tool
extends CollisionShape3D

@export_group("Collider")
@export var height = 50
@export var radius = 10
@export var sides_count = 3
@export_group("Chamfer")
@export_range(0, 45) var upper_angle = 50
@export var upper_radius = 10
@export_range(0, 45) var lower_angle = 50
@export var lower_radius = 10
@export_group("IN EDITOR")
@export var start: bool
func _process(delta: float):
	if start:
		shape = ConvexPolygonShape3D.new()
		var points : PackedVector3Array
		for i in range(1, sides_count+1):
			var angle : float = deg_to_rad(i*(360/sides_count))
			points.append(Vector3(radius*cos(angle),0,radius*sin(angle)))
		shape.points = points	
		print(shape.points)
		start = false
