@tool
extends MeshInstance3D
var wing1
var wing2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wing1 = get_parent().get_node("wing1")
	wing2 = get_parent().get_node("wing2")
	wing1.position = wing1.position.lerp(position+rotated_as(Vector3(1,1,-1),rotation),delta*7)
	wing2.position = wing2.position.lerp(position+rotated_as(Vector3(-1,1,-1),rotation),delta*7)

func rotated_as(vector: Vector3, rotation: Vector3) -> Vector3:
	var rotated_vector = vector
	rotated_vector = rotated_vector.rotated(Vector3.BACK,rotation.z)
	rotated_vector = rotated_vector.rotated(Vector3.UP,rotation.y)
	rotated_vector = rotated_vector.rotated(Vector3.RIGHT,rotation.x)
	return rotated_vector
