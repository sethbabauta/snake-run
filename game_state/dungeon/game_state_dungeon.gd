extends GameState


func enter() -> void:
	game_state_manager.scene_change_requested.emit(Settings.DUNGEON_SCENE)
