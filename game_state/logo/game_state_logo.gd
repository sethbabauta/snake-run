extends GameState


func enter() -> void:
	game_state_manager.scene_change_requested.emit(Settings.LOGO_SCENE)


func update() -> void:
	if get_runtime() > 3.0:
		is_complete = true
