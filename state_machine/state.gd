class_name State extends RefCounted

var is_complete: bool
var parent: State
var start_time: float
var state_machine: StateMachine

var state = func(): return state_machine.state


func enter() -> void:
	pass


func exit() -> void:
	pass


func get_runtime() -> float:
	return Time.get_unix_time_from_system() - start_time


func initialize() -> void:
	is_complete = false
	start_time = Time.get_unix_time_from_system()


func physics_update() -> void:
	pass


func physics_update_branch() -> void:
	physics_update()
	if is_instance_valid(state):
		state.physics_update_branch()


func set_state(new_state: State, force_reset: bool = false) -> void:
	state_machine.set_state(new_state, force_reset)


func update() -> void:
	pass


func update_branch() -> void:
	update()
	if is_instance_valid(state):
		state.update_branch()
