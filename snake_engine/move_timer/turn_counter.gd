class_name TurnCounter extends RefCounted

var timer_signal: Signal
var notified_this_turn: bool = false
var notified_counter: int = 0

const SIMPLIFY_COUNT = 3


func _init(p_timer_signal: Signal) -> void:
	timer_signal = p_timer_signal
	timer_signal.connect(_on_timer_timeout)


func try_notify(
	snake_game_object: GameEngine.GameObject,
	value: int,
	game_announcer: GameAnnouncer,
	is_poison: bool = false
) -> void:
	if notified_this_turn:
		return

	var display_value: String = _create_display_value(value)


	game_announcer.display_number(
		display_value,
		snake_game_object.physics_body,
		is_poison,
	)
	notified_this_turn = true
	notified_counter += 1


func _create_display_value(value: int) -> String:
	var display_value: String = str(value)
	return display_value


func _on_timer_timeout() -> void:
	notified_this_turn = false
