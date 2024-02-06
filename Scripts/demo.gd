class_name Demo extends Node

@export_file("*.tscn") var adventure_death_screen
@export var main_node: Main
@export var demo_label: Label

const START_LENGTH = 3

var poison_apple: GameEngine.GameObject

func _ready():
	var start_position: Vector2 = main_node.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, self.START_LENGTH)

	await get_tree().create_timer(0.1).timeout
	
	self.poison_apple = main_node.spawn_poison_apple()
	var display_components: String = "poison apple components: "
	for component_name in poison_apple.components:
		display_components += (component_name + ", ")
		
	demo_label.text = display_components


func end_game() -> void:
	get_tree().change_scene_to_file(adventure_death_screen)


func _on_button_pressed():
	poison_apple.add_component("Movable", { "speed": "1", "direction": "N", "priority": "99" })
