class_name WorldInfo extends RefCounted

var game_object_factory: GameEngine.GameObjectFactory
var main_node: Main


func _init(
	p_game_object_factory: GameEngine.GameObjectFactory,
	p_main_node: Main
) -> void:
	game_object_factory = p_game_object_factory
	main_node = p_main_node


func check_is_player_alive() -> bool:
	var player_positions: Array = game_object_factory.subscribe_lists[
		"player_controlled"
	]
	var is_player_alive: bool = false
	if player_positions.size() > 0:
		is_player_alive = true

	return is_player_alive


func get_closest_player_controlled(
	position_to_compare: Vector2,
) -> GameEngine.GameObject:
	var player_positions: Array = game_object_factory.subscribe_lists[
		"player_controlled"
	]
	var closest_object: GameEngine.GameObject
	var shortest_distance: float

	for current_game_object in player_positions:
		var current_distance: float = (
			current_game_object
			.physics_body
			.global_position
			.distance_to(position_to_compare)
		)

		if not shortest_distance:
			shortest_distance = current_distance
			closest_object = current_game_object
			continue

		if shortest_distance > current_distance:
			shortest_distance = current_distance
			closest_object = current_game_object

	return closest_object


func get_game_objects_of_name(
	search_name: String,
) -> Array[GameEngine.GameObject]:
	var visible_game_objects: Array[GameEngine.GameObject] = (
		await _get_visible_game_objects()
	)
	var found_game_objects: Array[GameEngine.GameObject] = []
	if not visible_game_objects:
		return found_game_objects

	for object in visible_game_objects:
		if object.name == search_name:
			found_game_objects.append(object)

	return found_game_objects


func get_is_object_visible(object: GameEngine.GameObject) -> bool:
	var visible_objects: Array = await _get_visible_game_objects()
	var is_visible: bool = false

	if object in visible_objects:
		is_visible = true

	return is_visible


func get_random_valid_world_position() -> Vector2:
	var position := Vector2.ONE

	for try_count in range(1000):
		position = _get_random_world_position()
		if not await is_position_taken(position):
			break

	return position


func get_simple_door_locations(
	exclusions: Array[String] = []
) -> Array[Vector2]:
	var camera_coordinates: Vector2 = main_node.follow_camera.global_position
	var simple_camera_coordinates: Vector2 = (
		Utils.convert_world_to_simple_coordinates(camera_coordinates)
	)
	var door_positions_north: Array[Vector2] = [
		simple_camera_coordinates + Vector2(0, -10),
		simple_camera_coordinates + Vector2(-1, -10),
	]
	var door_positions_south: Array[Vector2] = [
		simple_camera_coordinates + Vector2(0, 9),
		simple_camera_coordinates + Vector2(-1, 9),
	]
	var door_positions_east: Array[Vector2] = [
		simple_camera_coordinates + Vector2(9, 0),
		simple_camera_coordinates + Vector2(9, -1),
	]
	var door_positions_west: Array[Vector2] = [
		simple_camera_coordinates + Vector2(-10, 0),
		simple_camera_coordinates + Vector2(-10, -1),
	]

	var door_positions: Array[Vector2] = []
	if "N" not in exclusions:
		door_positions += door_positions_north
	if "S" not in exclusions:
		door_positions += door_positions_south
	if "E" not in exclusions:
		door_positions += door_positions_east
	if "W" not in exclusions:
		door_positions += door_positions_west

	return door_positions


func get_snake_length() -> int:
	var snake_length: int = 0

	if not main_node.get_tree():
		return snake_length

	await main_node.get_tree().create_timer(0.05).timeout
	var snake_heads: Array[GameEngine.GameObject] = (
		await get_game_objects_of_name("PlayerSnakeHead")
	)

	if snake_heads:
		var snake_component: Components.SnakeBody = (
			snake_heads[0].components.get("SnakeBody")
		)
		snake_length = snake_component.get_length_from_here()

	return snake_length


func is_position_taken(position: Vector2, debug: bool = false, debug_from: String = "") -> bool:
	var taken_positions: Array = await _get_taken_positions()
	var is_taken: bool = true

	if position not in taken_positions:
		is_taken = false

	if debug:
		print(
			"debug from: ",
			debug_from,
			", searched position: ",
			position,
			", is taken: ",
			is_taken,
			", taken positions: ",
			taken_positions,
		)

	return is_taken


func _get_random_world_position() -> Vector2:
	var rng := RandomNumberGenerator.new()
	var position := Vector2(
		rng.randf_range(0, main_node.max_simple_size.x - 1.0),
		rng.randf_range(0, main_node.max_simple_size.y - 1.0),
	)
	var camera_offset: Vector2 = (
		Utils.convert_world_to_simple_coordinates(
			main_node.follow_camera.global_position
		) - Vector2(10, 10)
	)
	position += camera_offset
	position = Utils.convert_simple_to_world_coordinates(position)

	return position


func _get_taken_positions() -> Array:
	var taken_positions: Array = []
	await main_node.get_tree().physics_frame
	if main_node.query_area.has_overlapping_areas():
		for area in main_node.query_area.get_overlapping_areas():
			taken_positions.append(area.global_position)

	return taken_positions


func _get_visible_game_objects() -> Array[GameEngine.GameObject]:
	var game_objects: Array[GameEngine.GameObject] = []

	if not main_node.get_tree():
		return game_objects

	await main_node.get_tree().physics_frame

	if not main_node.query_area.has_overlapping_areas():
		return game_objects

	for area in main_node.query_area.get_overlapping_areas():
		game_objects.append(area.game_object)

	return game_objects
