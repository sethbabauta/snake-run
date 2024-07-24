extends Node

var state_machine:= StateMachine.new()

var logo:= GameStateLogo.new(self)
var menu:= GameStateMenu.new(self)
var classic:= GameStateClassic.new(self)


func _ready() -> void:
	state_machine.set_state(logo)


func _physics_process(_delta: float) -> void:
	state_machine.state.physics_update_branch()


func _process(_delta: float) -> void:
	if state_machine.state.is_complete:
		choose_next_state()

	state_machine.state.update_branch()


func choose_next_state() -> void:
	match state_machine.state:
		logo:
			state_machine.set_state(menu)
		menu:
			var next_state: State = menu.next_state
			state_machine.set_state(next_state)
