class_name PauseDialog extends PanelContainer

signal menu_pressed
signal settings_pressed
signal resume_pressed


func _on_settings_button_pressed() -> void:
	settings_pressed.emit()


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	menu_pressed.emit()


func _on_resume_button_pressed() -> void:
	resume_pressed.emit()
