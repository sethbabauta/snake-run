extends GameEngine

class_name Components


class Movable extends Component:
    var speed: int = 0
    var direction: String = "N"


    func _move_forward() -> void:
        match self.direction:
            "N":
                self.game_object.rigidbody.global_translate(Vector2.UP * Main.BASE_MOVE_SPEED)
            "S":
                self.game_object.rigidbody.global_translate(Vector2.DOWN * Main.BASE_MOVE_SPEED)
            "E":
                self.game_object.rigidbody.global_translate(Vector2.RIGHT * Main.BASE_MOVE_SPEED)
            "W":
                self.game_object.rigidbody.global_translate(Vector2.LEFT * Main.BASE_MOVE_SPEED)


    func _change_direction(event: Event) -> void:
        print(event.parameters)
        self.direction = event.parameters.get("direction")
        print("changing: ", self.direction)


    func fire_event(event: Event) -> Event:
        if event.id == "MoveForward":
            self._move_forward()
        if event.id == "ChangeDirection":
            self._change_direction(event)

        return event


class PlayerControlled extends Component:
    func _init(game_object: GameObject = null) -> void:
        super(game_object)
        self.game_object.factory_from.subscribe(game_object, "player_controlled")


    func fire_event(event: Event) -> Event:
        if event.id == "ChangeDirection":
            match event.parameters.get("input"):
                "turn_up":
                    event.parameters["direction"] = "N"
                "turn_left":
                    event.parameters["direction"] = "W"
                "turn_down":
                    event.parameters["direction"] = "S"
                "turn_right":
                    event.parameters["direction"] = "E"

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
