extends GameState

var next_state: State
var menu: Control


func enter() -> void:
	menu = _change_scene(Settings.MENU_SCENE)
	menu.start_classic.pressed.connect(_on_classic_pressed)
	menu.start_snake_o_mode.pressed.connect(_on_snakeo_pressed)
	menu.start_dungeon.pressed.connect(_on_dungeon_pressed)


func _on_classic_pressed() -> void:
	_select_mode(game_state_manager.game_state_classic)


func _on_dungeon_pressed() -> void:
	_select_mode(game_state_manager.game_state_dungeon)


func _on_snakeo_pressed() -> void:
	_select_mode(game_state_manager.game_state_snakeo)


func _select_mode(new_state: State) -> void:
	next_state = new_state
	is_complete = true
