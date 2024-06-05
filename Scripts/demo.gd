class_name Demo extends Node

@export_file("*.tscn") var adventure_death_screen
@export var main_node: Main
@export var move_timer: MoveTimer

const START_LENGTH = 5
const APPLE_AMOUNT = 3


func _ready():
	self.main_node.spawn_background()

	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, self.START_LENGTH)
	self.main_node.queue_object_to_spawn("CrownItem")

	await get_tree().create_timer(0.1).timeout

	EventBus.game_started.emit("Demo")


func end_game() -> void:
	get_tree().change_scene_to_file(adventure_death_screen)


func setup_level() -> void:
	#var level_path: String = Settings.LEVELS_PATH + "level_" + str(Utils.roll(1, 2)) + ".tscn"
	var level_path: String = Settings.LEVELS_PATH + "level_1" + ".tscn"
	var scene: PackedScene = load(level_path)
	var level = scene.instantiate()
	var tile_map: TileMap = level.get_node("TileMap")
	self.main_node.level_factory.setup_level(tile_map, Vector2(10, 10))


func _on_button_pressed():
	setup_level()
