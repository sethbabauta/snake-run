class_name GameAnnouncer extends Control

@export var time_between_words: float = 0.5

@onready var announcement: Label = %Announcement


func announce_message(announce_text: String) -> void:
	var announce_split_array: PackedStringArray = announce_text.split(" ")
	for word in announce_split_array:
		await _announce_word(word)

	announcement.text = ""
	EventBus.announcement_completed.emit()


func _announce_word(word: String) -> void:
	announcement.text = word
	await get_tree().create_timer(time_between_words).timeout

