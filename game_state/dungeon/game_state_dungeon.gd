class_name GameStateDungeon extends GameState


func enter() -> void:
	game_state_manager.get_tree().change_scene_to_file(Settings.DUNGEON_SCENE)
