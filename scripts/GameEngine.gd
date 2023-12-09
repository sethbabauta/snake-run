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
		var blueprint_dict: Dictionary = {
			"Blueprint": {},
			"Component": {},
		}
		var parser = XMLParser.new()
		parser.open(BLUEPRINTS_PATH)
		while parser.read() != ERR_FILE_EOF:
			# if parsing NODE_ELEMENT of name Blueprint create new dict inside 
			# blueprint_dict named after the blueprint name
			
			# add component details to a new dict until parsing NODE_ELEMENT_END 
			# of name Blueprint set dict inside blueprint_dict
			
			
			if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
				print(parser.get_node_name())
			if parser.get_node_type() == XMLParser.NODE_ELEMENT:
				var node_name = parser.get_node_name()
				var attributes_dict = {}

				if node_name == "Blueprint":
					for idx in parser.get_attribute_count():
						attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
					blueprint_dict[node_name] = attributes_dict

				if node_name == "Component":
					var component_name = parser.get_attribute_value(0)
					for idx in range(1, parser.get_attribute_count()):
						attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
					blueprint_dict[node_name][component_name] = attributes_dict

				# print("The ", node_name, " element has the following attributes: ", attributes_dict)
				# blueprint_dict[node_name].append(attributes_dict)

		print(blueprint_dict)
		return blueprint_dict

	func create_object(blueprint: String) -> GameObject:
		var new_game_object: GameObject = GameObject.new()
		# TODO: find blueprint in blueprints
		
		# TODO: instantiate all component based on what the found blueprint has w/ params

		return new_game_object

	
