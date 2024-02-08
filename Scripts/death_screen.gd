class_name ClassicDeathScreen extends Control

@export_file("*.tscn") var classic_scene
@export_file("*.tscn") var menu_scene
@export var score_label: Label


func _ready() -> void:
	score_label.text = "Score: %d" % ScoreKeeper.score


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(classic_scene)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(menu_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
