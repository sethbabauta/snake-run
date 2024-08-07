extends DungeonState


func _init() -> void:
	EventBus.level_changed.connect(_on_level_changed)


func _on_level_changed(direction: String) -> void:
	if dungeon_state_manager.dungeon_state_machine.state != self:
		return

	dungeon.update_rooms(direction)

	if not dungeon.current_room.get_is_room_complete():
		is_complete = true
