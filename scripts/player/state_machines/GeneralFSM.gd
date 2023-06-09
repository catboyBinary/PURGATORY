extends Node

signal general_state_changed(state: FSMStates.General)

var state := FSMStates.General.IDLE

func run(
	speed_squared: float,
	is_crouching: bool 
) -> void:
	var requires_checking := true
	
	while (requires_checking):
		var last_general_state := state
		
		match state:
			FSMStates.General.IDLE:
				if speed_squared >= 0.1: 
					state = FSMStates.General.RUNNING
				elif is_crouching: 
					state = FSMStates.General.IDLE_CROUCH
			FSMStates.General.RUNNING:
				if is_crouching: 
					state = FSMStates.General.CROUCHING
				elif speed_squared < 0.1: 
					state = FSMStates.General.IDLE
			FSMStates.General.IDLE_CROUCH:
				if !is_crouching:
					state = FSMStates.General.IDLE
				elif speed_squared >= 0.1: 
					state = FSMStates.General.CROUCHING
			FSMStates.General.CROUCHING:
				if !is_crouching:
					state = FSMStates.General.IDLE
				elif speed_squared < 0.1: 
					state = FSMStates.General.IDLE_CROUCH
			
				
		requires_checking = state != last_general_state
		if (requires_checking): general_state_changed.emit(state)
