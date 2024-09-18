extends GameState

var settings_scene: SettingsDialog


func _unhandled_input(event: InputEvent) -> void:
	if game_state_manager.state_machine.state != self:
		return

	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_select_mode(game_state_manager.game_state_menu)


func enter() -> void:
	settings_scene = _change_scene(Settings.SETTINGS_SCENE)
	settings_scene.back_pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	_select_mode(game_state_manager.game_state_menu)
