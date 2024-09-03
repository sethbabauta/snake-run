extends DungeonState


func _init() -> void:
	EventBus.level_changed.connect(_on_level_changed)
	EventBus.player_died.connect(_on_player_died)


func _on_level_changed(direction: String) -> void:
	if not _is_correct_state():
		return

	dungeon.update_rooms(direction)

	if not dungeon.current_room.get_is_room_complete():
		_select_mode(dungeon_state_manager.enter_room)


func _on_player_died() -> void:
	if not _is_correct_state():
		return

	_select_mode(dungeon_state_manager.die)
