extends DungeonState


func enter() -> void:
	var exclusions: Array[String] = dungeon.get_current_room_exclusions()
	dungeon.main_node.clear_doors(exclusions)

	await EventBus.player_moved

	dungeon.main_node.toggle_timer_freeze()

	await dungeon.clear_pickups()

	if (
		dungeon.current_room.get_is_room_complete()
		and not dungeon.current_room.cleared_message_played
	):
		await dungeon.main_node.play_scripted_event(_level_cleared_event)
		await dungeon.game_announcer.announce_arrows(exclusions)
		dungeon.current_room.cleared_message_played = true

	dungeon.main_node.toggle_timer_freeze()

	is_complete = true


func _level_cleared_event(_args: Dictionary) -> void:
	var cleared_message: String = LevelClearedMessagesDb.get_random_message()
	dungeon.game_announcer.announce_message(cleared_message)
	await get_tree().create_timer(1).timeout
	EventBus.scripted_event_completed.emit()
