extends Node

signal vertical_state_changed(state: FSMStates.Vertical)

var state := FSMStates.Vertical.IDLE

func run(vertical_velocity: float, force_idle: bool) -> void:
	if vertical_velocity > 0.25: 
		state = FSMStates.Vertical.RISING
	elif -0.25 <= vertical_velocity and vertical_velocity <= 0.25: 
		state = FSMStates.Vertical.JUMP_APEX
	elif vertical_velocity < -0.25: 
		state = FSMStates.Vertical.FALLING
	
	if force_idle:
		state = FSMStates.Vertical.IDLE
	vertical_state_changed.emit(state)
