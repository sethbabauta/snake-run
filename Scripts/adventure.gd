class_name Adventure extends Node

@export_file("*.tscn") var adventure_death_screen
@export var main_node: Main

const START_LENGTH = 3

func _ready():
	ScoreKeeper.SCORE_CHANGED.connect(_on_score_changed)

	self.main_node.spawn_background()
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	self.main_node.spawn_player_snake(start_position, self.START_LENGTH)
	setup_level()

	await get_tree().create_timer(1).timeout
	self.main_node.spawn_and_place_object("Apple")
	self.main_node.spawn_doors()
	await get_tree().create_timer(2).timeout

	var move_timer: Timer = get_node("MoveTimer")
	move_timer.start()


func end_game() -> void:
	get_tree().change_scene_to_file(adventure_death_screen)


func end_level() -> void:
	self.main_node.clear_doors()
	await get_tree().create_timer(0.05).timeout
	self.main_node.clear_pickups()


func setup_level() -> void:
	var level_path: String = Settings.LEVELS_PATH + "Room30.tscn"
	var scene: PackedScene = load(level_path)
	var level = scene.instantiate()
	var tile_map: TileMap = level.get_node("SnakeWorldTileMap")
	self.main_node.level_factory.setup_level(tile_map, Vector2(0, 0))


func _on_score_changed(score: int) -> void:
	if score == 5:
		end_level()
