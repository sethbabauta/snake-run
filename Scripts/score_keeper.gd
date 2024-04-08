extends Node

signal score_changed(new_score: int, changed_by: int)

var score: int = 0


func add_to_score(amount: int) -> void:
	score += amount
	score_changed.emit(score, amount)


func reset_score() -> void:
	var changed_by = 0 - score
	score = 0
	score_changed.emit(score, changed_by)


func set_score(new_score: int) -> void:
	var changed_by = new_score - score
	score = new_score
	score_changed.emit(score, changed_by)
