extends DungeonState

var turns_with_no_apples: int = 0

func _init() -> void:
	EventBus.level_completed.connect(_on_level_completed)


func enter() -> void:
	dungeon.main_node.move_timer.speed_3.connect(_on_move_timer)


func _on_level_completed() -> void:
	is_complete = true


func _on_move_timer() -> void:
	if dungeon_state_manager.dungeon_state_machine.state != self:
		return

	var apples_in_room: Array[GameEngine.GameObject] = await (
		dungeon.main_node.get_game_objects_of_name("Apple")
	)

	if not apples_in_room:
		turns_with_no_apples += 1

	if turns_with_no_apples >= 3:
		dungeon.main_node.queue_object_to_spawn("Apple")
		turns_with_no_apples = 0
