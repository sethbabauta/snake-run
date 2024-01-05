class_name Main extends Node

const BLUEPRINTS_PATH = "res://Blueprints.txt"
const SPRITES_PATH = "res://Sprites/"
const PHYSICS_OBJECT_PATH = "res://Scenes/PhysicsObject.tscn"
const TICK_THRESHOLD = 10
const BASE_MOVE_SPEED = 32

var ticks: int = 0
var game_object_factory: GameEngine.GameObjectFactory
var max_simple_size: Vector2


func _init() -> void:
    self.game_object_factory = GameEngine.GameObjectFactory.new()


func _ready() -> void:
    self.max_simple_size = get_viewport().get_visible_rect().size / BASE_MOVE_SPEED

    var start_position: Vector2 = self.convert_simple_to_world_coordinates(Vector2(9, 9))
    self.spawn_player_snake(start_position, 7)
    self._spawn_start_barriers()


func spawn_player_snake(start_position: Vector2, snake_length: int) -> void:
    var snake_head:= self.game_object_factory.create_object("PlayerSnakeHead", self)
    var set_position_event:= GameEngine.Event.new(
        "SetPosition",
        {"position": start_position}
    )
    snake_head.fire_event(set_position_event)

    var jg_snake_body: Components.SnakeBody = snake_head.components.get("SnakeBody")

    for snake_body_idx in range(snake_length-1):
        var new_snake_body_obj:= self.game_object_factory.create_object("SnakeBody", self)
        var tail: GameEngine.GameObject = jg_snake_body.get_tail_game_object()

        Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)

        set_position_event = GameEngine.Event.new(
            "SetPosition",
            {"position": tail.physics_body.global_position + (Vector2.DOWN * self.BASE_MOVE_SPEED)}
        )
        new_snake_body_obj.fire_event(set_position_event)


func _spawn_start_barriers() -> void:
    for coordinate in range(self.max_simple_size.x):
        self._spawn_barrier(Vector2(coordinate, 0))
        self._spawn_barrier(Vector2(coordinate, self.max_simple_size.y-1))
        self._spawn_barrier(Vector2(0, coordinate))
        self._spawn_barrier(Vector2(self.max_simple_size.x-1, coordinate))


func _spawn_barrier(position: Vector2) -> void:
    var world_position: Vector2 = convert_simple_to_world_coordinates(position)
    var barrier:= self.game_object_factory.create_object("Barrier", self)
    var set_position_event:= GameEngine.Event.new(
        "SetPosition",
        {"position": world_position}
    )
    barrier.fire_event(set_position_event)


func convert_world_to_simple_coordinates(coordinates: Vector2) -> Vector2:
    var new_coordinates:= (
            (coordinates.round() - (Vector2.ONE * (self.BASE_MOVE_SPEED / 2)))
            .snapped(Vector2.ONE * self.BASE_MOVE_SPEED) / self.BASE_MOVE_SPEED
    )
    return new_coordinates


func convert_simple_to_world_coordinates(coordinates: Vector2) -> Vector2:
    var new_coordinates:= (
            (coordinates.round() * self.BASE_MOVE_SPEED)
            + (Vector2.ONE * (self.BASE_MOVE_SPEED / 2))
    )
    return new_coordinates


func _fire_change_direction_event(input_name: String) -> void:
    var new_event:= GameEngine.Event.new("TryChangeDirection", {"input": input_name})
    self.game_object_factory.notify_subscribers(new_event, "player_controlled")


func _physics_process(delta: float) -> void:
    ticks += 1

    if Input.is_action_just_pressed("turn_up"):
        _fire_change_direction_event("turn_up")

    if Input.is_action_just_pressed("turn_left"):
        _fire_change_direction_event("turn_left")

    if Input.is_action_just_pressed("turn_down"):
        _fire_change_direction_event("turn_down")

    if Input.is_action_just_pressed("turn_right"):
        _fire_change_direction_event("turn_right")

    if ticks > self.TICK_THRESHOLD:
        var new_event:= GameEngine.Event.new("MoveForward")
        self.game_object_factory.notify_subscribers(new_event, "movable")

        ticks = 0
