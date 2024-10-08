extends GameState

var dungeon_state_machine:= StateMachine.new()
var current_screen: Node

@onready var wait: Node = $States/Wait
@onready var start_game: DungeonState = $States/StartGame
@onready var collect_apples: DungeonState = $States/CollectApples
@onready var clear_room: DungeonState = $States/ClearRoom
@onready var roam_free: DungeonState = $States/RoamFree
@onready var enter_room: DungeonState = $States/EnterRoom
@onready var win: DungeonState = $States/Win
@onready var lose: DungeonState = $States/Lose
@onready var die: Node = $States/Die


func _init() -> void:
	EventBus.game_ended.connect(_on_game_ended)


func _ready() -> void:
	for dungeon_state in states.get_children():
		dungeon_state.dungeon_state_manager = self

	dungeon_state_machine.set_state(wait)


func _physics_process(_delta: float) -> void:
	dungeon_state_machine.state.physics_update_branch()


func _process(_delta: float) -> void:
	if dungeon_state_machine.state.is_complete:
		choose_next_state()

	dungeon_state_machine.state.update_branch()


func choose_next_state() -> void:
	match dungeon_state_machine.state:
		start_game:
			dungeon_state_machine.set_state(collect_apples)
		collect_apples:
			_dungeon_next_state(collect_apples)
		clear_room:
			dungeon_state_machine.set_state(roam_free)
		roam_free:
			_dungeon_next_state(roam_free)
		enter_room:
			dungeon_state_machine.set_state(collect_apples)
		win:
			_dungeon_next_state(win)
		lose:
			_dungeon_next_state(lose)
		die:
			_dungeon_next_state(die)

func enter() -> void:
	dungeon_state_machine.set_state(start_game)


func set_current_screen_to_dungeon(new_screen: Dungeon) -> void:
	current_screen = new_screen
	current_screen.game_ui.menu_pressed.connect(_on_menu_pressed)


func set_dungeon_for_all_states(new_dungeon: Dungeon) -> void:
	for dungeon_state in states.get_children():
		dungeon_state.dungeon = new_dungeon
		dungeon_state._on_dungeon_state_set()


func _dungeon_next_state(dungeon_state: DungeonState) -> void:
	var next_dungeon_state: State = dungeon_state.next_state
	dungeon_state.next_state = null
	dungeon_state_machine.set_state(next_dungeon_state)


func _on_game_ended(won: bool) -> void:
	if won:
		dungeon_state_machine.set_state(win)
	else:
		dungeon_state_machine.set_state(lose)


func _on_menu_pressed() -> void:
	_select_mode(game_state_manager.game_state_menu)
