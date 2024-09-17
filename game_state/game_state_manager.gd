extends Node

var state_machine:= StateMachine.new()

@onready var game_state_logo: GameState = %GameStateLogo
@onready var game_state_menu: GameState = %GameStateMenu
@onready var game_state_classic: GameState = %GameStateClassic
@onready var game_state_snakeo: GameState = %GameStateSnakeo
@onready var game_state_dungeon: GameState = %GameStateDungeon
@onready var game_state_settings: GameState = %GameStateSettings
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
			_gamemode_next_state(game_state_menu)
		game_state_classic:
			_gamemode_next_state(game_state_classic)
		game_state_snakeo:
			_gamemode_next_state(game_state_snakeo)
		game_state_dungeon:
			_gamemode_next_state(game_state_dungeon)
		game_state_settings:
			_gamemode_next_state(game_state_settings)


func _gamemode_next_state(game_state: GameState) -> void:
	var next_state: State = game_state.next_state
	state_machine.set_state(next_state)
