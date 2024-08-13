class_name Dungeon extends Node

const CROWN_POISON_RATE = 20
const START_LENGTH = 3

@export var dungeon_death_screen: PackedScene
@export var dungeon_win_screen: PackedScene

var current_room: Room
var current_room_neighbors: RoomMapper.RoomNeighbors
var loaded_rooms: Array[Room]
var crown_poison_counter: CrownPoisonCounter
var crown_collected: bool = false
var crown_collected_count: int = 0

@onready var follow_camera: FollowCamera = %FollowCamera
@onready var main_node: Main = %Main
@onready var room_mapper: RoomMapper = %room_mapper
@onready var game_announcer: GameAnnouncer = %GameAnnouncer


func _ready() -> void:
	EventBus.crown_collected.connect(_on_crown_pickup)
	EventBus.crown_dropped.connect(_on_crown_dropped)
	EventBus.player_fully_entered.connect(_on_player_fully_entered)
	EventBus.player_moved.connect(_on_player_moved)
	ScoreKeeper.score_changed.connect(_on_score_changed)


func get_current_room_exclusions() -> Array[String]:
	var exclusions: Array[String] = []

	if not current_room_neighbors.up:
		exclusions.append("N")
	if not current_room_neighbors.down:
		exclusions.append("S")
	if not current_room_neighbors.left:
		exclusions.append("W")
	if not current_room_neighbors.right:
		exclusions.append("E")

	if current_room:
		var walled_off_directions: Array[String] = current_room.walled_off_directions.duplicate()
		exclusions = exclusions + walled_off_directions

	return exclusions


func level_change_pause(_args: Dictionary) -> void:
	game_announcer.announce_message("3 2 1 GO")
	await EventBus.announcement_completed
	EventBus.scripted_event_completed.emit()


func load_room(room: Room) -> void:
	var room_tile_map: RoomTileMap = room.tile_map.instantiate()
	room_mapper.add_child(room_tile_map)
	room_tile_map.visible = false
	var position_offset:= Vector2(room.layout_x * 20, room.layout_y * -20)
	main_node.level_factory.setup_level(room_tile_map.room_tile_map, position_offset)
	loaded_rooms.append(room)


func spawn_doors_and_apple() -> void:
	var exclusions: Array[String] = get_current_room_exclusions()
	main_node.spawn_doors(exclusions)
	await get_tree().create_timer(1).timeout
	main_node.queue_object_to_spawn("Apple")


func update_rooms(direction: String) -> void:
	if direction == "ERROR":
		return

	match direction:
		"N":
			current_room = current_room_neighbors.up
		"S":
			current_room = current_room_neighbors.down
		"E":
			current_room = current_room_neighbors.right
		"W":
			current_room = current_room_neighbors.left

	if not current_room:
		return

	current_room_neighbors = room_mapper.get_room_neighbors(current_room)
	_load_room_neighbors()

	if direction != "Start":
		main_node.play_scripted_event(level_change_pause)


func _crown_scripted_event(_args: Dictionary) -> void:
	main_node.audio_library.play_sound("earthquake")
	follow_camera.shake_with_noise()
	await EventBus.shake_completed
	game_announcer.announce_message("ESCAPE WITH YOUR LIFE")
	await EventBus.announcement_completed
	EventBus.scripted_event_completed.emit()


func _load_room_neighbors() -> void:
	if (
		current_room_neighbors.left not in loaded_rooms
		and current_room_neighbors.left
	):
		load_room(current_room_neighbors.left)
	if (
		current_room_neighbors.right not in loaded_rooms
		and current_room_neighbors.right
	):
		load_room(current_room_neighbors.right)
	if (
		current_room_neighbors.up not in loaded_rooms
		and current_room_neighbors.up
	):
		load_room(current_room_neighbors.up)
	if (
		current_room_neighbors.down not in loaded_rooms
		and current_room_neighbors.down
	):
		load_room(current_room_neighbors.down)


func _on_crown_dropped() -> void:
	crown_collected = false


func _on_crown_pickup() -> void:
	crown_collected = true
	crown_collected_count += 1
	if crown_collected_count == 1:
		main_node.play_scripted_event(_crown_scripted_event)


func _on_player_moved() -> void:
	if crown_collected:
		crown_poison_counter.increment_counter()


func _on_score_changed(_new_score: int, changed_by: int) -> void:
	current_room.current_room_score += changed_by
	if current_room.get_is_room_complete():
		EventBus.level_completed.emit()


func _on_player_fully_entered() -> void:
	if not current_room:
		return

	if not current_room.get_is_room_complete():
		await EventBus.player_moved
		var exclusions: Array[String] = get_current_room_exclusions()
		main_node.spawn_doors(exclusions)

		# workaround for edge case where player clears lvl then fully enters
		await get_tree().create_timer(5).timeout
		if current_room.get_is_room_complete():
			main_node.clear_doors(exclusions)


class CrownPoisonCounter:
	var poison_interval: int = CROWN_POISON_RATE
	var current_interval: int = 0
	var main_node: Main

	func _init(p_main_node: Main) -> void:
		main_node = p_main_node

	func increment_counter(amount: int = 1) -> void:
		current_interval += amount
		if current_interval >= poison_interval:
			current_interval = 0
			var new_event := GameEngine.Event.new(
				"IngestPoison",
				{"poison_level": 1},
			)
			main_node.game_object_factory.notify_subscribers(new_event, "player_controlled")
