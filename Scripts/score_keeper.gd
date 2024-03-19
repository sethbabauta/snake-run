extends Node

signal score_changed

var score: int = 0


func add_to_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func reset_score() -> void:
	score = 0
	score_changed.emit(score)


func set_score(new_score: int) -> void:
	score = new_score
	score_changed.emit(score)
