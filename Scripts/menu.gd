class_name Menu extends Control

@export var classic_scene: PackedScene


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(classic_scene)
