class_name RoomManager extends RefCounted

var dungeon: Dungeon
var current_room_neighbors: RoomMapper.RoomNeighbors
var loaded_rooms: Array[Room]


func _init(p_dungeon: Dungeon) -> void:
	dungeon = p_dungeon


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

	if dungeon.current_room:
		var walled_off_directions: Array[String] = (
			dungeon.current_room.walled_off_directions.duplicate()
		)
		exclusions = exclusions + walled_off_directions

	return exclusions


func load_room(room: Room) -> void:
	var room_tile_map: RoomTileMap = room.tile_map.instantiate()
	dungeon.room_mapper.add_child(room_tile_map)
	room_tile_map.visible = false
	var position_offset:= Vector2(room.layout_x * 20, room.layout_y * -20)
	dungeon.main_node.level_factory.setup_level(
		room_tile_map.room_tile_map,
		position_offset,
	)
	loaded_rooms.append(room)


func set_current_room_to_start() -> void:
	dungeon.current_room = dungeon.room_mapper.get_room_at_layout_coordinates(
		Vector2(0, 0)
	)
	current_room_neighbors = dungeon.room_mapper.get_room_neighbors(
		dungeon.current_room
	)


func update_rooms(direction: String) -> void:
	if direction == "ERROR":
		return

	match direction:
		"N":
			dungeon.current_room = current_room_neighbors.up
		"S":
			dungeon.current_room = current_room_neighbors.down
		"E":
			dungeon.current_room = current_room_neighbors.right
		"W":
			dungeon.current_room = current_room_neighbors.left

	if not dungeon.current_room:
		return

	current_room_neighbors = dungeon.room_mapper.get_room_neighbors(
		dungeon.current_room
	)
	_load_room_neighbors()


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
