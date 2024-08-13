extends DungeonState


func enter() -> void:
	var exclusions: Array[String] = dungeon.get_current_room_exclusions()
	dungeon.main_node.clear_doors(exclusions)

	await EventBus.player_moved

	var pickups_cleared: int = 0
	var clear_pickup_tries: int = 0
	while pickups_cleared == 0 and clear_pickup_tries < 10:
		pickups_cleared += await dungeon.main_node.clear_pickups()
		clear_pickup_tries += 1

	await dungeon.main_node.play_scripted_event(_level_cleared_event)
	await dungeon.game_announcer.announce_arrows(exclusions)

	is_complete = true


func _level_cleared_event(_args: Dictionary) -> void:
	dungeon.game_announcer.announce_message("ROOM CLEARED")
	await get_tree().create_timer(1).timeout
	EventBus.scripted_event_completed.emit()
