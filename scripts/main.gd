extends Node

class_name Main

const BLUEPRINTS_PATH = "res://Blueprints.txt"
const SPRITES_PATH = "res://Sprites/"
const TICK_THRESHOLD = 15
const SPRITE_SCALE_FACTOR = 0.2
const BASE_MOVE_SPEED = 32

var ticks: int = 0
var game_object_factory: GameEngine.GameObjectFactory


func _init() -> void:
    game_object_factory = GameEngine.GameObjectFactory.new()


func _ready() -> void:
    var john_goals_object:= game_object_factory.create_object("JohnGoals", self)
    var set_position_event:= GameEngine.Event.new(
        "SetPosition",
        {"position": Vector2(304, 304)}
    )
    john_goals_object.fire_event(set_position_event)

    # Demo: Multiple player controlled objs
    var john_goals_object2:= game_object_factory.create_object("JohnGoals", self)
    var set_position_event2:= GameEngine.Event.new(
        "SetPosition",
        {"position": Vector2(400, 400)}
    )
    john_goals_object2.fire_event(set_position_event2)


func _fire_change_direction_event(input_name: String):
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
