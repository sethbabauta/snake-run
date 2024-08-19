class_name Classic extends Node

const START_LENGTH = 5

@export var classic_death_screen: PackedScene

@onready var main_node: Main = %Main
@onready var game_announcer: GameAnnouncer = %GameAnnouncer
@onready var game_ui: GameUI = %GameUI


func _ready():
	main_node.spawn_background()
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, START_LENGTH)
	main_node.spawn_start_barriers()

	game_announcer.announce_message("3 2 1 GO!", 1.05)
	await get_tree().create_timer(1).timeout
	main_node.queue_object_to_spawn("Apple")
	await EventBus.announcement_completed

	EventBus.game_started.emit("Classic")

	var snake_go: GameEngine.GameObject = main_node.get_closest_player_controlled(Vector2.ZERO)
