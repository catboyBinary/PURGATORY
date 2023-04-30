extends Node
class_name MovementController

@onready var logic: PlayerLogic = get_parent()

@export var max_speed := 5
@export var jump_velocity := 7.0
@export var coyote := 0.1
@export var dash_speed := 40

var raw_decel: float = 0.2
var raw_accel: float = 1

var dash_direction: Vector3 = Vector3.ZERO
var landing := false

# я не ебу к чему бинари привязал эти сигналы, но звуков после рефакторинга нет
signal land
signal dashed

signal update_general_state(speed_squared: float, is_crouching: bool)
signal update_vertical_state(vertical_velocity: float, force_idle: bool)

func update_velocity(player: CharacterBody3D, basis: Basis, direction: Vector3, delta: float):
	if (logic.ability_state == FSMStates.Ability.IDLE):
		var last_vertical_state := logic.vertical_state
		var vertical_velocity  := vertical_movement(player, delta)
		
		# Перенести отсюда куда-нибудь в логику
		if (logic.vertical_state == FSMStates.Vertical.IDLE and
			last_vertical_state != FSMStates.Vertical.IDLE):
				land.emit()
		
		var flattened_velocity := player.velocity
		flattened_velocity.y = 0
		
		player.velocity = GeneralMovement.move(
			flattened_velocity, 
			direction,
			raw_decel,
			raw_accel,
			max_speed,
			delta
		)
		player.velocity.y = vertical_velocity
		dash_direction = direction
		
		update_general_state.emit(flattened_velocity.length_squared(), false)
		update_vertical_state.emit(vertical_velocity, logic.coyote)
	else:
		if (logic.ability_state == FSMStates.Ability.DASHING):
			# это тоже перенести
			if (player.velocity != dash_direction * dash_speed):
				dashed.emit()
			if dash_direction == Vector3.ZERO: 
				dash_direction = basis * Vector3.FORWARD
			player.velocity = dash_direction * dash_speed
			
	
func vertical_movement(player: CharacterBody3D, delta: float) -> float:
	var on_floor   := player.is_on_floor()
	var has_jumped := false
	
	var velocity := VerticalMovement.move(
		player.velocity.y,
		on_floor,
		delta
	)
	
	if logic.coyote and logic.buffered_jump:
		velocity = VerticalMovement.jump(jump_velocity)
		logic.buffered_jump = false
		on_floor = false
		has_jumped = true
	
	logic.update_coyote(on_floor, has_jumped)
	logic.vertical_state = FSMStates.Vertical.IDLE
	return velocity
