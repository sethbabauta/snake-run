class_name Demo extends Node

@export_file("*.tscn") var adventure_death_screen
@export var main_node: Main
@export var demo_label: Label

const START_LENGTH = 5
const APPLE_AMOUNT = 3

var poison_apples: Array = []

func _ready():
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, self.START_LENGTH)

	await get_tree().create_timer(0.1).timeout

	for idx in range(APPLE_AMOUNT):
		self.poison_apples.append(main_node.spawn_and_place_object("PoisonApple"))

	self.update_label()


func end_game() -> void:
	get_tree().change_scene_to_file(adventure_death_screen)


func update_label() -> void:
	if str(self.poison_apples[0].physics_body) != "<Freed Object>":
		var display_components: String = "poison apple components: "
		for component_name in self.poison_apples[0].components:
			display_components += (component_name + ", ")

		demo_label.text = display_components


func _on_button_pressed():
	for apple in self.poison_apples:
		apple.add_component("Movable", { "speed": "1", "direction": "N", "priority": "99" })
		apple.add_component("AIControlledSimple", { "priority": "101" })


func _on_timer_timeout():
	self.update_label()
