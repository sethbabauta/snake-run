extends Node


func change_scene(scene_path: String) -> void:
	_clear_current_scene()
	var new_scene: Node = load(scene_path).instantiate()
	add_child(new_scene)


func _clear_current_scene() -> void:
	for child in get_children():
		child.free()
