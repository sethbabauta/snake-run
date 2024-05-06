class_name Classic extends Node

const START_LENGTH = 5

@export var classic_death_screen: PackedScene

@onready var main_node: Main = %Main


func _ready():
	main_node.spawn_background()
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, START_LENGTH)
	main_node.spawn_start_barriers()

	await get_tree().create_timer(1).timeout
	main_node.spawn_and_place_object("Apple")
	await get_tree().create_timer(2).timeout

	EventBus.game_started.emit("Classic")


func end_game(won: bool = false) -> void:
	if not won:
		get_tree().change_scene_to_packed(classic_death_screen)
		return
