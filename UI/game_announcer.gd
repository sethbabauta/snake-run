class_name GameAnnouncer extends Control

const SHRINK_RATE = 5.0
const INITIAL_OFFSET_AMOUNT = 125.0
const BASE_FONT_SIZE = 75.0

var font_offset: float = 0.0
var is_game_paused: bool = false

@onready var announcement: Label = %Announcement
@onready var dungeon_arrow_north: DungeonArrow = %DungeonArrowNorth
@onready var dungeon_arrow_east: DungeonArrow = %DungeonArrowEast
@onready var dungeon_arrow_south: DungeonArrow = %DungeonArrowSouth
@onready var dungeon_arrow_west: DungeonArrow = %DungeonArrowWest


func _init() -> void:
	EventBus.game_paused.connect(_on_pause)


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
	var arrows_to_play: Array[String] = ["N", "E", "S", "W"]
	arrows_to_play = Utils.array_subtract(arrows_to_play, exclusions)

	var current_arrow: DungeonArrow
	for direction in arrows_to_play:
		await _check_if_game_is_paused()
		current_arrow = _announce_arrow(direction)
		await get_tree().create_timer(0.2).timeout

	if current_arrow:
		await current_arrow.animation_player.animation_finished

	await _check_if_game_is_paused()


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


func hide_arrows() -> void:
	dungeon_arrow_north.visible = false
	dungeon_arrow_east.visible = false
	dungeon_arrow_south.visible = false
	dungeon_arrow_west.visible = false


func _announce_arrow(direction: String) -> DungeonArrow:
	var announcing_arrow: DungeonArrow
	match direction:
		"N":
			announcing_arrow = dungeon_arrow_north
		"E":
			announcing_arrow = dungeon_arrow_east
		"S":
			announcing_arrow = dungeon_arrow_south
		"W":
			announcing_arrow = dungeon_arrow_west

	announcing_arrow.play_arrow_animation()

	return announcing_arrow


func _announce_word(word: String, time_between_words: float) -> void:
	announcement.text = word
	await get_tree().create_timer(time_between_words).timeout
	await _check_if_game_is_paused()


func _check_if_game_is_paused() -> void:
	if is_game_paused:
		await EventBus.game_paused


func _on_pause(is_paused: bool) -> void:
	is_game_paused = is_paused
