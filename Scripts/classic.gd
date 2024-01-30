class_name Classic extends Node

@export var main_node: Main

func _ready():
	var start_position: Vector2 = main_node.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, main_node.START_LENGTH)
	main_node._spawn_start_barriers()

	await get_tree().create_timer(0.1).timeout
	main_node.spawn_apple()
