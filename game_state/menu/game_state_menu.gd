extends GameState


func enter() -> void:
	var menu: Control = _change_scene(Settings.MENU_SCENE)

	if not menu:
		return

	menu.start_classic.pressed.connect(_on_classic_pressed)
	menu.start_snake_o_mode.pressed.connect(_on_snakeo_pressed)
	menu.start_dungeon.pressed.connect(_on_dungeon_pressed)
	menu.settings_button.pressed.connect(_on_settings_pressed)


func _on_classic_pressed() -> void:
	_select_mode(game_state_manager.game_state_classic)


func _on_dungeon_pressed() -> void:
	_select_mode(game_state_manager.game_state_dungeon)


func _on_settings_pressed() -> void:
	_select_mode(game_state_manager.game_state_settings)


func _on_snakeo_pressed() -> void:
	_select_mode(game_state_manager.game_state_snakeo)
