class_name ObjectSpawner extends RefCounted

var main_node: Main
var background_tile: PackedScene = load(Settings.GRASS_BACKGROUND_SCENE_PATH)
var spawn_queue: Array[SpawnJob] = []


func _init(p_main_node: Main) -> void:
	main_node = p_main_node


func queue_object_to_spawn(
	object_name: String,
	position: Vector2 = await main_node.get_random_valid_world_position(),
	force_preferred_position: bool = false,
) -> GameEngine.GameObject:
	var new_object := main_node.game_object_factory.create_object(
		object_name,
		main_node,
	)
	var new_spawn_job := SpawnJob.new(new_object, position, force_preferred_position)
	spawn_queue.append(new_spawn_job)

	return new_object


func spawn_background(offset:= Vector2(0, 0)) -> void:
	for x in range(main_node.max_simple_size.x):
		for y in range(main_node.max_simple_size.y):
			_spawn_background_tile(Vector2(x, y) + offset)


func spawn_barrier(position: Vector2) -> void:
	var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
	var barrier := main_node.game_object_factory.create_object(
		"Barrier",
		main_node,
	)
	var set_position_event := GameEngine.Event.new(
		"SetPosition",
		{"position": world_position},
	)
	barrier.fire_event(set_position_event)


func spawn_doors(exclusions: Array[String] = []) -> void:
	var door_positions: Array = main_node.get_simple_door_locations(exclusions)

	for position in door_positions:
		var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
		if not await main_node.is_position_taken(world_position):
			queue_object_to_spawn("Door", world_position, true)


func spawn_object_instantly(
	object_name: String,
	position: Vector2 = await main_node.get_random_valid_world_position(),
) -> GameEngine.GameObject:
	var new_object := main_node.game_object_factory.create_object(
		object_name,
		main_node,
	)
	var set_position_event := GameEngine.Event.new("SetPosition", {"position": position})
	new_object.fire_event(set_position_event)

	return new_object


func spawn_player_snake(start_position: Vector2, snake_length: int, slow: bool = false) -> void:
	var spawn_position: Vector2 = start_position
	var snake_type: String = "PlayerSnakeHead"

	if slow:
		snake_type = "PlayerSnakeHeadSlow"
	var snake_head := await queue_object_to_spawn(snake_type, spawn_position)

	for snake_body_idx in range(snake_length - 1):
		spawn_position = spawn_position + (Vector2.DOWN * Settings.BASE_MOVE_SPEED)
		spawn_snake_segment(snake_head, spawn_position)


func spawn_snake_segment(
	head_game_object: GameEngine.GameObject,
	spawn_position: Vector2,
) -> void:
	var head_snake_body: Components.SnakeBody = (
		head_game_object.components.get("SnakeBody")
	)
	var tail: GameEngine.GameObject = head_snake_body.get_tail_game_object()

	var new_snake_body_obj: GameEngine.GameObject = await queue_object_to_spawn(
		"SnakeBody", spawn_position, true
	)

	Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)


func spawn_start_barriers() -> void:
	spawn_barrier(Vector2(0, 0))
	spawn_barrier(Vector2(main_node.max_simple_size.x - 1, 0))
	spawn_barrier(Vector2(0, main_node.max_simple_size.y - 1))
	spawn_barrier(Vector2(
		main_node.max_simple_size.x - 1,
		main_node.max_simple_size.y - 1,
	))

	for coordinate in range(1, main_node.max_simple_size.x - 1):
		spawn_barrier(Vector2(coordinate, 0))
		spawn_barrier(Vector2(coordinate, main_node.max_simple_size.y - 1))
		spawn_barrier(Vector2(0, coordinate))
		spawn_barrier(Vector2(main_node.max_simple_size.x - 1, coordinate))


func _spawn_background_tile(position: Vector2) -> void:
	var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
	var current_tile: Sprite2D = background_tile.instantiate()
	current_tile.name = "background_tile-" + str(Utils.rng.randi_range(1, 10000))
	main_node.add_child(current_tile)
	current_tile.global_position = world_position


func _spawn_object_from_queue() -> void:
	if not spawn_queue:
		return

	var current_spawn_job: SpawnJob = spawn_queue.pop_front()
	var position: Vector2 = current_spawn_job.preferred_position
	var object_to_spawn: GameEngine.GameObject = current_spawn_job.object_to_spawn
	if (
		await main_node.is_position_taken(position)
		and not current_spawn_job.force_preferred_position
	):
		position = await main_node.get_random_valid_world_position()

	if (
		await main_node.is_position_taken(position)
		and not current_spawn_job.force_preferred_position
	):
		var warning: String = (
			"Attempted to spawn "
			+ object_to_spawn._to_string()
			+ " at position "
			+ str(position)
		)
		push_warning(warning)

		if current_spawn_job.can_retry():
			current_spawn_job.try_requeue_job(spawn_queue)

		return

	var set_position_event := GameEngine.Event.new("SetPosition", {"position": position})
	object_to_spawn.fire_event(set_position_event)
