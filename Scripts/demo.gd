class_name Demo extends Node

@export_file("*.tscn") var adventure_death_screen
@export var main_node: Main
@export var demo_label: Label

const START_LENGTH = 3

var poison_apple: GameEngine.GameObject
var player: GameEngine.GameObject

func _ready():
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, self.START_LENGTH)

	await get_tree().create_timer(0.1).timeout

	self.poison_apple = main_node.spawn_and_place_object("PoisonApple")
	self.update_label()


func end_game() -> void:
	get_tree().change_scene_to_file(adventure_death_screen)


func update_label() -> void:
	if str(self.poison_apple.physics_body) != "<Freed Object>":
		var display_components: String = "poison apple components: "
		for component_name in self.poison_apple.components:
			display_components += (component_name + ", ")

		demo_label.text = display_components

		self.player = main_node.get_closest_player_controlled(poison_apple)


func _on_button_pressed():
	poison_apple.add_component("Movable", { "speed": "1", "direction": "N", "priority": "99" })
	poison_apple.add_component("AIControlledSimple", { "priority": "101" })


func _on_timer_timeout():
	self.update_label()
