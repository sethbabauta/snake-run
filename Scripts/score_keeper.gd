extends Node

signal SCORE_CHANGED

var score: int = 0


func add_to_score(amount: int) -> void:
	self.score += amount
	SCORE_CHANGED.emit(self.score)


func reset_score() -> void:
	self.score = 0
	SCORE_CHANGED.emit(self.score)
	
	
func set_score(score: int) -> void:
	self.score = score
	SCORE_CHANGED.emit(self.score)
