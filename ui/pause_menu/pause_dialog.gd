class_name PauseDialog extends PanelContainer

signal menu_pressed


func _ready() -> void:
	EventBus.game_paused.connect(_on_game_paused)


func _on_game_paused(is_paused: bool) -> void:
	visible = is_paused


func _on_settings_button_pressed() -> void:
	EventBus.settings_toggled.emit()


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	menu_pressed.emit()
