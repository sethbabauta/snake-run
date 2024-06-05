class_name Snakeo extends Node

const START_LENGTH = 3
const POWERUP_1_INTERVAL = 30

@export var snakeo_death_screen: PackedScene

var temp_apple_flipper_spawner: ScoreCheckpointSpawner

@onready var main_node: Main = %Main
@onready var game_announcer: GameAnnouncer = %GameAnnouncer


func _ready() -> void:
	ScoreKeeper.score_changed.connect(_on_score_changed)
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

	game_announcer.announce_message("3 2 1 GO!", 1.05)
	await get_tree().create_timer(1).timeout
	main_node.queue_object_to_spawn("Apple")
	await get_tree().create_timer(2).timeout

	EventBus.game_started.emit("Snakeo")


func end_game(won: bool = false) -> void:
	if not won:
		get_tree().change_scene_to_packed(snakeo_death_screen)
		return


func _on_ate_item(item_name: String, eater: String) -> void:
	if eater != "PlayerSnakeHead":
		return

	if item_name == "Apple":
		main_node.queue_object_to_spawn("SlightlyPoisonousApple")
	if item_name == "TempAppleFlipper":
		ScoreKeeper.add_to_score(10)


func _on_score_changed(new_score: int, _changed_by: int) -> void:
	temp_apple_flipper_spawner.check_score(new_score)


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
			main_node.queue_object_to_spawn(item_to_spawn)
			checkpoint += checkpoint_interval
