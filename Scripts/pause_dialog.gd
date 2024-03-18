class_name PauseDialog extends PanelContainer

@export_file("*.tscn") var main_menu_scene
@export_file("*.tscn") var settings_scene
var main_node: Main


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file(settings_scene)


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
