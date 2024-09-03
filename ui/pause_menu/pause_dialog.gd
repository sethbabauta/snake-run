class_name PauseDialog extends PanelContainer

@export var main_menu_button: Button


func _on_settings_button_pressed() -> void:
	EventBus.settings_toggled.emit()


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
