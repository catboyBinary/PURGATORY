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

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("dash") and can_dash):
		state = State.DASHING
		can_dash = false
		dash_timer.start()
		dash_cooldown_timer.start()

func _on_dash_timer_timeout() -> void:
	state = State.OTHER

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_coyote_timer_timeout() -> void:
	coyote = false
