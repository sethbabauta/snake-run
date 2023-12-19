extends Node

const GameEngine = preload("res://scripts/GameEngine.gd")

const TICK_THRESHOLD = 25
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
    if ticks > TICK_THRESHOLD:
        # TODO: if correct input: create event w/ said RAW input, to be processed by all player-controlled
        john_goals_object.fire_event(GameEngine.Event.new("MoveForward"))
        ticks = 0
