class_name Menu extends Control

@export_file("*.tscn") var classic_scene
@export_file("*.tscn") var adventure_scene


func _on_start_classic_pressed() -> void:
	get_tree().change_scene_to_file(classic_scene)

	
func _on_start_adventure_pressed() -> void:
	get_tree().change_scene_to_file(adventure_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
