class_name DeathScreen extends Control

@export var score_label: Label
@export var play_again: Button
@export var menu: Button
@export var dev_high_score_label: Label


func set_dev_high_score(score: int) -> void:
	dev_high_score_label.text = "Dev high score: %d" % score


func _on_quit_pressed() -> void:
	get_tree().quit()
