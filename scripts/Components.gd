extends GameEngine

class_name Components


class Physics extends Component:
	enum Directions {N=1, S=-1, E=1, W=-1}

	var speed: int = 0
	var direction: Directions = Directions.N


class Render extends Component:
	var texture: String = ""
