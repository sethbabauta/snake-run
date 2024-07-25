extends GameState

var next_state: State


func _init() -> void:
	EventBus.menu_state_change.connect(_on_mode_selected)


func enter() -> void:
	game_state_manager.scene_change_requested.emit(Settings.MENU_SCENE)


func _on_mode_selected(new_state: State) -> void:
	next_state = new_state
	is_complete = true
