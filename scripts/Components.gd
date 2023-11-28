extends Node

class PhysicsComponent:
	enum Directions {N=1, S=-1, E=1, W=-1}
	var direction: Directions = Directions.N
	var speed: int = 0

class Render:
	var sprite: String
