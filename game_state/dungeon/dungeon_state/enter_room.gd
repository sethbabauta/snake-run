extends DungeonState


func enter() -> void:
	var exclusions: Array[String] = dungeon.get_current_room_exclusions()
	dungeon.main_node.spawn_doors(exclusions)
	await get_tree().create_timer(1).timeout
	dungeon.main_node.queue_object_to_spawn("Apple")

	is_complete = true
