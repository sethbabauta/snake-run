class_name Main extends Node

@export var follow_camera: Camera2D
@export var gamemode_node: Node

var game_object_factory: GameEngine.GameObjectFactory
var level_factory: LevelFactory
var max_simple_size: Vector2
var query_area: Area2D
var background_tile: PackedScene = load(Settings.GRASS_BACKGROUND_SCENE_PATH)


func _init() -> void:
	self.game_object_factory = GameEngine.GameObjectFactory.new()
	self.level_factory = LevelFactory.new(self)


func _ready() -> void:
	self.query_area = follow_camera.get_node("CollisionQuery")
	ScoreKeeper.set_score(gamemode_node.START_LENGTH)
	self.max_simple_size = (
			get_viewport().get_visible_rect().size / Settings.BASE_MOVE_SPEED
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("turn_up"):
		self._fire_change_direction_event("turn_up")

	if event.is_action_pressed("turn_left"):
		self._fire_change_direction_event("turn_left")

	if event.is_action_pressed("turn_down"):
		self._fire_change_direction_event("turn_down")

	if event.is_action_pressed("turn_right"):
		self._fire_change_direction_event("turn_right")

	if event.is_action_pressed("drop_item"):
		self._fire_drop_item_event()

	if event.is_action_pressed("use_item"):
		self._fire_use_item_event()


static func apply_shader_to_physics_body(
		target: GameEngine.GameObject,
		sprite_node_name: String,
		material_name: String,
) -> void:
	var shader_material_path: String = Settings.SHADERS_PATH + material_name
	var shader_material: Material = load(shader_material_path)
	var sprite_node: Sprite2D = target.physics_body.get_node(sprite_node_name)
	sprite_node.material = shader_material


static func apply_shader_to_snake(
		target_head: GameEngine.GameObject,
		material_name: String,
) -> void:
	Main.apply_shader_to_physics_body(target_head, "EquippedItem", material_name)

	var current_snakebody: Components.SnakeBody = target_head.components.get("SnakeBody")
	while current_snakebody != null:
		Main.apply_shader_to_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
				material_name,
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")


func clear_doors() -> void:
	var door_locations: Array = get_simple_door_locations()
	for door_location in door_locations:
		var door_world_location: Vector2 = (
				Utils.convert_simple_to_world_coordinates(door_location)
		)
		var door_game_object: GameEngine.GameObject = (
				get_game_object_at_position_or_null(door_world_location)
		)
		if not door_game_object:
			continue

		if door_game_object.name != "Door":
			continue

		door_game_object.delete_self()


func clear_pickup(pickup_name: String) -> void:
	var pickups: Array = get_game_objects_of_name(pickup_name)
	for pickup in pickups:
		pickup.delete_self()


func clear_pickups() -> void:
	var pickups_to_clear: Array = [
		"Apple",
		"PoisonApple",
	]

	for pickup_name in pickups_to_clear:
		clear_pickup(pickup_name)


func cooldown(
		ability_duration: float,
		cooldown_duration: float,
		ability_user: GameEngine.GameObject,
) -> void:
	await get_tree().create_timer(ability_duration).timeout
	var new_event:= GameEngine.Event.new("CooldownStart")
	ability_user.fire_event(new_event)

	await get_tree().create_timer(cooldown_duration).timeout
	new_event = GameEngine.Event.new("CooldownEnd")
	ability_user.fire_event(new_event)


func fire_delayed_event(
		target: GameEngine.GameObject,
		event: GameEngine.Event,
		delay_seconds: float,
) -> void:
	await get_tree().create_timer(delay_seconds).timeout
	target.fire_event(event)


func get_closest_player_controlled(
		position_to_compare: Vector2,
) -> GameEngine.GameObject:
	var player_positions: Array = (
			self.game_object_factory.subscribe_lists["player_controlled"]
	)
	var closest_object: GameEngine.GameObject
	var shortest_distance: float

	for current_game_object in player_positions:
		var current_distance: float = (
				current_game_object.physics_body.global_position
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


func get_game_object_at_position_or_null(position: Vector2) -> Variant:
	if not self.query_area.has_overlapping_areas():
		return null

	var found_game_object: GameEngine.GameObject
	for area in query_area.get_overlapping_areas():
		if area.global_position.is_equal_approx(position):
			found_game_object = area.game_object

	return found_game_object


func get_game_objects_of_name(name: String) -> Array:
	var game_objects: Array = []
	if not self.query_area.has_overlapping_areas():
		return game_objects

	for area in query_area.get_overlapping_areas():
		if area.game_object.name == name:
			game_objects.append(area.game_object)

	return game_objects


func get_random_valid_world_position() -> Vector2:
	var taken_positions: Array = get_taken_positions()

	var position:= Vector2.ONE

	for try_count in range(1000):
		position = self.get_random_world_position()
		if not is_position_taken(position):
			break

	return position


func get_random_world_position() -> Vector2:
	var rng:= RandomNumberGenerator.new()
	var position:= Vector2(
			rng.randi_range(0, self.max_simple_size.x-1),
			rng.randi_range(0, self.max_simple_size.y-1),
	)
	position = Utils.convert_simple_to_world_coordinates(position)

	return position


func get_simple_door_locations(exclusions: Array = []) -> Array:
	var camera_coordinates: Vector2 = follow_camera.global_position
	var simple_camera_coordinates: Vector2 = (
			Utils.convert_world_to_simple_coordinates(camera_coordinates)
	)
	var door_positions_north: Array = [
		simple_camera_coordinates + Vector2(0, -10),
		simple_camera_coordinates + Vector2(-1, -10),
	]
	var door_positions_south: Array = [
		simple_camera_coordinates + Vector2(0, 9),
		simple_camera_coordinates + Vector2(-1, 9),
	]
	var door_positions_east: Array = [
		simple_camera_coordinates + Vector2(9, 0),
		simple_camera_coordinates + Vector2(9, -1),
	]
	var door_positions_west: Array = [
		simple_camera_coordinates + Vector2(-10, 0),
		simple_camera_coordinates + Vector2(-10, -1),
	]

	var door_positions: Array = []
	if "N" not in exclusions:
		door_positions += door_positions_north
	if "S" not in exclusions:
		door_positions += door_positions_south
	if "E" not in exclusions:
		door_positions += door_positions_east
	if "W" not in exclusions:
		door_positions += door_positions_west

	return door_positions


func get_taken_positions() -> Array:
	var taken_positions: Array = []
	if self.query_area.has_overlapping_areas():
		for area in query_area.get_overlapping_areas():
			taken_positions.append(area.global_position)

	return taken_positions


func is_position_taken(position: Vector2) -> bool:
	var taken_positions: Array = get_taken_positions()
	var is_taken: bool = true
	if position not in taken_positions:
		is_taken = false

	return is_taken


static func overlay_sprite_on_game_object(
		sprite_path: String,
		target: GameEngine.GameObject,
		sprite_node_name: String,
		z_idx: int = 2,
) -> void:
	var new_sprite:= Sprite2D.new()
	new_sprite.texture = load(sprite_path)
	new_sprite.z_index = z_idx
	new_sprite.name = sprite_node_name
	target.physics_body.add_child(new_sprite)


static func remove_overlay_sprite_from_physics_body(
		target: GameEngine.GameObject,
		sprite_node_name: String,
) -> void:
	var sprite_node: Sprite2D = target.physics_body.get_node_or_null(sprite_node_name)
	if sprite_node:
		sprite_node.queue_free()


static func remove_shader_from_physics_body(
		target: GameEngine.GameObject,
		sprite_node_name: String,
) -> void:
	var sprite_node: Sprite2D = target.physics_body.get_node_or_null(sprite_node_name)
	if sprite_node:
		sprite_node.material = null


static func remove_shader_from_snake(
		target_head: GameEngine.GameObject,
) -> void:
	Main.remove_shader_from_physics_body(target_head, "EquippedItem")

	var current_snakebody: Components.SnakeBody = target_head.components.get("SnakeBody")
	while current_snakebody != null:
		Main.remove_shader_from_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")


func spawn_and_place_object(
		object_name: String,
		position: Vector2 = self.get_random_valid_world_position(),
) -> GameEngine.GameObject:
	var new_object:= self.game_object_factory.create_object(object_name, self)
	var set_position_event:= GameEngine.Event.new(
		"SetPosition",
		{"position": position}
	)
	new_object.fire_event(set_position_event)

	return new_object


func spawn_background() -> void:
	for x in range(self.max_simple_size.x):
		for y in range(self.max_simple_size.y):
			self._spawn_background_tile(Vector2(x, y))


func spawn_doors() -> void:
	var door_positions: Array = get_simple_door_locations()

	for position in door_positions:
		var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
		if not is_position_taken(world_position):
			spawn_and_place_object("Door", world_position)


func spawn_start_doors() -> void:
	var camera_coordinates: Vector2 = follow_camera.global_position
	var simple_camera_coordinates: Vector2 = (
			Utils.convert_world_to_simple_coordinates(camera_coordinates)
	)
	var door_positions_south: Array = [
		simple_camera_coordinates + Vector2(0, 9),
		simple_camera_coordinates + Vector2(-1, 9),
	]
	var door_positions: Array = get_simple_door_locations(["S"])

	for position in door_positions:
		var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
		if not is_position_taken(world_position):
			spawn_and_place_object("Door", world_position)

	for position in door_positions_south:
		var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
		if not is_position_taken(world_position):
			spawn_and_place_object("DungeonEntrance", world_position)


func spawn_snake_segment(
		head_game_object: GameEngine.GameObject,
		spawn_direction: Vector2 = Vector2.DOWN,
) -> void:

	var head_snake_body: Components.SnakeBody = (
			head_game_object.components.get("SnakeBody")
	)
	var tail: GameEngine.GameObject = head_snake_body.get_tail_game_object()

	var spawn_position: Vector2 = (
			tail.physics_body.global_position
			+ (spawn_direction * Settings.BASE_MOVE_SPEED)
	)
	var new_snake_body_obj: GameEngine.GameObject = (
			self.spawn_and_place_object("SnakeBody", spawn_position)
	)

	Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)


func spawn_player_snake(start_position: Vector2, snake_length: int) -> void:
	var snake_head:= self.spawn_and_place_object("PlayerSnakeHead", start_position)

	for snake_body_idx in range(snake_length-1):
		self.spawn_snake_segment(snake_head)


func _fire_change_direction_event(input_name: String) -> void:
	var new_event:= GameEngine.Event.new(
			"TryChangeDirection", {"input": input_name}
	)
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_drop_item_event() -> void:
	var new_event:= GameEngine.Event.new("DropItem")
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_use_item_event() -> void:
	var new_event:= GameEngine.Event.new("UseItem")
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _on_move_timer_speed_1() -> void:
	var new_event:= GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable1")


func _on_move_timer_speed_2() -> void:
	var new_event:= GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable2")


func _on_move_timer_speed_3() -> void:
	var new_event:= GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable3")


func _on_move_timer_speed_4() -> void:
	var new_event:= GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable4")


func _on_move_timer_speed_5() -> void:
	var new_event:= GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable5")


func _spawn_background_tile(position: Vector2) -> void:
	var world_position: Vector2 = (
			Utils.convert_simple_to_world_coordinates(position)
	)
	var current_tile: Sprite2D = self.background_tile.instantiate()
	self.add_child(current_tile)
	current_tile.global_position = world_position


func _spawn_barrier(position: Vector2) -> void:
	var world_position: Vector2 = (
			Utils.convert_simple_to_world_coordinates(position)
	)
	var barrier:= self.game_object_factory.create_object("Barrier", self)
	var set_position_event:= GameEngine.Event.new(
		"SetPosition",
		{"position": world_position}
	)
	barrier.fire_event(set_position_event)


func spawn_start_barriers() -> void:
	self._spawn_barrier(Vector2(0, 0))
	self._spawn_barrier(Vector2(self.max_simple_size.x-1, 0))
	self._spawn_barrier(Vector2(0, self.max_simple_size.y-1))
	self._spawn_barrier(
			Vector2(self.max_simple_size.x-1, self.max_simple_size.y-1)
	)

	for coordinate in range(1, self.max_simple_size.x-1):
		self._spawn_barrier(Vector2(coordinate, 0))
		self._spawn_barrier(Vector2(coordinate, self.max_simple_size.y-1))
		self._spawn_barrier(Vector2(0, coordinate))
		self._spawn_barrier(Vector2(self.max_simple_size.x-1, coordinate))
