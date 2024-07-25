class_name Menu extends Control


func _ready() -> void:
	_random_tests()


func _on_start_classic_pressed() -> void:
	EventBus.menu_state_change.emit(GameStateManager.classic)


func _on_start_snakeo_mode_pressed() -> void:
	EventBus.menu_state_change.emit(GameStateManager.snakeo)


func _on_start_dungeon_pressed() -> void:
	EventBus.menu_state_change.emit(GameStateManager.dungeon)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_test_env_pressed() -> void:
	pass


func _random_tests() -> void:
	pass
