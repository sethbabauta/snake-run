class_name MainUI extends Control

@export var score_label: Label
@export var powerup_1_label: Label

var powerup_1_timer: Timer


func _ready() -> void:
	powerup_1_timer = get_node("../Powerup1Timer")

	ScoreKeeper.SCORE_CHANGED.connect(_on_score_changed)
	score_label.text = "Score: %d" % ScoreKeeper.score


func _physics_process(delta: float) -> void:
	if powerup_1_timer:
		var time_left = str(ceil(powerup_1_timer.get_time_left()))
		if powerup_1_timer.is_stopped():
			powerup_1_label.text = "Powerup 1: OFF"
		else:
			powerup_1_label.text = "Powerup 1: " + time_left


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
