class_name ScoreTurnCounter extends TurnCounter


func _create_display_value(value: int) -> String:
	var display_value: String
	var value_as_string: String = str(value)
	if notified_counter < SIMPLIFY_COUNT:
		display_value = "+ %s score + %s segment" % [
			value_as_string,
			value_as_string,
		]
		if value > 1:
			display_value += "s"
	else:
		display_value = "+ %s" % [value_as_string]


	return display_value
