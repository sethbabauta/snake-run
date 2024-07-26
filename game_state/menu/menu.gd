extends Control

@onready var start_classic: Button = %StartClassic
@onready var start_snake_o_mode: Button = %"StartSnake-oMode"
@onready var start_dungeon: Button = %StartDungeon


func _ready() -> void:
	_random_tests()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_test_env_pressed() -> void:
	pass


func _random_tests() -> void:
	pass
