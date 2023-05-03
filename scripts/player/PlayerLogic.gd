extends Node
class_name PlayerLogic

@onready var player: CharacterBody3D = get_parent()
@onready var movement_controller: MovementController = $MovementController

# signal general_state_changed(state: GeneralState)
# signal vertical_state_changed(state: VerticalState)

var ability_state  := FSMStates.Ability.IDLE
var general_state  := FSMStates.General.IDLE
var vertical_state := FSMStates.Vertical.IDLE

@onready var ability_fsm  = $StateMachines/AbilityFSM
@onready var general_fsm  = $StateMachines/GeneralFSM
@onready var vertical_fsm = $StateMachines/VerticalFSM

var can_dash: bool = true
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

var coyote: bool = false
@onready var coyote_timer: Timer = $CoyoteTimer

var buffered_jump: bool = false

var holds_crouch_button: bool = false
var is_crouching: bool = false
var can_stand_up: bool = true

@export_group("Colliders, my beloved")
@export var standing_collider:  CollisionShape3D
@export var crouching_collider: CollisionShape3D
@export var stand_up_check: Area3D

@export_group("Abilities")
@export var dash_time: float
@export var dash_distance: float:
	set(value):
		dash_speed = value / dash_time

var dash_speed: float

func _ready() -> void:
	dash_timer.wait_time = dash_time

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("dash") and can_dash and can_stand_up):
		ability_fsm.run(FSMStates.Ability.DASHING)
		can_dash = false
		dash_timer.start()
		dash_cooldown_timer.start()
		
	if (event.is_action_pressed("jump")):
		buffered_jump = true
	if (event.is_action_released("jump")):
		buffered_jump = false
		
	if (event.is_action_pressed("crouch")):
		holds_crouch_button = true
	if (event.is_action_released("crouch")):
		holds_crouch_button = false
		
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
	
	match (state):
		FSMStates.General.CROUCHING, FSMStates.General.IDLE_CROUCH:
			standing_collider.disabled = true
			crouching_collider.disabled = false
		_:
			standing_collider.disabled = false
			crouching_collider.disabled = true

func _on_vertical_state_changed(state) -> void:
	vertical_state = state
