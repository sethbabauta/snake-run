class_name RoomMapper extends Node

@export var rooms_resource_group: ResourceGroup
var rooms: Array[Room]


func _ready() -> void:
	rooms_resource_group.load_all_into(rooms)


func get_room_neighbors(room: Room) -> RoomNeighbors:
	return RoomNeighbors.new(room, rooms)


func get_room_at_layout_coordinates(layout_coordinates: Vector2) -> Room:
	for current_room in rooms:
		if (current_room.layout_x == layout_coordinates.x
		and current_room.layout_y == layout_coordinates.y):
			return current_room

	return null


class RoomNeighbors:
	var rooms: Array[Room]
	var room: Room
	var left: Room
	var right: Room
	var up: Room
	var down: Room


	func _init(p_room: Room, p_rooms: Array[Room]) -> void:
		room = p_room
		rooms = p_rooms
		_search_for_neighbors()


	func _search_for_neighbors() -> void:
		var left_coordinates:= Vector2i(room.layout_x - 1, room.layout_y)
		var right_coordinates:= Vector2i(room.layout_x + 1, room.layout_y)
		var up_coordinates:= Vector2i(room.layout_x, room.layout_y + 1)
		var down_coordinates:= Vector2i(room.layout_x, room.layout_y - 1)

		for current_room in rooms:
			var current_room_coordinates = Vector2i(current_room.layout_x, current_room.layout_y)
			if current_room_coordinates == left_coordinates:
				left = current_room
				continue
			if current_room_coordinates == right_coordinates:
				right = current_room
				continue
			if current_room_coordinates == up_coordinates:
				up = current_room
				continue
			if current_room_coordinates == down_coordinates:
				down = current_room
				continue
