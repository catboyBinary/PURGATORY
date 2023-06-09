extends Control
class_name PlayerUI

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$GeneralState.text = "general_state: " + str(FSMStates.General.keys()[player.logic.general_state])
	$AbilityState.text = "ability_state: " + str(FSMStates.Ability.keys()[player.logic.ability_state])
	$VerticalState.text = "vertical_state: " + str(FSMStates.Vertical.keys()[player.logic.vertical_state])
	$FPS.text = "fps: " + str(Engine.get_frames_per_second())
	
	$DashTimer.max_value = player.dash_cooldown.wait_time
	$DashTimer.value = 1 - player.dash_cooldown.time_left
	if $DashTimer.value == $DashTimer.max_value:
		$DashTimer.visible = false
	else:
		$DashTimer.visible = true

