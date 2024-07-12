class_name Menu extends Control

@export_file("*.tscn") var classic_scene
@export_file("*.tscn") var dungeon_scene
@export_file("*.tscn") var snakeo_scene
@export_file("*.tscn") var test_scene


func _ready() -> void:
	_random_tests()


func _on_start_classic_pressed() -> void:
	get_tree().change_scene_to_file(classic_scene)


func _on_start_dungeon_pressed() -> void:
	get_tree().change_scene_to_file(dungeon_scene)


func _on_start_snakeo_pressed() -> void:
	get_tree().change_scene_to_file(snakeo_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_test_env_pressed() -> void:
	get_tree().change_scene_to_file(test_scene)


func _random_tests() -> void:
	pass
