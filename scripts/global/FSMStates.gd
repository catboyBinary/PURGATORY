extends Node
class_name FSMStates

enum Ability {
	IDLE,
	DASHING,
	SWORD_DASH
}

enum General {
	IDLE,
	IDLE_CROUCH,
	CROUCHING,
	RUNNING,
	SLIDING,
	WALL_RUNNING
}

enum Vertical {
	IDLE,
	RISING,
	JUMP_APEX,
	FALLING
}
