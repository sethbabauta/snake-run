extends Node

class_name Main

const BLUEPRINTS_PATH = "res://Blueprints.txt"
const SPRITES_PATH = "res://Sprites/"
const TICK_THRESHOLD = 25
const BASE_MOVE_SPEED = 239

var ticks: int = 0
var game_object_factory: GameEngine.GameObjectFactory
var john_goals_object: GameEngine.GameObject


func _init() -> void:
    game_object_factory = GameEngine.GameObjectFactory.new()
    john_goals_object = game_object_factory.create_object("JohnGoals", self)


func _ready() -> void:
    var set_position_event_parameters = {"position": Vector2(600, 300)}
    var set_position_event:= GameEngine.Event.new(
        "SetPosition",
        set_position_event_parameters
    )
    john_goals_object.fire_event(set_position_event)


func _physics_process(delta: float) -> void:
    ticks += 1
    # TODO: if correct input: create event w/ said RAW input, to be processed by all player-controlled
    if Input.is_action_just_pressed("turn_up"):
        print("input up")
        var new_event:= GameEngine.Event.new("ChangeDirection", {"input": "turn_up"})
        self.game_object_factory.notify_subscribers(new_event, "player_controlled")

    if Input.is_action_just_pressed("turn_left"):
        print("input l")
        var new_event:= GameEngine.Event.new("ChangeDirection", {"input": "turn_left"})
        self.game_object_factory.notify_subscribers(new_event, "player_controlled")

    if Input.is_action_just_pressed("turn_down"):
        print("input d")
        var new_event:= GameEngine.Event.new("ChangeDirection", {"input": "turn_down"})
        self.game_object_factory.notify_subscribers(new_event, "player_controlled")

    if Input.is_action_just_pressed("turn_right"):
        print("input r")
        var new_event:= GameEngine.Event.new("ChangeDirection", {"input": "turn_right"})
        self.game_object_factory.notify_subscribers(new_event, "player_controlled")

    if ticks > TICK_THRESHOLD:
        john_goals_object.fire_event(GameEngine.Event.new("MoveForward"))
        ticks = 0
