class_name Dungeon extends Node

const START_LENGTH = 3

var current_room: Room
var current_room_neighbors: RoomMapper.RoomNeighbors
var loaded_rooms: Array[Room]

@onready var main: Main = %Main
@onready var room_mapper: RoomMapper = %room_mapper


func _ready() -> void:
	EventBus.level_changed.connect(_on_level_changed)

	current_room = room_mapper.get_room_at_layout_coordinates(Vector2(0, 0))
	current_room_neighbors = room_mapper.get_room_neighbors(current_room)
	EventBus.level_changed.emit("Start")


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
	# if room & neighbors not loaded, load rooms

