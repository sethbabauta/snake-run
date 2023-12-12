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

	func _init(name="NoName") -> void:
		name = name

	func fire_event(Event) -> bool:
		for component in components:
			component.fire_event(Event)
		return true

class GameObjectFactory:
	var blueprints: Dictionary = {}

	func _init() -> void:
		blueprints = load_blueprints()
		# print(blueprints)

	func _get_blueprint_params(parser: XMLParser) -> Dictionary:
		var blueprint_params: Dictionary = {}
		for idx in parser.get_attribute_count():
			blueprint_params[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)

		return blueprint_params

	func _get_inherited_components(blueprint: Dictionary, blueprints: Dictionary) -> Dictionary:
		var blueprint_to_inherit = blueprint["params"].get("Inherits")
		assert(
			blueprints.has(blueprint_to_inherit),
			"Blueprint Inheritence error: Inherited blueprint not found."
		)

		var new_blueprint = blueprint.duplicate(true)
		new_blueprint["components"] = blueprints.get(blueprint_to_inherit).get("components").duplicate(true)
		return new_blueprint

	func _format_blueprint(parser: XMLParser, blueprints: Dictionary) -> Dictionary:
		var blueprint: Dictionary = {
			"params": {},
			"components": {},
		}
		var blueprint_params: Dictionary = _get_blueprint_params(parser)
		blueprint["params"] = blueprint_params

		if blueprint["params"].has("Inherits"):
			blueprint = _get_inherited_components(blueprint, blueprints)

		var node_name = parser.get_node_name()
		parser.read()
		var loop_count = 0
		while not (parser.get_node_type() == XMLParser.NODE_ELEMENT_END and node_name == "Blueprint") and loop_count < 1000:
			var component_params: Dictionary = {}
			var component_name = parser.get_attribute_value(0)

			for idx in range(1, parser.get_attribute_count()):
				component_params[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
			blueprint["components"][component_name] = component_params

			parser.read()
			node_name = parser.get_node_name()
			loop_count += 1

		return blueprint

	func load_blueprints() -> Dictionary:
		"""
		Converts XML Blueprints into dict like:
		{
			bp1: {
				params: { Name: "bp1" },
				components: {
					comp1: { p1: "p1", p2: "p2" },
					comp2: { p1: "p1", p2: "p2" },
				},
			},
			bp2: {
				params: { Name: "bp2", Inherits: "bp1" },
				components: {
					comp3: { p1: "p1", p2: "p2" },
				},
			},
		}
		"""
		var blueprints: Dictionary = {}
		var parser = XMLParser.new()
		parser.open(BLUEPRINTS_PATH)
		while parser.read() != ERR_FILE_EOF:
			var node_name = parser.get_node_name()
			assert(node_name == "Blueprint", "Blueprints formatting error: Blueprint not found.")

			var formatted_blueprint = _format_blueprint(parser, blueprints)
			var blueprint_name = formatted_blueprint["params"]["Name"]
			blueprints[blueprint_name] = formatted_blueprint

		return blueprints

	func create_object(blueprint_name: String) -> GameObject:
		assert(blueprints.has(blueprint_name), "Create Object error: Blueprint not found.")
		var components_class = Components.new()
		var new_game_object: GameObject = GameObject.new(blueprint_name)
		var blueprint = blueprints.get(blueprint_name)

		# TODO: instantiate all component based on what the found blueprint has w/ params
		var components = blueprint.get("components")

		for idx in components.size():
			var current_component_name = components.keys()[idx]
			assert(current_component_name in components_class)
			var new_component = components_class[current_component_name].new()
			new_game_object.components[current_component_name] = new_component

		return new_game_object


