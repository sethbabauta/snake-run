class_name Menu extends Control

@export var classic_node: PackedScene


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(classic_node)
