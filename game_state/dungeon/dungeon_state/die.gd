extends DungeonState


func enter() -> void:
	var exclusions: Array[String] = dungeon.get_current_room_exclusions()
	dungeon.main_node.clear_doors(exclusions)

	dungeon.main_node.toggle_timer_freeze(false)

	await dungeon.clear_pickups()
	dungeon.set_current_room_to_start()

	if dungeon.current_room.get_is_room_complete():
		_select_mode(dungeon_state_manager.roam_free)
	else:
		_select_mode(dungeon_state_manager.enter_room)
