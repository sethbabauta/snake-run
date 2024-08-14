class_name GameState extends State

var game_state_manager: Node
var next_state: State

@onready var states: Node = $States
@onready var current_scene: Node = $CurrentScene


func exit() -> void:
	_clear_current_scene()


func _change_scene(scene_path: String) -> Node:
	if game_state_manager.state_machine.state != self:
		return

	_clear_current_scene()
	var new_scene: Node = load(scene_path).instantiate()
	current_scene.add_child(new_scene)

	return new_scene


func _clear_current_scene() -> void:
	for child in current_scene.get_children():
		current_scene.remove_child(child)
		child.queue_free()


func _select_mode(new_state: State) -> void:
	next_state = new_state
	is_complete = true
