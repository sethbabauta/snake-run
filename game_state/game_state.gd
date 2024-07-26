class_name GameState extends State

var game_state_manager: Node


func exit() -> void:
	_clear_current_scene()


func _change_scene(scene_path: String) -> Node:
	_clear_current_scene()
	var new_scene: Node = load(scene_path).instantiate()
	add_child(new_scene)

	return new_scene


func _clear_current_scene() -> void:
	for child in get_children():
		child.free()
