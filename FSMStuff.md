# Player FSM Design

## Overview
3 (for now) FSMs to describe the player state:
**AbilityFSM,  V-MovementFSM,  GeneralFSM**.

*They are evaluated in that order.*

**AbilityFSM** describes whether a player is currently using an ability,
if the player does, it overrules any other state.

**V-MovementFSM** describes the state of the player's vertical momentum.

**GeneralFSM** describes general movement states.

---
## FSM states

### GeneralFSM states:
- Idle
- IdleCrouch
- Running
- Crouching
- Sliding
- WallRunning

### V-MovementFSM states:
- Idle
- Falling
- Rising
- JumpApex

### AbilityFSM states:
- Idle
- Dash
- Sword Dash

---
## GeneralFSM behaviour outline:
Player begins in Idle state.

```
last_state = state
match state:
	Idle:
		if (crouchButton)
			state = IdleCrouch
		elif (velocity) 
			state = Running
	IdleCrouch:
		if (!crouchButton) 
			state = Idle
		elif (velocity) 
			state = Crouching
	Running:
		if (not velocity):
			state = Idle
		elif (crouchButton):
			if (velocity.magnitude < slideThreshold) 
				state = Crouching
			else:
				state = Sliding
		elif (VMovement.state != OnFloor and goingInWall):
			state = WallRunning
	Crouching:
		if (not velocity):
			state = IdleCrouch
		elif (not crouchButton):
			state = Running
	Sliding:
		if (velocity.magnitude < slideThreshold):
			state = Crouching
		elif (not crouchButton):
			state = Running
	WallRunning:
		if (VMovement.state == OnFloor 
		or crouchButton 
		or jumpButton
		or velocity.magnitude < wallRunThreshhold):
			state = Running
			
if last_state != state:
	state = FSM(state)

return state
```
---
## V-MovementFSM behaviour outline:
Player's starting state depends on the level, most often it's Falling.

```
if (coyote):
	state = Idle
elif (velocity.y < jumpApexEnd):
	state = Falling
elif (velocity.y < jumpApexStart):
	state = JumpApex
else:
	state = Rising
```
