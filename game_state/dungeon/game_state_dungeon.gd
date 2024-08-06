extends GameState

var dungeon_state_machine:= StateMachine.new()
var current_screen: Node

@onready var start_game: DungeonState = $States/StartGame
@onready var collect_apples: DungeonState = $States/CollectApples
@onready var clear_room: DungeonState = $States/ClearRoom
@onready var roam_free: DungeonState = $States/RoamFree
@onready var enter_room: DungeonState = $States/EnterRoom
@onready var win: DungeonState = $States/Win
@onready var lose: DungeonState = $States/Lose


func _init() -> void:
	EventBus.game_ended.connect(_on_game_ended)


func _ready() -> void:
	for dungeon_state in states.get_children():
		dungeon_state.dungeon_state_manager = self


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
			dungeon_state_machine.set_state(clear_room)
		clear_room:
			dungeon_state_machine.set_state(roam_free)
		roam_free:
			dungeon_state_machine.set_state(enter_room)
		enter_room:
			dungeon_state_machine.set_state(collect_apples)


func enter() -> void:
	current_screen = _change_scene(Settings.DUNGEON_SCENE)


func _on_game_ended(won: bool) -> void:
	if won:
		current_screen = _change_scene(Settings.DUNGEON_WIN_SCREEN)
	else:
		current_screen = _change_scene(Settings.DUNGEON_DEATH_SCREEN)

	if not current_screen:
		return

	current_screen.play_again.pressed.connect(_on_play_again_pressed)
	current_screen.menu.pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	_select_mode(game_state_manager.game_state_menu)


func _on_play_again_pressed() -> void:
	current_screen = _change_scene(Settings.DUNGEON_SCENE)
