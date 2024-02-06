class_name Main extends Node

@export var query_area: Area2D
@export var gamemode_node: Node

const BLUEPRINTS_PATH = "res://blueprints.txt"
const SCENES_PATH = "res://Scenes/"
const SPRITES_PATH = "res://Sprites/"
const PHYSICS_OBJECT_PATH = "res://Scenes/physics_object.tscn"
const TICK_THRESHOLD = 10
const BASE_MOVE_SPEED = 32

var game_object_factory: GameEngine.GameObjectFactory
var max_simple_size: Vector2


func _init() -> void:
	self.game_object_factory = GameEngine.GameObjectFactory.new()


func _ready() -> void:
	ScoreKeeper.set_score(gamemode_node.START_LENGTH)
	self.max_simple_size = get_viewport().get_visible_rect().size / BASE_MOVE_SPEED


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


func convert_simple_to_world_coordinates(coordinates: Vector2) -> Vector2:
	var new_coordinates:= (
			(coordinates.round() * self.BASE_MOVE_SPEED)
			+ (Vector2.ONE * (self.BASE_MOVE_SPEED / 2))
	)
	return new_coordinates


func convert_world_to_simple_coordinates(coordinates: Vector2) -> Vector2:
	var new_coordinates:= (
			(coordinates.round() - (Vector2.ONE * (self.BASE_MOVE_SPEED / 2)))
			.snapped(Vector2.ONE * self.BASE_MOVE_SPEED) / self.BASE_MOVE_SPEED
	)
	return new_coordinates


func spawn_apple() -> void:
	#var rng:= RandomNumberGenerator.new()
	#var roll: int = rng.randi_range(1, 20)
	#if self.score > 5 and roll > 15:
		#var poison_apple:= self.game_object_factory.create_object("PoisonApple", self)
		#var set_position_event:= GameEngine.Event.new(
			#"SetPosition",
			#{"position": self.get_random_valid_world_position()}
		#)
		#poison_apple.fire_event(set_position_event)

	var apple:= self.game_object_factory.create_object("Apple", self)
	var set_position_event:= GameEngine.Event.new(
		"SetPosition",
		{"position": self.get_random_valid_world_position()}
	)
	apple.fire_event(set_position_event)


func spawn_player_body(
		player_game_object: GameEngine.GameObject,
		spawn_direction: Vector2 = Vector2.DOWN,
) -> void:

	var player_snake_body: Components.SnakeBody = player_game_object.components.get("SnakeBody")
	var new_snake_body_obj:= self.game_object_factory.create_object("SnakeBody", self)
	var tail: GameEngine.GameObject = player_snake_body.get_tail_game_object()

	Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)

	var set_position_event:= GameEngine.Event.new(
		"SetPosition",
		{"position": tail.physics_body.global_position + (spawn_direction * self.BASE_MOVE_SPEED)}
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
	position = self.convert_simple_to_world_coordinates(position)

	return position


func _fire_change_direction_event(input_name: String) -> void:
	var new_event:= GameEngine.Event.new("TryChangeDirection", {"input": input_name})
	self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _spawn_barrier(position: Vector2) -> void:
	var world_position: Vector2 = convert_simple_to_world_coordinates(position)
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
	self._spawn_barrier(Vector2(self.max_simple_size.x-1, self.max_simple_size.y-1))

	for coordinate in range(1, self.max_simple_size.x-1):
		self._spawn_barrier(Vector2(coordinate, 0))
		self._spawn_barrier(Vector2(coordinate, self.max_simple_size.y-1))
		self._spawn_barrier(Vector2(0, coordinate))
		self._spawn_barrier(Vector2(self.max_simple_size.x-1, coordinate))
