extends MarginContainer

@export var number_label: Label


func _ready() -> void:
	ScoreKeeper.score_changed.connect(_on_score_changed)


func _on_score_changed(new_score: int, _changed_by: int) -> void:
	number_label.text = str(new_score)
