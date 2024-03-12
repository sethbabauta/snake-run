class_name Snakeo extends Node

signal GAME_START

@export_file("*.tscn") var snakeo_death_screen
@export var main_node: Main
@export var powerup_1_timer: Timer

const START_LENGTH = 3
const DANGER_INTERVAL = 2
const POWERUP_1_INTERVAL = 30

var powerup_1_on: bool = false
var game_ui: MainUI


func _ready() -> void:
	ScoreKeeper.SCORE_CHANGED.connect(_on_score_changed)
	main_node.POWERUP_1_ACTIVATE.connect(_on_powerup_1_activate)

	game_ui = get_node("GameUI")
	game_ui.powerup_1_label.visible = true
	powerup_1_timer = get_node("Powerup1Timer")

	self.main_node.spawn_background()
	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	self.main_node.spawn_player_snake(start_position, self.START_LENGTH)
	self.main_node.spawn_start_barriers()

	await get_tree().create_timer(1).timeout
	self.main_node.spawn_and_place_object("Apple")

	await get_tree().create_timer(2).timeout

	var move_timer: Timer = get_node("MoveTimer")
	move_timer.start()
	GAME_START.emit()


func end_game() -> void:
	get_tree().change_scene_to_file(snakeo_death_screen)


func _on_score_changed(score: int) -> void:
	if not powerup_1_timer.is_stopped():
		return
	if score == 0:
		return

	if score % DANGER_INTERVAL == 0:
		self.main_node.spawn_and_place_object("SlightlyPoisonousApple")
	if score % POWERUP_1_INTERVAL == 0:
		self.main_node.spawn_and_place_object("TempAppleFlipper")


func _on_powerup_1_activate(flip_seconds: int) -> void:
	ScoreKeeper.add_to_score(10)
	if powerup_1_timer.is_stopped():
		main_node.flip_apples()

	powerup_1_timer.start(flip_seconds)
	await powerup_1_timer.timeout

	main_node.flip_apples_back()

	await get_tree().create_timer(1).timeout
	var apples: Array = main_node.get_game_objects_of_name("Apple")
	if not apples:
		main_node.spawn_and_place_object("Apple")
