extends GameEngine

class_name Components


class Physics extends Component:
    enum Directions {N=1, S=-1, E=1, W=-1}

    var speed: int = 0
    var direction: Directions = Directions.N


class Render extends Component:
    var texture: String = ""

    func fire_event(event: Event) -> Event:
        if event.id == "CreateSpriteNode":
            var sprite_node:= Sprite2D.new()
            sprite_node.position = event.parameters.get("start_position")
            sprite_node.texture = load(self.texture)
            event.parameters.get("parent_node").add_child(sprite_node)

        return event
