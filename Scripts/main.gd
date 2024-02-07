class_name Main extends Node

@export var query_area: Area2D
@export var gamemode_node: Node

var game_object_factory: GameEngine.GameObjectFactory
var max_simple_size: Vector2


func _init() -> void:
	self.game_object_factory = GameEngine.GameObjectFactory.new()


func _ready() -> void:
	ScoreKeeper.set_score(gamemode_node.START_LENGTH)
	self.max_simple_size = (
			get_viewport().get_visible_rect().size / Settings.BASE_MOVE_SPEED
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("turn_up"):
		_fire_change_direction_event("turn_up")

	if event.is_action_pressed("turn_left"):
		_fire_change_direction_event("turn_left")

	if event.is_action_pressed("turn_down"):
		_fire_change_direction_event("turn_down")

	if event.is_action_pressed("turn_right"):
		_fire_change_direction_event("turn_right")


func _on_timer_timeout() -> void:
	var new_event:= GameEngine.Event.new("MoveForward")
	self.game_object_factory.notify_subscribers(new_event, "movable")


func spawn_apple() -> void:
	var apple:= self.game_object_factory.create_object("Apple", self)
	var set_position_event:= GameEngine.Event.new(
		"SetPosition",
		{"position": self.get_random_valid_world_position()}
	)
	apple.fire_event(set_position_event)


func spawn_poison_apple() -> GameEngine.GameObject:
	var poison_apple:= self.game_object_factory.create_object("PoisonApple", self)
	var set_position_event:= GameEngine.Event.new(
		"SetPosition",
		{"position": self.get_random_valid_world_position()}
	)
	poison_apple.fire_event(set_position_event)

	return poison_apple


func spawn_player_body(
		player_game_object: GameEngine.GameObject,
		spawn_direction: Vector2 = Vector2.DOWN,
) -> void:

	var player_snake_body: Components.SnakeBody = (
			player_game_object.components.get("SnakeBody")
	)
	var new_snake_body_obj:= self.game_object_factory.create_object("SnakeBody", self)
	var tail: GameEngine.GameObject = player_snake_body.get_tail_game_object()

	Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)

	var set_position_event:= GameEngine.Event.new(
			"SetPosition",
			{"position": (
					tail.physics_body.global_position
					+ (spawn_direction * Settings.BASE_MOVE_SPEED)
			)},
	)
	new_snake_body_obj.fire_event(set_position_event)


func spawn_player_snake(start_position: Vector2, snake_length: int) -> void:
	var snake_head:= self.game_object_factory.create_object("PlayerSnakeHead", self)
	var set_position_event:= GameEngine.Event.new(
		"SetPosition",
		{"position": start_position}
	)
	snake_head.fire_event(set_position_event)

	for snake_body_idx in range(snake_length-1):
		self.spawn_player_body(snake_head)


func get_closest_player_controlled(
		object_to_compare: GameEngine.GameObject,
) -> GameEngine.GameObject:
	var player_positions: Array = (
			object_to_compare.factory_from.subscribe_lists["player_controlled"]
	)
	var position_to_compare: Vector2 = object_to_compare.physics_body.global_position
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


func get_random_valid_world_position() -> Vector2:
	var taken_positions: Array = []

	if self.query_area.has_overlapping_areas():
		for area in query_area.get_overlapping_areas():
			taken_positions.append(area.global_position)

	var position:= Vector2.ONE

	for try_count in range(1000):
		position = self.get_random_world_position()
		if position not in taken_positions:
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


func _fire_change_direction_event(input_name: String) -> void:
	var new_event:= GameEngine.Event.new(
			"TryChangeDirection", {"input": input_name}
	)
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


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


func _spawn_start_barriers() -> void:
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
