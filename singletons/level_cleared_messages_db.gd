extends Node

var level_cleared_messages: Array[String] = []


func _ready() -> void:
	_load_messages()


func get_random_message() -> String:
	var index: int = Utils.roll(1, level_cleared_messages.size()) - 1
	var message: String = level_cleared_messages[index]

	return message


func _load_messages() -> void:
	var file:= FileAccess.open(
		Settings.LEVEL_CLEARED_MESSAGES_PATH,
		FileAccess.READ,
	)
	while file.get_position() < file.get_length():
		var next_message: String = file.get_line()

		level_cleared_messages.append(next_message)
