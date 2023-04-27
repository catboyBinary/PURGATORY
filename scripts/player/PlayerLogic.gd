extends Node
class_name PlayerLogic

enum State {
	DASHING,
	OTHER
}

var state: State = State.OTHER

var can_dash: bool = true
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

var coyote: bool = false
@onready var coyote_timer: Timer = $CoyoteTimer

var buffered_jump: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("dash") and can_dash):
		state = State.DASHING
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
	state = State.OTHER

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_coyote_timer_timeout() -> void:
	coyote = false
