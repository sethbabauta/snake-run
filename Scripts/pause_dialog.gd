class_name PauseDialog extends PanelContainer

@export var main_menu_scene: PackedScene


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_settings_button_pressed() -> void:
	EventBus.settings_toggled.emit()


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
