class_name StateMachine extends RefCounted

var state: State


func set_state(new_state: State, force_reset: bool = false) -> void:
	if state != new_state or force_reset:
		if is_instance_valid(state):
			state.exit()
		state = new_state
		state.initialize()
		state.enter()
