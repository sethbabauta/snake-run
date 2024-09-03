extends DungeonState

var turns_with_no_apples: int = 0


func _init() -> void:
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.player_died.connect(_on_player_died)


func _on_dungeon_state_set() -> void:
	dungeon.main_node.move_timer.speed_3.connect(_on_move_timer)


func _on_level_completed() -> void:
	_select_mode(dungeon_state_manager.clear_room)


func _on_move_timer() -> void:
	if not _is_correct_state():
		return

	var apples_in_room: Array[GameEngine.GameObject] = await (
		dungeon.main_node.get_game_objects_of_name("Apple")
	)

	if apples_in_room:
		turns_with_no_apples = 0
	else:
		turns_with_no_apples += 1

	if turns_with_no_apples >= 3:
		dungeon.main_node.queue_object_to_spawn("Apple")
		turns_with_no_apples = 0


func _on_player_died() -> void:
	if not _is_correct_state():
		return

	_select_mode(dungeon_state_manager.die)
