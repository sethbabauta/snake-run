extends GameState

var dungeon_state_machine:= StateMachine.new()


func _init() -> void:
	EventBus.game_ended.connect(_on_game_ended)


func enter() -> void:
	_change_scene(Settings.DUNGEON_SCENE)


func _on_game_ended(won: bool) -> void:
	var game_over_screen: Control
	if won:
		game_over_screen = _change_scene(Settings.DUNGEON_WIN_SCREEN)
	else:
		game_over_screen = _change_scene(Settings.DUNGEON_DEATH_SCREEN)

	if not game_over_screen:
		return

	game_over_screen.play_again.pressed.connect(_on_play_again_pressed)
	game_over_screen.menu.pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	_select_mode(game_state_manager.game_state_menu)


func _on_play_again_pressed() -> void:
	_change_scene(Settings.DUNGEON_SCENE)
