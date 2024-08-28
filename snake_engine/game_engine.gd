class_name GameEngine extends RefCounted


class Component:
	"""
	Do not fire events to components directly, always fire events to
	GameObjects and let the GameObject fire the event to each of its components
	"""
	var name: String
	var game_object: GameObject
	var priority: int = 100
	var initial_parameters: Dictionary

	func _init(p_name: String, p_game_object: GameObject = null) -> void:
		self.name = p_name
		self.game_object = p_game_object

	func first_time_setup() -> void:
		pass

	# return event so that it's clear that event is changing in place
	func fire_event(event: Event) -> Event:
		return event

	func on_add() -> void:
		pass

	func on_remove() -> void:
		pass

	func set_parameters(component_parameters: Dictionary) -> void:
		self.initial_parameters = component_parameters

		for parameter_name in component_parameters.keys():
			if parameter_name == "texture":
				component_parameters[parameter_name] = (
					Settings.SPRITES_PATH + component_parameters[parameter_name]
				)

			if parameter_name in self:
				self[parameter_name] = component_parameters[parameter_name]

	func _to_string() -> String:
		return "(%s, priority: %f)" % [self.name, self.priority]


class Event:
	var id: String
	var parameters: Dictionary
	var unique_id: int

	func _init(p_id: String = "NoID", p_parameters: Dictionary = {}) -> void:
		self.id = p_id
		self.parameters = p_parameters
		self.parameters["after_effects"] = []
		self.unique_id = Utils.rng.randi_range(1, 10000)

	static func dequeue_after_effect(
		event: Event,
		event_id_to_dequeue: String,
	) -> void:
		var event_job_to_dequeue: EventJob
		for job in event.parameters["after_effects"]:
			if job.event.id == event_id_to_dequeue:
				event_job_to_dequeue = job
				break

		if event_id_to_dequeue:
			event.parameters["after_effects"].erase(event_job_to_dequeue)

	static func queue_after_effect(
		target: GameObject,
		new_event: Event,
		event: Event,
	) -> void:
		var event_job := EventJob.new(target, new_event)
		event.parameters["after_effects"].append(event_job)


class EventJob:
	var target: GameObject
	var event: Event

	func _init(p_target: GameObject, p_event: Event) -> void:
		self.target = p_target
		self.event = p_event


class GameObject:
	var name: String
	var unique_id: int
	var main_node: Main
	var components: Dictionary
	var physics_body: Area2D
	var factory_from: GameObjectFactory
	var component_priority: Array
	var subscribed_to: Array = []
	var remove_component_queue: Array = []

	func _init(
		p_name: String = "NoName",
		p_main_node: Node = null,
		p_components: Dictionary = {},
		p_physics_body = null,
	) -> void:
		self.name = p_name
		self.main_node = p_main_node
		self.components = p_components
		self.physics_body = p_physics_body
		self.unique_id = Utils.rng.randi_range(1, 10000)

	func _to_string() -> String:
		var as_string: String = "%s.%s" % [self.name, str(self.unique_id)]
		return as_string

	func add_component(
		component_name: String,
		component_parameters: Dictionary,
	) -> void:
		var components_class: Components = Components.new()
		var new_component: Variant = components_class[component_name].new(component_name, self)
		new_component.set_parameters(component_parameters)
		new_component.first_time_setup()

		new_component.on_add()

		self.components[component_name] = new_component
		self._insert_component_priority(new_component)
		print("Comp prio: ", component_priority)

	func delete_self() -> void:
		var subscribed_copy = self.subscribed_to.duplicate(true)
		for list_name in subscribed_copy:
			self.factory_from.unsubscribe(self, list_name)

		self.physics_body.queue_free()

	# return event so that it's clear that event is changing in place
	func fire_event(event: Event) -> Event:
		#print("\n", self.name, " received event: ", event.id, ".", event.unique_id)
		# higher priority number first
		for component in self.component_priority:
			event = self.components[component.name].fire_event(event)

		if event.parameters["after_effects"]:
			var event_job_queue: Array = event.parameters["after_effects"].duplicate(true)

			for event_job in event_job_queue:
				var event_target: GameObject = event_job.target
				var next_event: Event = event_job.event
				event.parameters["after_effects"].erase(event_job)
				event_target.fire_event(next_event)

		if self.remove_component_queue:
			for component_name in self.remove_component_queue:
				self.remove_component(component_name)

		return event

	func queue_remove_component(component_name: String) -> void:
		self.remove_component_queue.append(component_name)

	func remove_component(component_name: String) -> void:
		self.remove_component_queue.erase(component_name)
		if component_name in self.components:
			self.components[component_name].on_remove()
			self.components.erase(component_name)
			self._remove_from_component_priority(component_name)

	func _component_priority_bsearch_function(
		current_component: Component,
		new_component: Component,
	) -> bool:
		# descending
		return current_component.priority > new_component.priority

	func _insert_component_priority(new_component: Component) -> void:
		var insert_index: int = (
			self
			. component_priority
			. bsearch_custom(
				new_component,
				self._component_priority_bsearch_function,
			)
		)
		self.component_priority.insert(insert_index, new_component)

	func _remove_from_component_priority(component_name: String) -> void:
		for component in self.component_priority:
			if component.name == component_name:
				self.component_priority.erase(component)


class GameObjectFactory:
	var blueprints: Dictionary = {}
	var subscribe_lists: Dictionary = {}

	func _init() -> void:
		self.blueprints = self.load_blueprints()

	func _get_blueprint_parameters(parser: XMLParser) -> Dictionary:
		var blueprint_parameters: Dictionary = {}

		for idx in parser.get_attribute_count():
			blueprint_parameters[parser.get_attribute_name(idx)] = (parser.get_attribute_value(idx))

		return blueprint_parameters

	func _get_inherited_components(
		child_blueprint: Dictionary,
		unformatted_blueprints: Dictionary,
	) -> Dictionary:
		var blueprint_to_inherit: String = child_blueprint["parameters"].get("Inherits")
		assert(
			unformatted_blueprints.has(blueprint_to_inherit),
			"Blueprint Inheritence error: Inherited blueprint not found."
		)

		var new_blueprint: Dictionary = child_blueprint.duplicate(true)
		new_blueprint["components"] = (
			unformatted_blueprints.get(blueprint_to_inherit).get("components").duplicate(true)
		)

		return new_blueprint

	func _format_blueprint(parser: XMLParser, unformatted_blueprints: Dictionary) -> Dictionary:
		const MAX_LOOPS = 1000

		var blueprint: Dictionary = {
			"parameters": {},
			"components": {},
		}
		var blueprint_parameters: Dictionary = self._get_blueprint_parameters(parser)
		blueprint["parameters"] = blueprint_parameters

		if blueprint["parameters"].has("Inherits"):
			blueprint = self._get_inherited_components(blueprint, unformatted_blueprints)

		parser.read()
		var node_name: String = parser.get_node_name()
		var loop_count: int = 0

		while (
			not (parser.get_node_type() == XMLParser.NODE_ELEMENT_END and node_name == "Blueprint")
			and loop_count < MAX_LOOPS
		):
			var component_parameters: Dictionary = {}
			var component_name: String = parser.get_attribute_value(0)

			for idx in range(1, parser.get_attribute_count()):
				component_parameters[parser.get_attribute_name(idx)] = (parser.get_attribute_value(
					idx
				))

			if not component_parameters.has("priority"):
				component_parameters["priority"] = "100"

			blueprint["components"][component_name] = component_parameters

			parser.read()
			node_name = parser.get_node_name()
			loop_count += 1

		return blueprint

	func load_blueprints() -> Dictionary:
		"""
		Converts XML Blueprints into dict like:
		{
			bp1: {
				parameters: { Name: "bp1" },
				components: {
					comp1: { p1: "p1", p2: "p2" },
					comp2: { p1: "p1", p2: "p2" },
				},
			},
			bp2: {
				parameters: { Name: "bp2", Inherits: "bp1" },
				components: {
					comp1: { p1: "p1", p2: "p2" },
					comp2: { p1: "p1", p2: "p2" },
					comp3: { p1: "p1", priority: "99" },
				},
			},
		}
		"""
		var loaded_blueprints: Dictionary = {}
		var parser: XMLParser = XMLParser.new()
		parser.open(Settings.BLUEPRINTS_PATH)

		while parser.read() != ERR_FILE_EOF:
			var node_name: String = parser.get_node_name()
			assert(
				node_name == "Blueprint",
				"Blueprints formatting error: Blueprint not found.",
			)

			var formatted_blueprint: Dictionary = self._format_blueprint(parser, loaded_blueprints)
			var blueprint_name: String = formatted_blueprint["parameters"]["Name"]

			loaded_blueprints[blueprint_name] = formatted_blueprint

		return loaded_blueprints

	func _add_components_from_blueprint(
		blueprint_components: Dictionary,
		game_object: GameObject,
	) -> void:
		for idx in blueprint_components.size():
			var current_component_name: String = blueprint_components.keys()[idx]

			var current_parameters: Dictionary = blueprint_components.values()[idx].duplicate(true)
			game_object.add_component(current_component_name, current_parameters)

	func create_object(blueprint_name: String, main_node: Node) -> GameObject:
		assert(
			self.blueprints.has(blueprint_name),
			"Create Object error: Blueprint not found.",
		)

		var new_game_object: GameObject = GameObject.new(blueprint_name, main_node)
		new_game_object.factory_from = self
		var blueprint: Dictionary = self.blueprints.get(blueprint_name)
		var blueprint_components: Dictionary = blueprint.get("components")

		self._add_components_from_blueprint(blueprint_components, new_game_object)

		return new_game_object

	func subscribe(game_object: GameObject, list_name: String) -> void:
		if self.subscribe_lists.has(list_name):
			self.subscribe_lists[list_name].append(game_object)
		else:
			self.subscribe_lists[list_name] = [game_object]

		game_object.subscribed_to.append(list_name)

	func unsubscribe(game_object: GameObject, list_name: String) -> void:
		if self.subscribe_lists.has(list_name):
			self.subscribe_lists[list_name].erase(game_object)

		game_object.subscribed_to.erase(list_name)

	func notify_subscribers(event: Event, list_name: String) -> void:
		var subscribers = self.subscribe_lists.get(list_name)
		if subscribers:
			var subscribers_copy: Array = subscribers.duplicate(true)
			for game_object in subscribers_copy:
				var event_copy: Event = Event.new(event.id, event.parameters.duplicate(true))
				game_object.fire_event(event_copy)
