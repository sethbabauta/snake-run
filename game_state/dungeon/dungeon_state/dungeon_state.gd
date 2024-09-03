class_name DungeonState extends State

var dungeon_state_manager: GameState
var next_state: State
var dungeon: Dungeon


func _is_correct_state() -> bool:
	var is_correct_state: bool = (
		dungeon_state_manager.dungeon_state_machine.state == self
	)
	return is_correct_state


func _on_dungeon_state_set() -> void:
	pass


func _select_mode(new_state: State) -> void:
	next_state = new_state
	is_complete = true
