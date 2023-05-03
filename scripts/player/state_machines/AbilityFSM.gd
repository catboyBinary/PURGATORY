extends Node

signal ability_state_changed(state: FSMStates.Ability)

var state := FSMStates.Ability.IDLE
var queued_state := FSMStates.Ability.IDLE

func run(
	new_state: FSMStates.Ability,
) -> void:
	match state:
		FSMStates.Ability.IDLE:
			state = new_state
		FSMStates.Ability.DASHING:
			state = new_state
		FSMStates.Ability.SWORD_DASH:
			state = new_state
	ability_state_changed.emit(state)

func _on_dash_timer_timeout() -> void:
	run(queued_state)
