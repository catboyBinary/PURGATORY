extends Node
class_name MovementController

@onready var logic: PlayerLogic = get_parent()

var raw_decel: float
var raw_accel: float

@export var max_speed := 5
@export var time_to_full_stop: float:
	set(value):
		raw_decel = max_speed / value / float(Engine.physics_ticks_per_second)
@export var time_to_full_speed: float:
	set(value):
		raw_accel = max_speed / value / float(Engine.physics_ticks_per_second)
		# компенсируем факт того что замедление у нас применяется всегда
		raw_accel += raw_decel
@export_range(0, 1) var speed_cap_strength: float = 0.9

# jump-height = 1/2 * jump-velocity^2 / gravity
@export var jump_duration: float:
	set(value):
		jump_duration = value
		gravity = 8 * (jump_height / pow(jump_duration, 2))
		jump_velocity = gravity * 0.5 * jump_duration
@export var jump_height: float:
	set(value):
		jump_height = value
		gravity = 8 * (jump_height / pow(jump_duration, 2))
		jump_velocity = gravity * 0.5 * jump_duration
	
var gravity: float
var jump_velocity: float

var dash_direction: Vector3 = Vector3.ZERO

func update_velocity(player: CharacterBody3D, basis: Basis, direction: Vector3, delta: float):
	stuck_check()
	
	if (logic.ability_state == FSMStates.Ability.IDLE):
		var last_vertical_state := logic.vertical_state
		var vertical_velocity  := vertical_movement(player, delta)
		
		var flattened_velocity := player.velocity
		flattened_velocity.y = 0
		
		player.velocity = GeneralMovement.move(
			flattened_velocity, 
			direction,
			raw_decel,
			raw_accel,
			max_speed,
			speed_cap_strength,
			delta
		)
		player.velocity.y = vertical_velocity
		dash_direction = direction
		
		logic.general_fsm.run(flattened_velocity.length_squared(), logic.is_crouching)
		logic.vertical_fsm.run(vertical_velocity, logic.coyote)
	else:
		if (logic.ability_state == FSMStates.Ability.DASHING):
			var curve_offset := remap(
				logic.dash_timer.time_left,
				0,
				logic.dash_timer.wait_time,
				0,
				1
			)
			if dash_direction == Vector3.ZERO: 
				dash_direction = basis * Vector3.FORWARD
			player.velocity = dash_direction * logic.dash_speed
			player.velocity *= logic.dash_curve.sample_baked(curve_offset)

func stuck_check():
	if (logic.is_crouching):
		logic.can_stand_up = not logic.stand_up_check.has_overlapping_bodies()
		
	if (logic.holds_crouch_button):
		logic.is_crouching = true
	else:
		if (logic.can_stand_up):
			logic.is_crouching = false
		else:
			logic.is_crouching = true
	
func vertical_movement(player: CharacterBody3D, delta: float) -> float:
	var on_floor   := player.is_on_floor()
	var has_jumped := false
	
	print(gravity)
	
	var velocity := VerticalMovement.move(
		player.velocity.y,
		on_floor,
		gravity,
		delta
	)
	
	if logic.coyote and logic.buffered_jump:
		velocity = VerticalMovement.jump(jump_velocity)
		logic.buffered_jump = false
		on_floor = false
		has_jumped = true
	
	logic.update_coyote(on_floor, has_jumped)
	return velocity
