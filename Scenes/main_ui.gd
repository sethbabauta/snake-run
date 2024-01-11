class_name MainUI extends Control

@export var score_label: Label

func _on_main_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
