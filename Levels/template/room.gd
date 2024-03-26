class_name Room extends Resource

@export var score_threshold: int
@export var tile_map: PackedScene
@export var layout_x: int
@export var layout_y: int

var current_room_score: int = 0


static func get_world_coordinates(layout_coordinates: Vector2) -> Vector2:
	var simple_coordinates: Vector2 = layout_coordinates * 20
	return Utils.convert_simple_to_world_coordinates(simple_coordinates)
