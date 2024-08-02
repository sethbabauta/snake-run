extends GameState


func _init() -> void:
	EventBus.game_ended.connect(_on_game_ended)


func enter() -> void:
	_change_scene(Settings.DUNGEON_SCENE)


func _on_game_ended(won: bool) -> void:
	if not won:
		_change_scene(Settings.DUNGEON_DEATH_SCREEN)
