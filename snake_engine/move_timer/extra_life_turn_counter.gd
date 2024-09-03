class_name ExtraLifeTurnCounter extends TurnCounter


func _create_display_value(value: int) -> String:
	var display_value: String = "+ " + str(value)
	if notified_counter < SIMPLIFY_COUNT:
		display_value += " extra li"

		if value > 1:
			display_value += "ves"
		else:
			display_value += "fe"

	return display_value
