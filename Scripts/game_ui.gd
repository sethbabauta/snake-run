class_name GameUI extends Control

const POWERUP_1_TEXT: String = "Powerup: "

@export var main_node: Main

var is_settings_active: bool = false

@onready var pause_dialog: PauseDialog = %PauseDialog
@onready var settings_dialog: Control = %SettingsDialog
@onready var score_label: Label = %ScoreLabel
@onready var snake_length_label: Label = %SnakeLengthLabel
@onready var powerup_1_label: Label = %Powerup1Label


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.settings_toggled.connect(_on_settings_toggled)
	ScoreKeeper.score_changed.connect(_on_score_changed)
	snake_length_label.text = "Snake Length: " + str(main_node.gamemode_node.START_LENGTH)
	score_label.text = "Score: %d" % ScoreKeeper.score


func _process(_delta: float) -> void:
	if main_node.powerup_1_timer.is_stopped():
		powerup_1_label.text = POWERUP_1_TEXT + "OFF"
	else:
		var time_left = str(ceil(main_node.powerup_1_timer.get_time_left()))
		powerup_1_label.text = POWERUP_1_TEXT + time_left


func _on_game_paused(is_paused: bool) -> void:
	pause_dialog.visible = is_paused


func _on_game_started(gamemode_name: String) -> void:
	if gamemode_name == "Snakeo":
		powerup_1_label.visible = true


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

	var snake_length: int = await main_node.get_snake_length()
	snake_length_label.text = "Snake Length: " + str(snake_length)


func _on_settings_toggled() -> void:
	is_settings_active = not is_settings_active
	settings_dialog.visible = is_settings_active
