extends Node

class_name GameEngine

const BLUEPRINTS_PATH = "res://Blueprints.txt"
const SPRITES_PATH = "res://Sprites/"


class Event:
    var id: String
    var parameters: Dictionary

    func _init(id: String = "NoID", parameters: Dictionary = {}) -> void:
        self.id = id
        self.parameters = parameters


class Component:
    """
    Do not fire events to components directly, always fire events to
    GameObjects and let the GameObject fire the event to each of its components
    """
    var name: String

    # return event so that it's clear that event is changing in place
    func fire_event(event: Event) -> Event:
        return event


class GameObject:
    var name: String
    var components: Dictionary

    func _init(name: String = "NoName", components: Dictionary = {}) -> void:
        self.name = name
        self.components = components


    # return event so that it's clear that event is changing in place
    func fire_event(event: Event) -> Event:
        for component in self.components.values():
            event = component.fire_event(event)

        return event


class GameObjectFactory:
    var blueprints: Dictionary = {}

    func _init() -> void:
        self.blueprints = load_blueprints()


    func _get_blueprint_parameters(parser: XMLParser) -> Dictionary:
        var blueprint_parameters: Dictionary = {}

        for idx in parser.get_attribute_count():
            blueprint_parameters[parser.get_attribute_name(idx)] = (
                    parser.get_attribute_value(idx)
            )

        return blueprint_parameters


    func _get_inherited_components(
            blueprint: Dictionary,
            blueprints: Dictionary,
    ) -> Dictionary:
        var blueprint_to_inherit: String = blueprint["parameters"].get("Inherits")
        assert(
            blueprints.has(blueprint_to_inherit),
            "Blueprint Inheritence error: Inherited blueprint not found."
        )

        var new_blueprint: Dictionary = blueprint.duplicate(true)
        new_blueprint["components"] = (
                blueprints
                .get(blueprint_to_inherit)
                .get("components")
                .duplicate(true)
        )

        return new_blueprint


    func _format_blueprint(parser: XMLParser, blueprints: Dictionary) -> Dictionary:
        const MAX_LOOPS = 1000

        var blueprint: Dictionary = {
            "parameters": {},
            "components": {},
        }
        var blueprint_parameters: Dictionary = _get_blueprint_parameters(parser)
        blueprint["parameters"] = blueprint_parameters

        if blueprint["parameters"].has("Inherits"):
            blueprint = _get_inherited_components(blueprint, blueprints)

        parser.read()
        var node_name: String = parser.get_node_name()
        var loop_count: int = 0

        while (
                not (parser.get_node_type() == XMLParser.NODE_ELEMENT_END
                and node_name == "Blueprint")
                and loop_count < MAX_LOOPS
        ):
            var component_parameters: Dictionary = {}
            var component_name: String = parser.get_attribute_value(0)

            for idx in range(1, parser.get_attribute_count()):
                component_parameters[parser.get_attribute_name(idx)] = (
                        parser.get_attribute_value(idx)
                )
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
                    comp3: { p1: "p1", p2: "p2" },
                },
            },
        }
        """
        var blueprints: Dictionary = {}
        var parser: XMLParser = XMLParser.new()
        parser.open(BLUEPRINTS_PATH)

        while parser.read() != ERR_FILE_EOF:
            var node_name: String = parser.get_node_name()
            assert(
                    node_name == "Blueprint",
                    "Blueprints formatting error: Blueprint not found.",
            )

            var formatted_blueprint: Dictionary = _format_blueprint(parser, blueprints)
            var blueprint_name: String = formatted_blueprint["parameters"]["Name"]

            blueprints[blueprint_name] = formatted_blueprint

        return blueprints


    func _set_component_parameters(
            new_component: Variant,
            component_parameters: Dictionary,
    ) -> void:
        for parameter_name in component_parameters.keys():
            if parameter_name == "texture":
                component_parameters[parameter_name] = (
                        SPRITES_PATH + component_parameters[parameter_name]
                )

            if parameter_name in new_component:
                new_component[parameter_name] = component_parameters[parameter_name]


    func _create_components(blueprint_components: Dictionary) -> Dictionary:
        var components_class: Components = Components.new()
        var components: Dictionary = {}

        for idx in blueprint_components.size():
            var current_component_name: String = blueprint_components.keys()[idx]
            assert(
                    current_component_name in components_class,
                    "Create Components error: Component name not found.",
            )

            var current_parameters: Dictionary = blueprint_components.values()[idx]
            var new_component: Variant = components_class[current_component_name].new()
            _set_component_parameters(new_component, current_parameters)

            components[current_component_name] = new_component

        return components


    func create_object(blueprint_name: String) -> GameObject:
        assert(
                self.blueprints.has(blueprint_name),
                "Create Object error: Blueprint not found.",
        )

        var new_game_object: GameObject = GameObject.new(blueprint_name)
        var blueprint: Dictionary = self.blueprints.get(blueprint_name)
        var blueprint_components: Dictionary = blueprint.get("components")

        new_game_object.components = _create_components(blueprint_components)

        return new_game_object


