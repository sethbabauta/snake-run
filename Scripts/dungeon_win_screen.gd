class_name DungeonWinScreen extends Control

@export_file("*.tscn") var dungeon_scene
@export_file("*.tscn") var menu_scene

@onready var score_label: Label = %Score


func _ready() -> void:
	score_label.text = "Score: %d" % ScoreKeeper.score


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(dungeon_scene)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(menu_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
