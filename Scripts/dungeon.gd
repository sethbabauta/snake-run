class_name Dungeon extends Node

const START_LENGTH = 3

var current_room: Room
var current_room_neighbors: RoomMapper.RoomNeighbors
var loaded_rooms: Array[Room]

@onready var main_node: Main = %Main
@onready var room_mapper: RoomMapper = %room_mapper


func _ready() -> void:
	EventBus.level_changed.connect(_on_level_changed)
	main_node.move_timer.speed_5.connect(_on_move_timer_speed_5)

	_setup_initial_room()
	EventBus.level_changed.emit("Start")


func _load_room(room: Room) -> void:
	var room_tile_map: RoomTileMap = room.tile_map.instantiate()
	room_mapper.add_child(room_tile_map)
	room_tile_map.visible = false
	var position_offset:= Vector2(room.layout_x * 20, room.layout_y * 20)
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


func _setup_initial_room() -> void:
	current_room = room_mapper.get_room_at_layout_coordinates(Vector2(0, 0))
	current_room_neighbors = room_mapper.get_room_neighbors(current_room)
	_load_room(current_room)


func _on_level_changed(direction: String) -> void:
	match direction:
		"North":
			current_room = current_room_neighbors.up
		"South":
			current_room = current_room_neighbors.down
		"East":
			current_room = current_room_neighbors.right
		"West":
			current_room = current_room_neighbors.left

	current_room_neighbors = room_mapper.get_room_neighbors(current_room)
	_load_room_neighbors()



func _on_move_timer_speed_5() -> void:
	# check if player head is on screen
		# no:
		# check direction and emit level changed
		# return

	# check if player tail is on screen
		# emit player fully entered
	pass
