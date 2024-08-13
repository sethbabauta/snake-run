extends DungeonState


func enter() -> void:
	var new_dungeon: Dungeon = dungeon_state_manager._change_scene(
		Settings.DUNGEON_SCENE
	)
	dungeon_state_manager.current_screen = new_dungeon
	dungeon_state_manager.set_dungeon_for_all_states(new_dungeon)

	_setup_initial_room()
	dungeon.crown_poison_counter = Dungeon.CrownPoisonCounter.new(dungeon.main_node)
	dungeon.update_rooms("Start")

	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	dungeon.main_node.spawn_player_snake(start_position, dungeon.START_LENGTH)
	dungeon.main_node.queue_object_to_spawn(
		"DungeonExit",
		Utils.convert_simple_to_world_coordinates(Vector2(9, 6)),
	)
	dungeon.spawn_doors_and_apple()

	dungeon.main_node.play_scripted_event(dungeon.level_change_pause)
	await EventBus.announcement_completed

	EventBus.game_started.emit("Dungeon")

	is_complete = true


func _setup_initial_room() -> void:
	dungeon.current_room = dungeon.room_mapper.get_room_at_layout_coordinates(Vector2(0, 0))
	dungeon.current_room_neighbors = dungeon.room_mapper.get_room_neighbors(dungeon.current_room)
	dungeon.load_room(dungeon.current_room)
