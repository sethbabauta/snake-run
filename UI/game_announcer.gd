class_name GameAnnouncer extends Control

const SHRINK_RATE = 5.0
const INITIAL_OFFSET_AMOUNT = 125.0
const BASE_FONT_SIZE = 75.0

var font_offset: float = 0.0

@onready var announcement: Label = %Announcement
@onready var dungeon_arrow_north: DungeonArrow = %DungeonArrowNorth
@onready var dungeon_arrow_east: DungeonArrow = %DungeonArrowEast
@onready var dungeon_arrow_south: DungeonArrow = %DungeonArrowSouth
@onready var dungeon_arrow_west: DungeonArrow = %DungeonArrowWest


func _process(delta: float) -> void:
	if font_offset <= 0:
		return

	font_offset = Utils.decay_to_zero(font_offset, 0.0, SHRINK_RATE * delta, 10)
	font_offset = snapped(font_offset, 1)

	announcement.set(
		"theme_override_font_sizes/font_size",
		BASE_FONT_SIZE + font_offset,
	)


func announce_arrows(exclusions: Array[String] = []) -> void:
	EventBus.pause_requested.emit()
	var arrows_to_play: Array[String] = ["N", "E", "S", "W"]
	arrows_to_play = Utils.array_subtract(arrows_to_play, exclusions)

	for direction in arrows_to_play:
		_announce_arrow(direction)
		await get_tree().create_timer(0.2).timeout

	EventBus.pause_requested.emit()


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


func _announce_arrow(direction: String) -> void:
	match direction:
		"N":
			dungeon_arrow_north.play_arrow_animation()
		"E":
			dungeon_arrow_east.play_arrow_animation()
		"S":
			dungeon_arrow_south.play_arrow_animation()
		"W":
			dungeon_arrow_west.play_arrow_animation()


func _announce_word(word: String, time_between_words: float) -> void:
	announcement.text = word
	await get_tree().create_timer(time_between_words).timeout

