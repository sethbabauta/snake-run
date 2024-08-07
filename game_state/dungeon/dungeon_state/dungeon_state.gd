class_name DungeonState extends State

var dungeon_state_manager: GameState
var next_state: State
var dungeon: Dungeon


func _select_mode(new_state: State) -> void:
	next_state = new_state
	is_complete = true
