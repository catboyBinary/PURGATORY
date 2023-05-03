extends SpringArm3D

@onready var camera: Camera3D = $Camera3D
@export var fov: float

@export var standing_anchor: Node3D
@export var crouching_anchor: Node3D
@export var sliding_anchor: Node3D

@export var logic: PlayerLogic

var standing_pos: Vector3
var crouching_pos: Vector3
var sliding_pos: Vector3

var target_position: Vector3

func _ready() -> void:
	camera.fov = fov
	spring_length = 0
	
	standing_pos  = standing_anchor.position
	crouching_pos = crouching_anchor.position
	sliding_pos   = sliding_anchor.position
	
	position = standing_pos
	target_position = standing_pos
	
	set_process(false)

func _process(delta: float) -> void:
	if (position != target_position):
		position = position.lerp(target_position, 0.01)
	else:
		set_process(false)

func align_camera(state: FSMStates.General):
	match (state):
		FSMStates.General.IDLE_CROUCH, FSMStates.General.CROUCHING:
			target_position = crouching_pos
			set_process(true)
		_:
			target_position = standing_pos
			set_process(true)

func _on_general_state_changed(state) -> void:
	if (logic.ability_state == FSMStates.Ability.IDLE):
		align_camera(state)

func _on_ability_state_changed(state) -> void:
	if (state == FSMStates.Ability.IDLE):
		align_camera(logic.general_state)
	else:
		align_camera(FSMStates.General.IDLE)
