extends DungeonState


func enter() -> void:
	dungeon_state_manager.current_screen = dungeon_state_manager._change_scene(
		Settings.DUNGEON_WIN_SCREEN
	)

	if not dungeon_state_manager.current_screen:
		return

	dungeon_state_manager.current_screen.play_again.pressed.connect(_on_play_again_pressed)
	dungeon_state_manager.current_screen.menu.pressed.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	dungeon_state_manager._on_menu_pressed()


func _on_play_again_pressed() -> void:
	_select_mode(dungeon_state_manager.start_game)
