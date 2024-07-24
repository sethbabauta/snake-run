extends Node

var state_machine:= StateMachine.new()

var logo:= GameStateLogo.new()
var menu:= GameStateMenu.new()
var classic:= GameStateClassic.new()



func _ready() -> void:
	state_machine.set_state(logo)
