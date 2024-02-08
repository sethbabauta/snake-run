class_name MainUI extends Control

@export var score_label: Label

func _ready() -> void:
	ScoreKeeper.SCORE_CHANGED.connect(_on_score_changed)
	score_label.text = "Score: %d" % ScoreKeeper.score


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
