class_name Main extends Node

@onready var move_timer: MoveTimer = %MoveTimer

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
	self.max_simple_size = (get_viewport().get_visible_rect().size / Settings.BASE_MOVE_SPEED)


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

	if event.is_action_pressed("pause"):
		pause_or_play()


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
		(
			Main
			. apply_shader_to_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
				material_name,
			)
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")


func clear_doors() -> void:
	var door_locations: Array = get_simple_door_locations()
	for door_location in door_locations:
		var door_world_location: Vector2 = Utils.convert_simple_to_world_coordinates(door_location)
		var door_game_object: GameEngine.GameObject = get_game_object_at_position_or_null(
			door_world_location
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
	var new_event := GameEngine.Event.new("CooldownStart")
	ability_user.fire_event(new_event)

	await get_tree().create_timer(cooldown_duration).timeout
	new_event = GameEngine.Event.new("CooldownEnd")
	ability_user.fire_event(new_event)


func delete_and_replace(
	object_to_delete: GameEngine.GameObject,
	name_of_replacement: String,
) -> void:
	var object_position: Vector2 = object_to_delete.physics_body.global_position
	object_to_delete.delete_self()
	spawn_and_place_object(name_of_replacement, object_position)


func fire_delayed_event(
	target: GameEngine.GameObject,
	event: GameEngine.Event,
	delay_seconds: float,
) -> void:
	await get_tree().create_timer(delay_seconds).timeout
	target.fire_event(event)


func flip_apples() -> void:
	var nutritious_apples: Array = get_game_objects_of_name("Apple")
	var slightly_poisonous_apples: Array = get_game_objects_of_name("SlightlyPoisonousApple")

	for nutritious_apple in nutritious_apples:
		delete_and_replace(nutritious_apple, "SlightlyPoisonousAppleNoRespawn")

	for slightly_poisonous_apple in slightly_poisonous_apples:
		delete_and_replace(slightly_poisonous_apple, "AppleNoRespawn")


func flip_apples_back() -> void:
	var nutritious_apples: Array = get_game_objects_of_name("AppleNoRespawn")
	var slightly_poisonous_apples: Array = get_game_objects_of_name(
		"SlightlyPoisonousAppleNoRespawn"
	)

	for nutritious_apple in nutritious_apples:
		delete_and_replace(nutritious_apple, "SlightlyPoisonousApple")

	if not slightly_poisonous_apples:
		spawn_and_place_object("Apple")
		return

	for slightly_poisonous_apple in slightly_poisonous_apples:
		delete_and_replace(slightly_poisonous_apple, "Apple")


func flip_apples_temporary(flip_seconds: int) -> void:
	EventBus.powerup_1_activated.emit(flip_seconds)


func get_closest_player_controlled(
	position_to_compare: Vector2,
) -> GameEngine.GameObject:
	var player_positions: Array = self.game_object_factory.subscribe_lists["player_controlled"]
	var closest_object: GameEngine.GameObject
	var shortest_distance: float

	for current_game_object in player_positions:
		var current_distance: float = current_game_object.physics_body.global_position.distance_to(
			position_to_compare
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


func get_game_objects_of_name(search_name: String) -> Array:
	var visible_game_objects: Array = get_visible_game_objects()
	var found_game_objects: Array = []
	if not visible_game_objects:
		return found_game_objects

	for object in visible_game_objects:
		if object.name == search_name:
			found_game_objects.append(object)

	return found_game_objects


func get_random_valid_world_position() -> Vector2:
	var position := Vector2.ONE

	for try_count in range(1000):
		position = self.get_random_world_position()
		if not is_position_taken(position):
			break

	return position


func get_random_world_position() -> Vector2:
	var rng := RandomNumberGenerator.new()
	var position := Vector2(
		rng.randi_range(0, self.max_simple_size.x - 1.0),
		rng.randi_range(0, self.max_simple_size.y - 1.0),
	)
	var camera_offset: Vector2 = (
		Utils.convert_world_to_simple_coordinates(self.follow_camera.global_position)
		- Vector2(10, 10)
	)
	position += camera_offset
	position = Utils.convert_simple_to_world_coordinates(position)

	return position


func get_simple_door_locations(exclusions: Array = []) -> Array:
	var camera_coordinates: Vector2 = follow_camera.global_position
	var simple_camera_coordinates: Vector2 = Utils.convert_world_to_simple_coordinates(
		camera_coordinates
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


func get_snake_length() -> int:
	if not get_tree():
		return 0
	await get_tree().create_timer(0.05).timeout
	var snake_head: GameEngine.GameObject = get_game_objects_of_name("PlayerSnakeHead")[0]
	var snake_component: Components.SnakeBody = snake_head.components.get("SnakeBody")
	var snake_length: int = snake_component.get_length_from_here()

	return snake_length


func get_taken_positions() -> Array:
	var taken_positions: Array = []
	if self.query_area.has_overlapping_areas():
		for area in query_area.get_overlapping_areas():
			taken_positions.append(area.global_position)

	return taken_positions


func get_visible_game_objects() -> Array:
	var game_objects: Array = []
	if not self.query_area.has_overlapping_areas():
		return game_objects

	for area in query_area.get_overlapping_areas():
		game_objects.append(area.game_object)

	return game_objects


func is_object_visible(object: GameEngine.GameObject) -> bool:
	var visible_objects: Array = get_visible_game_objects()
	var is_visible: bool = false

	if object in visible_objects:
		is_visible = true

	return is_visible


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
	z_idx: int = 1,
	offset := Vector2(0, 0)
) -> void:
	var new_sprite := Sprite2D.new()
	new_sprite.texture = load(sprite_path)
	new_sprite.z_index = z_idx
	new_sprite.name = sprite_node_name
	target.physics_body.add_child(new_sprite)
	new_sprite.position += offset


func pause_or_play() -> void:
	move_timer.paused = not move_timer.paused
	EventBus.game_paused.emit(move_timer.paused)


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
		(
			Main
			. remove_shader_from_physics_body(
				current_snakebody.game_object,
				"PhysicsObjectSprite",
			)
		)
		var prev_body: GameEngine.GameObject = current_snakebody.prev_body
		if not prev_body:
			break
		current_snakebody = prev_body.components.get("SnakeBody")


func spawn_and_place_object(
	object_name: String,
	position: Vector2 = self.get_random_valid_world_position(),
) -> GameEngine.GameObject:
	var new_object := self.game_object_factory.create_object(object_name, self)
	var set_position_event := GameEngine.Event.new("SetPosition", {"position": position})
	new_object.fire_event(set_position_event)

	return new_object


func spawn_background(offset: Vector2 = Vector2(0, 0)) -> void:
	for x in range(self.max_simple_size.x):
		for y in range(self.max_simple_size.y):
			self._spawn_background_tile(Vector2(x, y) + offset)


func spawn_doors() -> void:
	var door_positions: Array = get_simple_door_locations()

	for position in door_positions:
		var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
		if not is_position_taken(world_position):
			spawn_and_place_object("Door", world_position)


func spawn_start_doors() -> void:
	var camera_coordinates: Vector2 = follow_camera.global_position
	var simple_camera_coordinates: Vector2 = Utils.convert_world_to_simple_coordinates(
		camera_coordinates
	)
	var door_positions_south: Array = [
		simple_camera_coordinates + Vector2(0, 9),
		simple_camera_coordinates + Vector2(-1, 9),
	]
	var door_positions: Array = get_simple_door_locations(["S", "E"])

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
	var head_snake_body: Components.SnakeBody = head_game_object.components.get("SnakeBody")
	var tail: GameEngine.GameObject = head_snake_body.get_tail_game_object()

	var spawn_position: Vector2 = (
		tail.physics_body.global_position + (spawn_direction * Settings.BASE_MOVE_SPEED)
	)
	var new_snake_body_obj: GameEngine.GameObject = self.spawn_and_place_object(
		"SnakeBody", spawn_position
	)

	Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)


func spawn_player_snake(start_position: Vector2, snake_length: int, slow: bool = false) -> void:
	var snake_type: String = "PlayerSnakeHead"
	if slow:
		snake_type = "PlayerSnakeHeadSlow"
	var snake_head := self.spawn_and_place_object(snake_type, start_position)

	for snake_body_idx in range(snake_length - 1):
		self.spawn_snake_segment(snake_head)


func _fire_change_direction_event(input_name: String) -> void:
	var new_event := GameEngine.Event.new("TryChangeDirection", {"input": input_name})
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_drop_item_event() -> void:
	var new_event := GameEngine.Event.new("DropItem")
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _fire_use_item_event() -> void:
	var new_event := GameEngine.Event.new("UseItem")
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _on_move_timer_speed_1() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable1")


func _on_move_timer_speed_2() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable2")


func _on_move_timer_speed_3() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable3")


func _on_move_timer_speed_4() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable4")


func _on_move_timer_speed_5() -> void:
	var new_event := GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable5")


func _spawn_background_tile(position: Vector2) -> void:
	var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
	var current_tile: Sprite2D = self.background_tile.instantiate()
	self.add_child(current_tile)
	current_tile.global_position = world_position


func _spawn_barrier(position: Vector2) -> void:
	var world_position: Vector2 = Utils.convert_simple_to_world_coordinates(position)
	var barrier := self.game_object_factory.create_object("Barrier", self)
	var set_position_event := GameEngine.Event.new("SetPosition", {"position": world_position})
	barrier.fire_event(set_position_event)


func spawn_start_barriers() -> void:
	self._spawn_barrier(Vector2(0, 0))
	self._spawn_barrier(Vector2(self.max_simple_size.x - 1, 0))
	self._spawn_barrier(Vector2(0, self.max_simple_size.y - 1))
	self._spawn_barrier(Vector2(self.max_simple_size.x - 1, self.max_simple_size.y - 1))

	for coordinate in range(1, self.max_simple_size.x - 1):
		self._spawn_barrier(Vector2(coordinate, 0))
		self._spawn_barrier(Vector2(coordinate, self.max_simple_size.y - 1))
		self._spawn_barrier(Vector2(0, coordinate))
		self._spawn_barrier(Vector2(self.max_simple_size.x - 1, coordinate))
