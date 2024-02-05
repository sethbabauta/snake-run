class_name AdventureDeathScreen extends Control

@export_file("*.tscn") var adventure_scene
@export_file("*.tscn") var menu_scene


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(adventure_scene)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(menu_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
