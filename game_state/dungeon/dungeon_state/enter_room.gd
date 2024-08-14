extends DungeonState


func enter() -> void:
	dungeon.spawn_doors_and_apple()
	is_complete = true
