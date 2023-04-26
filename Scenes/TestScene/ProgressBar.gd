extends ProgressBar

@export var player : CharacterBody3D

func _process(delta : float):
	max_value = player.find_child("DashCooldownTimer").wait_time
	value = 1 - player.find_child("DashCooldownTimer").time_left
	if value == max_value:
		visible = false
	else:
		visible = true
