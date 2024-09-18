extends Label


func _ready() -> void:
	text = DeathMessagesDb.get_random_message()
