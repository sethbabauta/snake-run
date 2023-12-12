extends Node

class_name Components

class Physics:
	enum Directions {N=1, S=-1, E=1, W=-1}
	var direction: Directions = Directions.N
	var speed: int = 0

class Render:
	var texture: String

	func _init(texture="res://Sprites/johngoals.jpg"):
		texture = texture
