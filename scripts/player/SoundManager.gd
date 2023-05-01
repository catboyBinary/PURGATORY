extends Node
@onready var player = get_parent()

func _on_ability_state_changed(state):
	match state:
		FSMStates.Ability.IDLE:
			if player.logic.general_state == FSMStates.General.RUNNING: 
				$Movement/Step.play()
		FSMStates.Ability.DASHING:
			$Ability/Dash.play()
			$Movement/Step.stop()
		FSMStates.Ability.SWORD_DASH:
			$Ability/SwordDash.play()


func _on_general_state_changed(state):
	match state:
		FSMStates.General.RUNNING:
			$Movement/Step.play()
		_:
			$Movement/Step.stop()


func _on_vertical_state_changed(state):
	match state:
		FSMStates.Vertical.IDLE:
			if player.logic.general_state == FSMStates.General.RUNNING: 
				$Movement/Step.play()
		_:
			$Movement/Step.stop()
