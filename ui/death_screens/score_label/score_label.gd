extends Label


func _ready() -> void:
	text = "Score: %d" % ScoreKeeper.score
