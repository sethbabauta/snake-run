extends Control

@export var score_label: Label
@export var play_again: Button
@export var menu: Button


func _ready() -> void:
	score_label.text = "Score: %d" % ScoreKeeper.score


func _on_quit_pressed() -> void:
	get_tree().quit()
