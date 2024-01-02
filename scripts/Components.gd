extends GameEngine

class_name Components


class Movable extends Component:
    const VALID_DIRECTIONS: Array = ["N", "S", "E", "W"]
    var speed: int = 0
    var direction: String = "N"

    func _init(game_object: GameObject = null) -> void:
        super(game_object)
        self.game_object.factory_from.subscribe(game_object, "movable")


    func _move_forward() -> void:
        match self.direction:
            "N":
                self.game_object.rigidbody.global_translate(
                        Vector2.UP * Main.BASE_MOVE_SPEED
                )
            "S":
                self.game_object.rigidbody.global_translate(
                        Vector2.DOWN * Main.BASE_MOVE_SPEED
                )
            "E":
                self.game_object.rigidbody.global_translate(
                        Vector2.RIGHT * Main.BASE_MOVE_SPEED
                )
            "W":
                self.game_object.rigidbody.global_translate(
                        Vector2.LEFT * Main.BASE_MOVE_SPEED
                )


    func _change_direction(event: Event) -> void:
        if event.parameters.get("direction") in self.VALID_DIRECTIONS:
            self.direction = event.parameters.get("direction")


    func _try_change_direction(event: Event) -> void:
        var new_event:= Event.new("ChangeDirection", event.parameters.duplicate(true))
        new_event.parameters["current_direction"] = self.direction
        self.game_object.queue_event_job(self.game_object, new_event)


    func fire_event(event: Event) -> Event:
        if event.id == "MoveForward":
            self._move_forward()
        if event.id == "ChangeDirection":
            self._change_direction(event)
        if event.id == "TryChangeDirection":
            self._try_change_direction(event)

        return event


class PlayerControlled extends Component:
    func _init(game_object: GameObject = null) -> void:
        super(game_object)
        self.game_object.factory_from.subscribe(
                game_object, "player_controlled"
        )


    func _is_opposite_direction(current_direction: String, new_direction: String) -> bool:
        if current_direction == "N" and new_direction == "S":
            return true
        if current_direction == "S" and new_direction == "N":
            return true
        if current_direction == "E" and new_direction == "W":
            return true
        if current_direction == "W" and new_direction == "E":
            return true
        return false


    func fire_event(event: Event) -> Event:
        if event.id == "ChangeDirection":
            var new_direction: String
            match event.parameters.get("input"):
                "turn_up":
                    new_direction = "N"
                "turn_left":
                    new_direction = "W"
                "turn_down":
                    new_direction = "S"
                "turn_right":
                    new_direction = "E"

            if not _is_opposite_direction(event.parameters.get("current_direction"), new_direction):
                event.parameters["direction"] = new_direction
            else:
                event.parameters["direction"] = "0"

        return event


class Render extends Component:
    var texture: String = ""
    var sprite_node: Sprite2D


    func first_time_setup() -> void:
        self.sprite_node = Sprite2D.new()
        self.sprite_node.texture = load(self.texture)
        self.game_object.rigidbody.add_child(sprite_node)


    func fire_event(event: Event) -> Event:
        if event.id == "SetPosition":
            self.game_object.rigidbody.global_position = (
                    event.parameters.get("position")
            )

        return event


class SnakeBody extends Component:
    var next_body: GameObject = null
    var prev_body: GameObject = null
    var prev_location: Vector2

    static func connect_bodies(next_body: GameObject, prev_body: GameObject) -> void:
        var next_body_snakebody: SnakeBody = next_body.components.get("SnakeBody")
        var prev_body_snakebody: SnakeBody = prev_body.components.get("SnakeBody")
        if next_body_snakebody and prev_body_snakebody:
            next_body_snakebody.prev_body = prev_body
            prev_body_snakebody.next_body = next_body


    func _follow_next_body() -> void:
        if self.next_body:
            var next_snake_body: SnakeBody = self.next_body.components.get("SnakeBody")
            self.prev_location = self.game_object.rigidbody.global_position
            self.game_object.rigidbody.global_position = next_snake_body.prev_location

        if self.prev_body:
            self.game_object.queue_event_job(self.prev_body, Event.new("FollowNextBody"))


    func _move_forward() -> void:
        self.prev_location = self.game_object.rigidbody.global_position

        if self.prev_body:
            self.game_object.queue_event_job(prev_body, Event.new("FollowNextBody"))


    func fire_event(event: Event) -> Event:
        if event.id == "FollowNextBody":
            self._follow_next_body()
        if event.id == "MoveForward":
            self._move_forward()

        return event
