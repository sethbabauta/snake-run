extends Node

signal SCORE_CHANGED

var score: int = 0


func add_to_score(amount: int) -> void:
	score += amount
	SCORE_CHANGED.emit(score)


func reset_score() -> void:
	score = 0
	SCORE_CHANGED.emit(score)


func set_score(new_score: int) -> void:
	score = new_score
	SCORE_CHANGED.emit(score)
