class_name Classic extends Node

@export_file("*.tscn") var classic_death_screen
@export var main_node: Main

const START_LENGTH = 5

func _ready():
	self.main_node.spawn_background()
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	self.main_node.spawn_player_snake(start_position, self.START_LENGTH)
	self.main_node.spawn_start_barriers()

	await get_tree().create_timer(0.1).timeout
	self.main_node.spawn_and_place_object("Apple")


func end_game() -> void:
	get_tree().change_scene_to_file(classic_death_screen)

