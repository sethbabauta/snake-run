class_name GameAnnouncer extends Control

const SHRINK_RATE = 5.0
const INITIAL_OFFSET_AMOUNT = 125.0
const BASE_FONT_SIZE = 75.0

var font_offset: float = 0.0

@onready var announcement: Label = %Announcement


func _process(delta: float) -> void:
	if font_offset <= 0:
		return

	font_offset = Utils.decay_to_zero(font_offset, 0.0, SHRINK_RATE * delta, 10)
	font_offset = snapped(font_offset, 1)

	announcement.set(
		"theme_override_font_sizes/font_size",
		BASE_FONT_SIZE + font_offset,
	)


func announce_arrows() -> void:
	pass


func announce_message(
	announce_text: String,
	time_between_words: float = 0.5,
) -> void:
	var announce_split_array: PackedStringArray = announce_text.split(" ")
	for word in announce_split_array:
		font_offset = INITIAL_OFFSET_AMOUNT
		await _announce_word(word, time_between_words)

	announcement.text = ""
	EventBus.announcement_completed.emit()


func _announce_word(word: String, time_between_words: float) -> void:
	announcement.text = word
	await get_tree().create_timer(time_between_words).timeout

