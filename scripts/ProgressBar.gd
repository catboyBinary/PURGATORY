extends ProgressBar

@onready var ui = get_parent()

func _process(delta : float):
	max_value = ui.player.dash_cooldown.wait_time
	value = 1 - ui.player.dash_cooldown.time_left
	if value == max_value:
		visible = false
	else:
		visible = true
