extends Node
class_name PlayerLogic

@onready var player = get_parent()

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

signal general_state_changed(state: GeneralState)
signal vertical_state_changed(state: VerticalState)

var general_state  := GeneralState.IDLE
var ability_state  := AbilityState.IDLE
var vertical_state := VerticalState.IDLE

var can_dash: bool = true
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var movement = $Movement

var coyote: bool = false
@onready var coyote_timer: Timer = $CoyoteTimer

var buffered_jump: bool = false
var last_general_state = general_state
var last_vertical_state = general_state

func general_state_machine(state: GeneralState) -> GeneralState:
	last_general_state = state
	var flat_velocity = player.velocity
	flat_velocity.y = 0
	var speed_sq = flat_velocity.length_squared()
	match state:
		GeneralState.IDLE:
			if speed_sq >= 0.01: state = GeneralState.RUNNING
			elif movement.crouching: state = GeneralState.IDLE_CROUCH
		GeneralState.IDLE_CROUCH:
			if speed_sq >= 0.01: state = GeneralState.CROUCHING
		GeneralState.CROUCHING:
			if speed_sq < 0.01: state = GeneralState.IDLE_CROUCH
		GeneralState.RUNNING:
			if speed_sq < 0.01: state = GeneralState.IDLE
				
	if state != last_general_state: state = general_state_machine(state)
	general_state_changed.emit()
	return state
	
func vertical_state_machine(state: VerticalState) -> VerticalState:
	last_vertical_state = state
	
	if player.velocity.y > 0.25: state = VerticalState.RISING
	elif -0.25 <= player.velocity.y and player.velocity.y <= 0.25: state = VerticalState.JUMP_APEX	
	elif player.velocity.y < -0.25: state = VerticalState.FALLING
	
	if coyote: state = VerticalState.IDLE
	
	if state != last_vertical_state: state = vertical_state_machine(state)
	general_state_changed.emit()
	return state

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("dash") and can_dash):
		ability_state = AbilityState.DASHING
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
	ability_state = AbilityState.IDLE

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_coyote_timer_timeout() -> void:
	coyote = false
