class_name GBAUI extends Control

signal menu_pressed

@export var main_node: Main
@export var powerup_container: MarginContainer
@export var snake_length_container: MarginContainer
@export var pause_dialog: PauseDialog
@export var settings_dialog: SettingsDialog

# states
@export var unpaused: UIState
@export var pause_menu: UIState
@export var settings_menu: UIState

var state_machine:= StateMachine.new()
var is_setup_complete: bool = false


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.ate_poison.connect(_on_ate_poison)
	EventBus.game_paused.connect(_on_game_paused)
	ScoreKeeper.score_changed.connect(_on_score_changed)
	set_state(unpaused)
	is_setup_complete = true


func _process(_delta: float) -> void:
	if not is_setup_complete:
		return

	if main_node.powerup_1_timer.is_stopped():
		powerup_container.update_label(0)
	else:
		var time_left: int = ceili(main_node.powerup_1_timer.get_time_left())
		powerup_container.update_label(time_left)


func _unhandled_input(event: InputEvent) -> void:
	if state_machine.state != settings_menu:
		return

	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		set_state(pause_menu)


func hide_all() -> void:
	pause_dialog.visible = false
	settings_dialog.visible = false


func set_state(new_state: UIState) -> void:
	hide_all()
	state_machine.set_state(new_state)


func _on_ate_poison(_amount: int) -> void:
	_update_snake_length()


func _on_game_started(_gamemode_name: String) -> void:
	_update_snake_length()


func _on_score_changed(_new_score: int, _changed_by: int) -> void:
	_update_snake_length()


func _update_snake_length() -> void:
	var snake_length: int = await main_node.get_snake_length()
	snake_length_container.update_label(snake_length)


func _on_game_paused(_is_paused: bool) -> void:
	match state_machine.state:
		pause_menu:
			set_state(unpaused)
		unpaused:
			set_state(pause_menu)


func _on_pause_dialog_menu_pressed() -> void:
	menu_pressed.emit()


func _on_pause_dialog_resume_pressed() -> void:
	EventBus.pause_requested.emit()
	set_state(unpaused)


func _on_pause_dialog_settings_pressed() -> void:
	set_state(settings_menu)


func _on_settings_dialog_back_pressed() -> void:
	set_state(pause_menu)
