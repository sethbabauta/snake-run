extends GameEngine

class_name Components


class Movable extends Component:
    var speed: int = 0
    var direction: String = "N"


    func _move_forward(event: Event) -> void:
        match self.direction:
            "N":
                self.game_object.rigidbody.global_translate(Vector2.UP * GameEngine.BASE_MOVE_SPEED)
            "S":
                self.game_object.rigidbody.global_translate(Vector2.DOWN * GameEngine.BASE_MOVE_SPEED)
            "E":
                self.game_object.rigidbody.global_translate(Vector2.RIGHT * GameEngine.BASE_MOVE_SPEED)
            "W":
                self.game_object.rigidbody.global_translate(Vector2.LEFT * GameEngine.BASE_MOVE_SPEED)


    func _change_direction(event: Event) -> void:
        self.direction = event.parameters.get("direction")


    func fire_event(event: Event) -> Event:
        if event.id == "MoveForward":
            self._move_forward(event)
        if event.id == "ChangeDirection":
            self._change_direction(event)

        return event


class PlayerControlled extends Component:
    func _init(game_object: GameObject = null) -> void:
        super(game_object)
        self.game_object.factory_from.subscribe(game_object, "player_controlled")


    func fire_event(event: Event) -> Event:
        if event.id == "ChangeDirection":
            pass

        return event


class Render extends Component:
    var texture: String = ""
    var sprite_node: Sprite2D


    func first_time_setup() -> void:
        self.sprite_node = Sprite2D.new()
        sprite_node.texture = load(self.texture)
        self.game_object.rigidbody.add_child(sprite_node)


    func fire_event(event: Event) -> Event:
        if event.id == "SetPosition":
            self.game_object.rigidbody.global_position = event.parameters.get("position")

        return event
