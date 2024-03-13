class_name MainUI extends Control

@export var score_label: Label
@export var snake_length_label: Label
@export var powerup_1_label: Label

var powerup_1_timer: Timer
var powerup_1_text: String = "Powerup: "
var main_node: Main


func _ready() -> void:
	main_node = get_node("../Main")
	powerup_1_timer = get_node_or_null("../Powerup1Timer")

	ScoreKeeper.SCORE_CHANGED.connect(_on_score_changed)
	snake_length_label.text = "Snake Length: " + str(main_node.gamemode_node.START_LENGTH)
	score_label.text = "Score: %d" % ScoreKeeper.score



func _physics_process(_delta: float) -> void:
	if powerup_1_timer:
		var time_left = str(ceil(powerup_1_timer.get_time_left()))
		if powerup_1_timer.is_stopped():
			powerup_1_label.text = powerup_1_text + "OFF"
		else:
			powerup_1_label.text = powerup_1_text + time_left


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

	var snake_length: int = await main_node.get_snake_length()
	snake_length_label.text = "Snake Length: " + str(snake_length)
