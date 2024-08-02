extends Node

var state_machine:= StateMachine.new()

@onready var game_state_logo: GameState = %GameStateLogo
@onready var game_state_menu: GameState = %GameStateMenu
@onready var game_state_classic: GameState = %GameStateClassic
@onready var game_state_snakeo: GameState = %GameStateSnakeo
@onready var game_state_dungeon: GameState = %GameStateDungeon
@onready var states: Node = %States


func _ready() -> void:
	for game_state in states.get_children():
		game_state.game_state_manager = self

	state_machine.set_state(game_state_logo)


func _physics_process(_delta: float) -> void:
	state_machine.state.physics_update_branch()


func _process(_delta: float) -> void:
	if state_machine.state.is_complete:
		choose_next_state()

	state_machine.state.update_branch()


func choose_next_state() -> void:
	match state_machine.state:
		game_state_logo:
			state_machine.set_state(game_state_menu)
		game_state_menu:
			var next_state: State = game_state_menu.next_state
			state_machine.set_state(next_state)
		game_state_classic:
			var next_state: State = game_state_classic.next_state
			state_machine.set_state(next_state)
