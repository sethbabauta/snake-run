class_name GameStateMenu extends GameState

var next_state: State


func _init(p_game_state_manager) -> void:
	super(p_game_state_manager)
	EventBus.menu_state_change.connect(_on_mode_selected)


func enter() -> void:
	game_state_manager.get_tree().change_scene_to_file(Settings.MENU_SCENE)


func _on_mode_selected(new_state: State) -> void:
	next_state = new_state
	is_complete = true
