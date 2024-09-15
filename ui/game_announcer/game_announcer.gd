class_name GameAnnouncer extends Control

const SHRINK_RATE = 5.0
const INITIAL_OFFSET_AMOUNT = 125.0
const BASE_FONT_SIZE = 75.0

var font_offset: float = 0.0
var is_game_paused: bool = false
var announcement_id_factory:= IDFactory.new("game_announcer")

@onready var announcement_label: Label = %Announcement
@onready var dungeon_arrow_north: DungeonArrow = %DungeonArrowNorth
@onready var dungeon_arrow_east: DungeonArrow = %DungeonArrowEast
@onready var dungeon_arrow_south: DungeonArrow = %DungeonArrowSouth
@onready var dungeon_arrow_west: DungeonArrow = %DungeonArrowWest
@onready var monologue: Control = %Monologue
@onready var item_effect_number: Control = %ItemEffectNumber


func _init() -> void:
	EventBus.game_paused.connect(_on_pause)


func _process(delta: float) -> void:
	if font_offset <= 0:
		return

	font_offset = Utils.decay_to_zero(font_offset, 0.0, SHRINK_RATE * delta, 10)
	font_offset = snapped(font_offset, 1)

	announcement_label.set(
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
	var announcement: IDCounter = announcement_id_factory.create_new_id()

	var announce_split_array: PackedStringArray = announce_text.split(" ")
	for word in announce_split_array:
		# if a new announcement starts then stop current one
		if not announcement_id_factory.is_id_current(announcement):
			break

		font_offset = INITIAL_OFFSET_AMOUNT
		await _announce_word(word, time_between_words)

	announcement_label.text = ""
	EventBus.announcement_completed.emit()


func display_number(
	value: String,
	affected_body: Area2D,
	is_damage: bool = false,
	extra_hang_time: float = 0.0,
) -> void:
	item_effect_number.display_number(
		value,
		affected_body,
		is_damage,
		extra_hang_time,
	)


func hide_arrows() -> void:
	dungeon_arrow_north.visible = false
	dungeon_arrow_east.visible = false
	dungeon_arrow_south.visible = false
	dungeon_arrow_west.visible = false


func start_monologue(monologuer: Area2D, speech: String) -> void:
	monologue.start_monologue(monologuer, speech)


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
	announcement_label.text = word
	await get_tree().create_timer(time_between_words).timeout
	await _check_if_game_is_paused()


func _check_if_game_is_paused() -> void:
	if is_game_paused:
		await EventBus.game_paused


func _on_pause(is_paused: bool) -> void:
	is_game_paused = is_paused
