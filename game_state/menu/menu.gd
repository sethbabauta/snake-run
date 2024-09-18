extends Control

@export var start_classic: Button
@export var start_snake_o_mode: Button
@export var start_dungeon: Button
@export var settings_button: Button


func _ready() -> void:
	_random_tests()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_test_env_pressed() -> void:
	pass


func _random_tests() -> void:
	pass
