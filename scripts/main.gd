extends Node


func _ready() -> void:
    generate_nodes()


func generate_nodes() -> void:
    var game_object_factory:= GameEngine.GameObjectFactory.new()
    var john_goals_object: GameEngine.GameObject = game_object_factory.create_object("JohnGoals")

    var create_sprite_node_event_parameters = {"parent_node": self, "start_position": Vector2(600, 300)}
    var create_sprite_node_event:= GameEngine.Event.new(
        "CreateSpriteNode",
        create_sprite_node_event_parameters
    )
    john_goals_object.fire_event(create_sprite_node_event)
