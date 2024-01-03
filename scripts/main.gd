class_name Main extends Node

const BLUEPRINTS_PATH = "res://Blueprints.txt"
const SPRITES_PATH = "res://Sprites/"
const PHYSICS_OBJECT_PATH = "res://Scenes/PhysicsObject.tscn"
const TICK_THRESHOLD = 15
const SPRITE_SCALE_FACTOR = 0.2
const BASE_MOVE_SPEED = 32

var ticks: int = 0
var game_object_factory: GameEngine.GameObjectFactory


func _init() -> void:
    game_object_factory = GameEngine.GameObjectFactory.new()


func _ready() -> void:
    _spawn_player_snake(Vector2(304, 304), 5)


func _spawn_player_snake(start_position: Vector2, snake_length: int) -> void:
    var john_goals_object:= game_object_factory.create_object("JohnGoals", self)
    var set_position_event:= GameEngine.Event.new(
        "SetPosition",
        {"position": start_position}
    )
    john_goals_object.fire_event(set_position_event)

    var jg_snake_body: Components.SnakeBody = john_goals_object.components.get("SnakeBody")
    for snake_body_idx in range(snake_length-1):
        var new_snake_body_obj:= game_object_factory.create_object("JohnGoalsSnakeBody", self)
        var tail: GameEngine.GameObject = jg_snake_body.get_tail_game_object()

        Components.SnakeBody.connect_bodies(tail, new_snake_body_obj)

        set_position_event = GameEngine.Event.new(
            "SetPosition",
            {"position": tail.rigidbody.global_position + (Vector2.DOWN * BASE_MOVE_SPEED)}
        )
        new_snake_body_obj.fire_event(set_position_event)


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

    if ticks > TICK_THRESHOLD:
        var new_event:= GameEngine.Event.new("MoveForward")
        self.game_object_factory.notify_subscribers(new_event, "movable")

        ticks = 0
