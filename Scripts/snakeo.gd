class_name Snakeo extends Node

@export_file("*.tscn") var snakeo_death_screen
@export var main_node: Main

const START_LENGTH = 3
const DANGER_INTERVAL = 5
const POWERUP_1_INTERVAL = 6


func _ready() -> void:
	ScoreKeeper.SCORE_CHANGED.connect(_on_score_changed)

	self.main_node.spawn_background()
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	self.main_node.spawn_player_snake(start_position, self.START_LENGTH)
	self.main_node.spawn_start_barriers()

	await get_tree().create_timer(1).timeout
	self.main_node.spawn_and_place_object("Apple")

	await get_tree().create_timer(2).timeout

	var move_timer: Timer = get_node("MoveTimer")
	move_timer.start()


func end_game() -> void:
	get_tree().change_scene_to_file(snakeo_death_screen)


func _on_score_changed(score: int) -> void:
	if score % DANGER_INTERVAL == 0:
		self.main_node.spawn_and_place_object("SlightlyPoisonousApple")
	if score % POWERUP_1_INTERVAL == 0:
		self.main_node.spawn_and_place_object("TempAppleFlipper")
