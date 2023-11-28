extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

class Event:
	var id: String
	var parameters: Dictionary

class Component:
	"""
	Do not fire events to components directly, always fire events to GameObjects
	and let the GameObject fire the event to each of its components
	""" 
	func fire_event(Event) -> bool:
		return true

class GameObject:
	var components: Array[Component]
	
	func fire_event(Event) -> bool:
		for component in components:
			component.fire_event(Event)
		return true

class GameObjectFactory:
	func load_blueprints() -> void:
		return

	func create_object(blueprint: String) -> GameObject:
		var new_game_object: GameObject = GameObject.new()
		return new_game_object
