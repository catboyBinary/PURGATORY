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

func _ready() -> void:
	shape = ConvexPolygonShape3D.new()
	for i in range(sides_count):
		print('a')
		var angle = 2 * PI * (i/sides_count)
		shape.points.append(Vector3(cos(angle),0,sin(angle))) 
