class_name Snakeo extends Node

const START_LENGTH = 3
const DANGER_INTERVAL = 1
const POWERUP_1_INTERVAL = 30

@export var snakeo_death_screen: PackedScene

var powerup_1_on: bool = false
var temp_apple_flipper_spawner: ScoreCheckpointSpawner

@onready var game_ui: GameUI = %GameUI
@onready var main_node: Main = %Main


func _ready() -> void:
	ScoreKeeper.score_changed.connect(_on_score_changed)
	EventBus.powerup_1_activated.connect(_on_powerup_1_activate)
	EventBus.ate_item.connect(_on_ate_item)

	temp_apple_flipper_spawner = (
		ScoreCheckpointSpawner
		. new(
			POWERUP_1_INTERVAL,
			POWERUP_1_INTERVAL,
			"TempAppleFlipper",
			main_node,
		)
	)

	main_node.spawn_background()
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, START_LENGTH)
	main_node.spawn_start_barriers()

	await get_tree().create_timer(1).timeout
	main_node.spawn_and_place_object("Apple")
	main_node.spawn_and_place_object("TempAppleFlipper")
	await get_tree().create_timer(2).timeout

	EventBus.game_started.emit("Snakeo")


func end_game() -> void:
	get_tree().change_scene_to_packed(snakeo_death_screen)


func _on_ate_item(item_name: String, eater: String) -> void:
	if eater != "PlayerSnakeHead":
		return

	if item_name == "Apple":
		main_node.spawn_and_place_object("SlightlyPoisonousApple")
	if item_name == "AppleNoRespawn":
		pass
	if item_name == "SlightlyPoisonousApple":
		pass
	if item_name == "TempAppleFlipper":
		ScoreKeeper.add_to_score(10)


func _on_score_changed(new_score: int) -> void:
	temp_apple_flipper_spawner.check_score(new_score)


func _on_powerup_1_activate(flip_seconds: int) -> void:
	if main_node.powerup_1_timer.is_stopped():
		main_node.flip_apples()

	main_node.powerup_1_timer.start(flip_seconds)
	await main_node.powerup_1_timer.timeout

	main_node.flip_apples_back()


class ScoreCheckpointSpawner:
	var checkpoint_interval: int
	var checkpoint: int
	var item_to_spawn: String
	var main_node: Main

	func _init(
		p_checkpoint_interval: int,
		p_checkpoint: int,
		p_item_to_spawn: String,
		p_main_node: Main,
	) -> void:
		checkpoint_interval = p_checkpoint_interval
		checkpoint = p_checkpoint
		item_to_spawn = p_item_to_spawn
		main_node = p_main_node

	func check_score(score: int) -> void:
		while not score < checkpoint:
			main_node.spawn_and_place_object(item_to_spawn)
			checkpoint += checkpoint_interval
