extends GameState

@export var dev_high_score: int = 0

var classic_state_machine:= StateMachine.new()


func _init() -> void:
	EventBus.game_ended.connect(_on_game_ended)


func enter() -> void:
	var classic_node: Classic = _change_scene(Settings.CLASSIC_SCENE)
	classic_node.game_ui.menu_pressed.connect(_on_menu_pressed)


func _on_game_ended(won: bool) -> void:
	if won:
		return

	var death_screen: DeathScreen = _change_scene(Settings.DEATH_SCREEN)

	if not death_screen:
		return

	death_screen.play_again.pressed.connect(_on_play_again_pressed)
	death_screen.menu.pressed.connect(_on_menu_pressed)
	death_screen.set_dev_high_score(dev_high_score)


func _on_menu_pressed() -> void:
	_select_mode(game_state_manager.game_state_menu)


func _on_play_again_pressed() -> void:
	_change_scene(Settings.CLASSIC_SCENE)
