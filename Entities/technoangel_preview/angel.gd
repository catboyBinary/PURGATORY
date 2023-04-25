@tool
extends MeshInstance3D
var wing1
var wing2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wing1 = get_parent().get_node("wing1")
	wing2 = get_parent().get_node("wing2")
	wing1.position = wing1.position.lerp(position+Vector3(1,1,1),delta*7)
	wing2.position = wing2.position.lerp(position+Vector3(-1,1,1),delta*7)
