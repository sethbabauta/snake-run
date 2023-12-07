extends Node

class_name GameEngine

const BLUEPRINTS_PATH = "res://Blueprints.txt"

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
	var name: String
	var components: Dictionary = {}

	func fire_event(Event) -> bool:
		for component in components:
			component.fire_event(Event)
		return true

class GameObjectFactory:
	var blueprints: Dictionary = {}
	
	func _init():
		blueprints = load_blueprints()
	
	func load_blueprints() -> Dictionary:
		var blueprint_dict: Dictionary = {}
		var parser = XMLParser.new()
		parser.open(BLUEPRINTS_PATH)
		while parser.read() != ERR_FILE_EOF:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT:
				var node_name = parser.get_node_name()
				var attributes_dict = {}
				for idx in range(parser.get_attribute_count()):
					attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
				# print("The ", node_name, " element has the following attributes: ", attributes_dict)
				blueprint_dict[node_name] = attributes_dict

		return blueprint_dict

	func create_object(blueprint: String) -> GameObject:
		var new_game_object: GameObject = GameObject.new()
		# TODO: find blueprint in blueprints
		# TODO: instantiate all component based on what the found blueprint has w/ params
		return new_game_object

	
