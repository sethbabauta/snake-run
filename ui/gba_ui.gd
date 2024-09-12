class_name GBAUI extends Control

signal menu_pressed

@export var main_node: Main
@export var powerup_container: MarginContainer
@export var snake_length_container: MarginContainer

var is_setup_complete: bool = false

func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.ate_poison.connect(_on_ate_poison)
	ScoreKeeper.score_changed.connect(_on_score_changed)
	is_setup_complete = true


func _process(_delta: float) -> void:
	if not is_setup_complete:
		return

	if main_node.powerup_1_timer.is_stopped():
		powerup_container.update_label(0)
	else:
		var time_left: int = ceili(main_node.powerup_1_timer.get_time_left())
		powerup_container.update_label(time_left)


func _on_ate_poison(_amount: int) -> void:
	_update_snake_length()


func _on_game_started(_gamemode_name: String) -> void:
	_update_snake_length()


func _on_score_changed(_new_score: int, _changed_by: int) -> void:
	_update_snake_length()


func _update_snake_length() -> void:
	var snake_length: int = await main_node.get_snake_length()
	snake_length_container.update_label(snake_length)


func _on_pause_dialog_menu_pressed() -> void:
	menu_pressed.emit()
