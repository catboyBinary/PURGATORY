extends Node
class_name PlayerLogic

enum AbilityState {
	IDLE,
	DASHING,
	SWORD_DASH
}

enum GeneralState {
	IDLE,
	IDLE_CROUCH,
	CROUCHING,
	RUNNING,
	SLIDING,
	WALL_RUNNING
}

enum VerticalState {
	IDLE,
	RISING,
	JUMP_APEX,
	FALLING
}

var current_state: GeneralState = GeneralState.IDLE
var current_ability: AbilityState = AbilityState.IDLE

var can_dash: bool = true
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var movement = $Movement

var coyote: bool = false
@onready var coyote_timer: Timer = $CoyoteTimer

var buffered_jump: bool = false
var last_state = current_state

func state_machine(state: GeneralState) -> GeneralState:
	last_state = state
	match state:
		GeneralState.IDLE:
			if movement.direction: state = GeneralState.RUNNING
			elif movement.crouching: state = GeneralState.IDLE_CROUCH
		GeneralState.IDLE_CROUCH:
			if movement.direction: state = GeneralState.CROUCHING
		GeneralState.RUNNING:
			if movement.direction == Vector3.ZERO: state = GeneralState.IDLE
				
	if state != last_state: state = state_machine(state)
	return state

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("dash") and can_dash):
		current_ability = AbilityState.DASHING
		can_dash = false
		dash_timer.start()
		dash_cooldown_timer.start()
		
	if (event.is_action_pressed("jump")):
		buffered_jump = true
	
	if (event.is_action_released("jump")):
		buffered_jump = false
		
func update_coyote(is_on_floor: bool, has_jumped: bool):
	if (has_jumped):
		if not coyote_timer.is_stopped():
			coyote_timer.stop()
		coyote = false
		return
	
	if (is_on_floor):
		if not coyote_timer.is_stopped():
			coyote_timer.stop()
		coyote = true
		return
	
	if coyote_timer.is_stopped() and coyote:
		coyote_timer.start()

func _on_dash_timer_timeout() -> void:
	current_ability = AbilityState.IDLE

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_coyote_timer_timeout() -> void:
	coyote = false
