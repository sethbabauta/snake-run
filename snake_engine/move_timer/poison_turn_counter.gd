class_name PoisonTurnCounter extends TurnCounter


func try_notify(
	snake_game_object: GameEngine.GameObject,
	value: int,
	game_announcer: GameAnnouncer,
	_is_poison: bool = false
) -> void:
	super(snake_game_object, value, game_announcer, true)


func _create_display_value(value: int) -> String:
	var display_value: String = "- " + str(value)
	if notified_counter < SIMPLIFY_COUNT:
		display_value += " segment"

		if value > 1:
			display_value += "s"

	return display_value
