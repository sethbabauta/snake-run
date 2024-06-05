class_name Dungeon extends Node

const START_LENGTH = 3

@export var dungeon_death_screen: PackedScene
@export var dungeon_win_screen: PackedScene

var current_room: Room
var current_room_neighbors: RoomMapper.RoomNeighbors
var loaded_rooms: Array[Room]

@onready var follow_camera: FollowCamera = %FollowCamera
@onready var main_node: Main = %Main
@onready var room_mapper: RoomMapper = %room_mapper
@onready var game_announcer: GameAnnouncer = %GameAnnouncer


func _ready() -> void:
	ScoreKeeper.score_changed.connect(_on_score_changed)
	EventBus.level_changed.connect(_on_level_changed)
	EventBus.crown_collected.connect(_on_crown_pickup)

	_setup_initial_room()
	EventBus.level_changed.emit("Start")

	var start_position: Vector2 = Utils.convert_simple_to_world_coordinates(Vector2(9, 9))
	main_node.spawn_player_snake(start_position, START_LENGTH)
	main_node.queue_object_to_spawn(
		"DungeonExit",
		Utils.convert_simple_to_world_coordinates(Vector2(9, 6)),
	)

	#game_announcer.announce_message("3 2 1 GO!", 1.05)
	await get_tree().create_timer(2).timeout

	EventBus.game_started.emit("Dungeon")


func end_game(won: bool = false) -> void:
	if not won:
		get_tree().change_scene_to_packed(dungeon_death_screen)
		return

	get_tree().change_scene_to_packed(dungeon_win_screen)


func end_level() -> void:
	var exclusions: Array[String] = get_current_room_exclusions()
	main_node.clear_doors(exclusions)
	await get_tree().create_timer(0.1).timeout
	main_node.clear_pickups()


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

	return exclusions


func _crown_scripted_event(_args: Dictionary) -> void:
	main_node.audio_library.play_sound("earthquake")
	follow_camera.shake_with_noise()
	await EventBus.shake_completed
	game_announcer.announce_message("ESCAPE WITH YOUR LIFE")
	await EventBus.announcement_completed
	EventBus.scripted_event_completed.emit()


func _level_change_pause(_args: Dictionary) -> void:
	game_announcer.announce_message("3 2 1 GO")
	await get_tree().create_timer(2).timeout
	EventBus.scripted_event_completed.emit()


func _load_room(room: Room) -> void:
	var room_tile_map: RoomTileMap = room.tile_map.instantiate()
	room_mapper.add_child(room_tile_map)
	room_tile_map.visible = false
	var position_offset:= Vector2(room.layout_x * 20, room.layout_y * -20)
	main_node.level_factory.setup_level(room_tile_map.room_tile_map, position_offset)
	loaded_rooms.append(room)


func _load_room_neighbors() -> void:
	if (
		current_room_neighbors.left not in loaded_rooms
		and current_room_neighbors.left
	):
		_load_room(current_room_neighbors.left)
	if (
		current_room_neighbors.right not in loaded_rooms
		and current_room_neighbors.right
	):
		_load_room(current_room_neighbors.right)
	if (
		current_room_neighbors.up not in loaded_rooms
		and current_room_neighbors.up
	):
		_load_room(current_room_neighbors.up)
	if (
		current_room_neighbors.down not in loaded_rooms
		and current_room_neighbors.down
	):
		_load_room(current_room_neighbors.down)


func _on_crown_pickup() -> void:
	main_node.play_scripted_event(_crown_scripted_event)


func _on_level_changed(direction: String) -> void:
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


	main_node.play_scripted_event(_level_change_pause)
	if not current_room.get_is_room_complete():
		main_node.spawn_doors()
		await get_tree().create_timer(1).timeout
		main_node.queue_object_to_spawn("Apple")


func _on_score_changed(_new_score: int, changed_by: int) -> void:
	current_room.current_room_score += changed_by
	if current_room.get_is_room_complete():
		end_level()


func _setup_initial_room() -> void:
	current_room = room_mapper.get_room_at_layout_coordinates(Vector2(0, 0))
	current_room_neighbors = room_mapper.get_room_neighbors(current_room)
	_load_room(current_room)
