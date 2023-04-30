extends Node
class_name PlayerLogic

@onready var player: CharacterBody3D = get_parent()
@onready var movement_controller: MovementController = $MovementController

# signal general_state_changed(state: GeneralState)
# signal vertical_state_changed(state: VerticalState)

var ability_state  := FSMStates.Ability.IDLE
var general_state  := FSMStates.General.IDLE
var vertical_state := FSMStates.Vertical.IDLE

var can_dash: bool = true
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

var coyote: bool = false
@onready var coyote_timer: Timer = $CoyoteTimer

var buffered_jump: bool = false

signal update_ability_state(state: FSMStates.Ability)

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("dash") and can_dash):
		update_ability_state.emit(FSMStates.Ability.DASHING)
		can_dash = false
		dash_timer.start()
		dash_cooldown_timer.start()
		
	if (event.is_action_pressed("jump")):
		buffered_jump = true
	
	if (event.is_action_released("jump")):
		buffered_jump = false
		
func update_coyote(is_on_floor: bool, has_jumped: bool):
	if (has_jumped):
		coyote_timer.stop()
		coyote = false
		return
	
	if (is_on_floor):
		coyote = true
		coyote_timer.start()
		return

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_coyote_timer_timeout() -> void:
	coyote = false

func _on_ability_state_changed(state) -> void:
	ability_state = state

func _on_general_state_changed(state) -> void:
	general_state = state

func _on_vertical_state_changed(state) -> void:
	vertical_state = state
