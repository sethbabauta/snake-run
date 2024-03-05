class_name Adventure extends Node

signal GAME_START

@export_file("*.tscn") var adventure_death_screen
@export var main_node: Main

const START_LENGTH = 3

var move_timer: MoveTimer

# TODO: Clean this up
var level_start_points = {
	"Room30.tscn": Vector2(0,0),
	"Room20.tscn": Vector2(-20, 0),
	"Room31.tscn": Vector2(0,-20),
	"Room21.tscn": Vector2(-20, -20),
	"Room32.tscn": Vector2(0,-40),
	"Room22.tscn": Vector2(-20, -40),
	"Room00.tscn": Vector2(0, 20)
}
var level_score_thresholds = {
	"Room30.tscn": 3,
	"Room20.tscn": 3,
	"Room21.tscn": 4,
	"Room31.tscn": 5,
	"Room22.tscn": 3,
	"Room32.tscn": 5,
	"Room00.tscn": 0,
}
var cleared_levels: Array = []
var current_level: String = "Room30.tscn"
var current_level_score = 0

# TODO: Clean this up
func _ready():
	ScoreKeeper.SCORE_CHANGED.connect(_on_score_changed)
	self.main_node.follow_camera.LEVEL_CHANGED.connect(_on_level_changed)
	self.main_node.follow_camera.PLAYER_FULLY_ENTERED.connect(_on_fully_entered)

	for start_point in self.level_start_points.values():
		self.main_node.spawn_background(start_point)
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	self.main_node.spawn_player_snake(start_position, self.START_LENGTH)
	setup_levels()

	await get_tree().create_timer(1).timeout
	self.main_node.spawn_start_doors()
	await get_tree().create_timer(1).timeout
	self.main_node.spawn_and_place_object("Apple")
	await get_tree().create_timer(1).timeout

	self.move_timer = get_node("MoveTimer")
	self.move_timer.start()

	self.GAME_START.emit()


func end_game() -> void:
	get_tree().change_scene_to_file(adventure_death_screen)


func end_level() -> void:
	self.main_node.clear_doors()
	await get_tree().create_timer(0.05).timeout
	self.main_node.clear_pickups()
	self.current_level_score = 0
	self.cleared_levels.append(self.current_level)


# TODO: Clean this up
func setup_level(level_name: String, start_position: Vector2) -> void:
	var level_path: String = Settings.LEVELS_PATH + level_name
	var scene: PackedScene = load(level_path)
	var level = scene.instantiate()
	var tile_map: TileMap = level.get_node("SnakeWorldTileMap")
	self.main_node.level_factory.setup_level(tile_map, start_position)


# TODO: Clean this up
func setup_levels() -> void:
	for level_idx in self.level_start_points.size():
		setup_level(self.level_start_points.keys()[level_idx], self.level_start_points.values()[level_idx])


func _on_fully_entered() -> void:
	if self.current_level not in self.cleared_levels:
		await get_tree().create_timer(1).timeout
		self.main_node.spawn_doors()


# TODO: Clean this up
func _on_level_changed(level_name: String) -> void:
	self.current_level = level_name
	self.move_timer.stop()
	await get_tree().create_timer(1).timeout
	self.move_timer.start()

	if self.current_level == "Room00.tscn":
		await get_tree().create_timer(2).timeout
		self.main_node.spawn_doors()
		return

	if self.current_level not in self.cleared_levels:
		self.main_node.spawn_doors()
		await get_tree().create_timer(1).timeout
		self.main_node.spawn_and_place_object("Apple")


func _on_score_changed(score: int) -> void:
	self.current_level_score += 1
	if self.current_level_score >= self.level_score_thresholds[self.current_level] and current_level!= "Room00.tscn":
		end_level()
